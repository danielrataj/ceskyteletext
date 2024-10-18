import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:global_snack_bar/global_snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ceskyteletext/elements/teletext_page.dart' as elements;
import 'package:ceskyteletext/elements/no_teletext_data.dart' as elements;
import 'package:ceskyteletext/elements/simple_keyboard.dart' as elements;
import 'package:ceskyteletext/elements/no_internet_connection.dart' as element;
import 'package:ceskyteletext/elements/custom_scaffold.dart' as element;
import 'package:ceskyteletext/model/teletext_page.dart' as model;
import 'package:ceskyteletext/model/app_state.dart' as model;
import 'package:provider/provider.dart';

const String pagesUrl = 'https://api-teletext.ceskatelevize.cz/teletext-api/?t=0';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int page1 = 1;
  int page2 = 0;
  int page3 = 0;

  model.AppState appstate = model.AppState();

  List<ConnectivityResult> _connectionStatus = [];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  initState() {
    super.initState();

    initConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Be sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();

    _connectivitySubscription.cancel();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = (await _connectivity.checkConnectivity());
    } on PlatformException catch (_) {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  Future<List<model.TeletextPage>> getTeletextPages() async {
    try {
      final response = await http.Client().get(Uri.parse(pagesUrl));
      final Map<String, dynamic> parsed = jsonDecode(response.body)['data'];

      return parsed.entries
          .map<model.TeletextPage>((json) => model.TeletextPage.fromJson(json))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print(e);
      throw Error();
    }
  }

  showSnack() {}

  @override
  Widget build(BuildContext context) {
    return element.CustomScaffold(
        title: widget.title,
        body: _connectionStatus.contains(ConnectivityResult.none)
            ? const element.NoInternetConnection()
            : FutureBuilder<List<model.TeletextPage>>(
                future: getTeletextPages(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<model.TeletextPage>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const elements.NoTelextData();
                  }

                  if (snapshot.data == null) {
                    return const elements.NoTelextData();
                  }

                  List<model.TeletextPage> pages =
                      snapshot.data as List<model.TeletextPage>;

                  return Consumer<model.AppState>(builder:
                      (BuildContext context, model.AppState appstate,
                          Widget? child) {
                    if (appstate.page.isEmpty) {
                      return Container();
                    }

                    List<Widget> elementsToPaint = [];

                    if (appstate.page.isNotEmpty) {
                      page1 = int.parse(appstate.page.toString().split('')[0]);
                      page2 = int.parse(appstate.page.toString().split('')[1]);
                      page3 = int.parse(appstate.page.toString().split('')[2]);

                      String selectedPage = appstate.page;

                      model.TeletextPage teletextPage = pages.firstWhere(
                          (element) => element.key == selectedPage, orElse: () {
                        return const model.TeletextPage(key: '', subpages: []);
                      });

                      if (teletextPage.subpages.isEmpty) {
                        GlobalSnackBarBloc.showMessage(
                          GlobalMsg(
                              'Stránku $selectedPage jsme na teletextu nenašli.',
                              bgColor: Theme.of(context).colorScheme.error),
                        );

                        selectedPage = '100';
                      }

                      final fullHeight = MediaQuery.of(context).size.height;
                      final appBarHeight =
                          Scaffold.of(context).appBarMaxHeight! +
                              MediaQuery.of(context).padding.top;
                      final scaffoldBodyHeight =
                          (fullHeight - appBarHeight) / 2;

                      elementsToPaint.add(SizedBox(
                        height: scaffoldBodyHeight,
                        child: elements.TeletextPage(
                            teletextPages: pages, selectedPage: selectedPage),
                      ));

                      elementsToPaint.add(
                        SizedBox(
                          height:
                              scaffoldBodyHeight, // just make sure it is a bit smaller
                          child: elements.SimpleKeyboard(
                              teletextPages: pages,
                              selectedPage: selectedPage,
                              containerHeight: scaffoldBodyHeight),
                        ),
                      );
                    }

                    return Column(
                      children: elementsToPaint,
                    );
                  });
                }));
  }
}

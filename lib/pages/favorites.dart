import 'package:ceskyteletext/elements/custom_scaffold.dart' as element;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/material.dart';
import 'package:ceskyteletext/model/app_state.dart' as model;

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.title});

  final String title;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  model.AppState appstate = model.AppState();

  Widget card({required String page, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.sp),
        leading:
            Image.network(appstate.teletextImageUrl.replaceFirst('%s', page)),
        trailing: Icon(Icons.keyboard_arrow_right,
            color: Theme.of(context).appBarTheme.backgroundColor, size: 25.sp),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            subtitle: title != page ? Text(page) : null,
        onTap: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) {
            Provider.of<model.AppState>(context, listen: false)
                .updatePage(entered: page);
            return false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return element.CustomScaffold(
        title: widget.title,
        body: FutureBuilder(
            future:
                Provider.of<model.AppState>(context, listen: true).favorites,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container();
              }

              if (snapshot.hasError) {
                return Container();
              }

              List<String> favorites = snapshot.data as List<String>;

              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mood_bad, size: 40.sp),
                      Text('Zatím tu nemáte žádné oblíbené stránky.',
                          style: TextStyle(fontSize: 20.sp),
                          textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FutureBuilder(
                        future: appstate.pageTitle(page: favorites[index]),
                        builder:
                            (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasError) {
                            return Container();
                          }

                          if (!snapshot.hasData) {
                            return Container();
                          }

                          String title = snapshot.data ?? '';

                          return card(page: favorites[index], title: title);
                        });
                  });
            }));
  }
}

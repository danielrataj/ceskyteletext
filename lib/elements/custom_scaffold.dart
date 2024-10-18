import 'package:flutter/material.dart';
import 'package:ceskyteletext/model/app_state.dart' as model;
import 'package:provider/provider.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const CustomScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    if (ModalRoute.of(context)?.settings.name == '/favorites') {
      actions.add(
        FutureBuilder(
          future: Provider.of<model.AppState>(context, listen: true).favorites,
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
              return Container();
            }

            return IconButton(
                tooltip: 'smazat oblíbené',
                onPressed: () {
                  Provider.of<model.AppState>(context, listen: false)
                      .removeAll();
                },
                icon: const Icon(
                  Icons.delete_forever,
                  semanticLabel: 'smazat oblíbené',
                ));
          },
        ),
      );
    }

    if (ModalRoute.of(context)?.settings.name != '/favorites') {
      actions.add(
        FutureBuilder(
          future: Provider.of<model.AppState>(context, listen: true).favorites,
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
              return Container();
            }

            return IconButton(
                tooltip: 'ukázat oblíbené',
                onPressed: () {
                  Navigator.pushNamed(context, '/favorites');
                },
                icon: const Icon(
                  Icons.favorite_outline,
                  semanticLabel: 'oblíbené',
                ));
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: Text(title), centerTitle: false, actions: actions),
      body: body,
    );
  }
}

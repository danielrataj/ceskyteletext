import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ceskyteletext/model/teletext_page.dart' as model;
import 'package:ceskyteletext/model/app_state.dart' as model;
import 'package:provider/provider.dart';

class SimpleKeyboard extends StatefulWidget {
  final List<model.TeletextPage> teletextPages;
  final String selectedPage;
  final double containerHeight;

  const SimpleKeyboard(
      {super.key,
      required this.teletextPages,
      required this.selectedPage,
      required this.containerHeight});

  @override
  State<SimpleKeyboard> createState() => _SimpleKeyboardState();
}

class _SimpleKeyboardState extends State<SimpleKeyboard> {
  String entered = '';
  final TextEditingController _textFieldController = TextEditingController();
  String codeDialog = '';
  String valueText = '';

  Future<void> _displayTextInputDialog(
      {required BuildContext context, required String selectedPage}) async {
    _textFieldController.text = selectedPage;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Název stránky'),
            content: TextField(
              onChanged: (value) {
                if (value.isEmpty) {
                  value = selectedPage;
                }

                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "popis stránky"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('zpět'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                autofocus: true,
                child: const Text('do oblíbených'),
                onPressed: () {
                  setState(() {
                    Provider.of<model.AppState>(context, listen: false)
                        .addFavorite(
                            selectedPage: selectedPage,
                            title: _textFieldController.text);

                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void updateEntered({required int key}) {
    setState(() {
      entered = entered + key.toString();
    });

    if (entered.length > 3) {
      setState(() {
        entered = key.toString();
      });
    }

    if (entered.length == 3) {
      // update model in case we have three digits number
      Provider.of<model.AppState>(context, listen: false)
          .updatePage(entered: entered);
    }
  }

  void clear() {
    setState(() {
      entered = '';
    });
  }

  Widget button(int key) {
    return SizedBox(
      width: widget.containerHeight / 5,
      height: widget.containerHeight / 5,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
            onPressed: () {
              updateEntered(key: key);
            },
            child: Text(key.toString(), style: TextStyle(fontSize: 18.sp))),
      ),
    );
  }

  Widget homeButton() {
    return SizedBox(
        width: widget.containerHeight / 5,
        height: widget.containerHeight / 5,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ElevatedButton(
              onPressed: () {
                Provider.of<model.AppState>(context, listen: false)
                    .updatePage(entered: '100');
                setState(() {
                  entered = '100';
                });
              },
              child: Icon(Icons.home, size: 18.sp)),
        ));
  }

  Widget favoritesButton() {
    Future<bool> isSelected =
        Provider.of<model.AppState>(context, listen: false)
            .isFavorite(page: widget.selectedPage);

    return SizedBox(
        width: widget.containerHeight / 5,
        height: widget.containerHeight / 5,
        child: Padding(
            padding: const EdgeInsets.all(3),
            child: FutureBuilder(
                future: isSelected,
                builder: ((BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container();
                  }

                  if (snapshot.hasError) {
                    return Container();
                  }

                  bool isSelected = snapshot.data as bool;

                  return ElevatedButton(
                    onPressed: () {
                      if (isSelected) {
                        Provider.of<model.AppState>(context, listen: false)
                            .removeFavorite(selectedPage: widget.selectedPage);
                      } else {
                        _displayTextInputDialog(
                            context: context,
                            selectedPage: widget.selectedPage);
                      }
                    },
                    child: Icon(
                      isSelected ? Icons.favorite : Icons.favorite_outline,
                      color: Colors.pink,
                      size: 18.sp
                    ),
                  );
                }))));
  }

  Widget changePageButton({int direction = 1}) {
    return SizedBox(
        width: widget.containerHeight / 5,
        height: widget.containerHeight / 5,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ElevatedButton(
              onPressed: () {
                model.TeletextPage nextTeletextPage =
                    const model.TeletextPage(key: '', subpages: []);

                for (int i = 0; i < widget.teletextPages.length; i++) {
                  if (widget.teletextPages[i].key == widget.selectedPage) {
                    try {
                      nextTeletextPage = widget.teletextPages[i + direction];
                    } catch (_) {}
                    break;
                  }
                }

                if (nextTeletextPage.key.isNotEmpty) {
                  Provider.of<model.AppState>(context, listen: false)
                      .updatePage(entered: nextTeletextPage.key);
                  entered = nextTeletextPage.key;
                }
              },
              child: Icon(
                  direction == 1 ? Icons.arrow_forward : Icons.arrow_back, size: 18.sp)),
        ));
  }

  @override
  void initState() {
    super.initState();

    entered = widget.selectedPage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              Row(children: [changePageButton(direction: -1)])
            ]),
            Column(
              children: [
                Row(children: [button(1), button(2), button(3)]),
                Row(children: [button(4), button(5), button(6)]),
                Row(children: [button(7), button(8), button(9)]),
                Row(children: [homeButton(), button(0), favoritesButton()])
              ],
            ),
            Column(
              children: [
                Row(children: [changePageButton(direction: 1)])
              ],
            )
          ],
        ),
        const Padding(padding: EdgeInsets.only(top: 10)),
        Chip(
          label:
              Text(entered.isNotEmpty ? entered.toString() : 'zadejte stránku'),
          onDeleted: entered.isNotEmpty
              ? () {
                  clear();
                }
              : null,
        )
      ],
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:ceskyteletext/model/teletext_page.dart' as model;
import 'package:ceskyteletext/model/app_state.dart' as model;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

const String defaultPage = '100';

class TeletextPage extends StatefulWidget {
  final List<model.TeletextPage> teletextPages;
  final String selectedPage;

  const TeletextPage(
      {super.key, required this.teletextPages, required this.selectedPage});

  @override
  State<TeletextPage> createState() => _TeletextPageState();
}

class _TeletextPageState extends State<TeletextPage> {
  @override
  Widget build(BuildContext context) {
    String selectedPage = widget.selectedPage;
    model.TeletextPage teletextPage = widget.teletextPages
        .firstWhere((element) => element.key == selectedPage, orElse: () {
      return const model.TeletextPage(key: '', subpages: []);
    });

    if (teletextPage.subpages.isEmpty) {
      throw 'Teletext is missing subpages. Probably wrong page number.';
    }

    return CarouselSlider.builder(
        itemCount: teletextPage.subpages.length,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          final Image image = Image.network(loadingBuilder:
                  (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
              fit: BoxFit.fitWidth,
              Provider.of<model.AppState>(context, listen: false)
                  .teletextImageUrl
                  .replaceFirst('%s',
                      '${teletextPage.key}${teletextPage.subpages[itemIndex]}'));

          List<Widget> itemsInColumn = [];

          itemsInColumn.add(Expanded(child: image));

          if (teletextPage.subpages.length > 1) {
            itemsInColumn.add(const Padding(
              padding: EdgeInsets.only(top: 5),
            ));
            itemsInColumn.add(Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: teletextPage.subpages.map<Widget>((e) {
                IconData icon = Icons.circle;

                if (teletextPage.subpages[itemIndex] == e) {
                  icon = Icons.circle_outlined;
                }

                return Icon(
                  icon,
                  size: 10,
                  color: Theme.of(context).appBarTheme.backgroundColor,
                );
              }).toList(),
            ));
          }

          return GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: itemsInColumn,
            ),

            // show image in gallery
            // add to favorite
            onDoubleTap: () {
              showImageViewer(context, image.image,
                  backgroundColor: Colors.blue[50] as Color,
                  closeButtonColor:
                      Theme.of(context).appBarTheme.backgroundColor as Color);
            },
          );
        },
        options: CarouselOptions(
          viewportFraction: 1,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          height: 40.h,
        ));
  }
}

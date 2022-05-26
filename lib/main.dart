import 'package:ceskyteletext/pages/favorites.dart';
import 'package:ceskyteletext/pages/homepage.dart';
import 'package:global_snack_bar/global_snack_bar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ceskyteletext/model/app_state.dart' as model;

const String title = 'Český Teletext';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget wrapperWidget({required Widget child}) {
    return GlobalMsgWrapper(child);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) {
        return ChangeNotifierProvider(
            create: (context) => model.AppState()..initiate(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: title,
              theme: FlexThemeData.light(
                  scheme: FlexScheme.bahamaBlue, useMaterial3: true),
              darkTheme: FlexThemeData.light(
                  scheme: FlexScheme.bahamaBlue, useMaterial3: true),
              themeMode: ThemeMode.system,
              routes: {
                '/': (context) {
                  return wrapperWidget(child: const MyHomePage(title: title));
                },
                '/favorites': (context) => wrapperWidget(
                    child:
                        const FavoritesPage(title: '$title - Oblíbené')),
              },
              initialRoute: '/',
            ));
      },
    );
  }
}

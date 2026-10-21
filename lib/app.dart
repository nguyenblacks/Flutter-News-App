import 'package:flutter/material.dart';
import 'package:flutter_news_app/feature/presentation/page/home/home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder(
          valueListenable: Hive.box('settings').listenable(),
          builder: (context, box, _) {
            var isDarkMode = box.get('darkMode') ?? false;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Swavoti news',
              theme: ThemeData(
                useMaterial3: true,
                brightness: isDarkMode ? Brightness.dark : Brightness.light,
              ),
              home: child,
            );
          },
        );
      },
      child: const HomePage(),
    );
  }
}

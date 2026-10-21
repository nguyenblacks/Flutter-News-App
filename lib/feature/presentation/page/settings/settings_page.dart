import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WidgetAppBar(),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(48.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Interface',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Use dark mode',
                        style: TextStyle(
                          fontSize: 42.sp,
                        ),
                      ),
                      Text(
                        'Get that whiteness out',
                        style: TextStyle(
                          fontSize: 36.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: Hive.box('settings').listenable(),
                  builder: (context, box, widget) {
                    var isDarkMode = box.get('darkMode') ?? false;
                    return Switch(
                      value: isDarkMode,
                      onChanged: (value) async {
                        await box.put('darkMode', value);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WidgetAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Settings'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/screens/home.dart';
import 'package:sizer/sizer_util.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  // runApp(MyApp());
  runApp(DevicePreview(
    builder: (context) => MyApp(),
    enabled: !kReleaseMode,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizerUtil().init(constraints, orientation); //initialize SizerUtil
            return MaterialApp(
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: Home(title: 'News Lounge'),
            );
          },
        );
      },
    );
  }
}

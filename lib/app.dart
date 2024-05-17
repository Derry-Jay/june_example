import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'utils/keys.dart';
import 'utils/values.dart';
import 'views/screens/common/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget rootBuilder(BuildContext context, Widget? child) {
    ScreenUtil.init(context, minTextAdapt: true, designSize: minDesignSize);
    return MaterialApp(
        home: child,
        theme: css.theme,
        navigatorKey: navKey,
        onGenerateRoute: rg.generateRoute,
        debugShowCheckedModeBanner: kDebugMode,
        title: title.isEmpty ? acf.name : title);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        minTextAdapt: true,
        builder: rootBuilder,
        designSize: minDesignSize,
        child: const HomeScreen(title: 'Flutter Demo Home Page'));
  }
}

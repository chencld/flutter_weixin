/*
 * @Author: lidan6
 * @Date: 2020-10-21 14:01:22
 * @LastEditors: lidan6
 * @LastEditTime: 2020-11-13 16:11:35
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_weixin/weixin_page.dart';
import 'package:flutter_weixin/model/message_model.dart';
import 'package:flutter_weixin/model/weixin_model.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MessageModel()),
        ChangeNotifierProvider(create: (_) => WeixinModel()),
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WeixinPage(),
    );
  }
}


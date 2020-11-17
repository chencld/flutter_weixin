/*
 * @Author: lidan6
 * @Date: 2020-10-13 14:41:38
 * @LastEditors: lidan6
 * @LastEditTime: 2020-11-16 18:31:48
 * @Description: 
 */
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_weixin/widget/message.dart';
import 'package:flutter_weixin/data/reply_data.dart';

class MessageModel with ChangeNotifier {
  List<Message> _messagelist = List<Message> ();
  final int len = replyData.length;
  Map get messagedata => {
    "messageList": _messagelist,
  };
  
  // loadMessage() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   _messagelist = (prefs.getStringList('messagelist') ?? List<Message> ());
  //   notifyListeners();
  // }

  // setMessage(messagelist) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setStringList('bestscore', messagelist);
  // }

  addImage(List list,int type){
    final double aWidth = window.physicalSize.width;
    final double width = aWidth / window.devicePixelRatio;
    final double ratio = width / 640;
    list.forEach((element) { 
      var timestr = DateTime.now().toString();
      Message message=Message(
        time: timestr.split(".")[0],
        type: type,
        asset: element,
        width: width,
        ratio: ratio
      );
      _messagelist.add(message);
    });
    var timestr = DateTime.now().toString();
    int rnum = Random().nextInt(len);
    _messagelist.add(Message(
        time: timestr.split(".")[0],
        content: replyData[rnum],
        type: 3,
        width: width,
        ratio: ratio
    ));
    notifyListeners();
  }

  addMessage(String content,int type){
    //_messagelist.add(message);
    final double aWidth = window.physicalSize.width;
    final double width = aWidth / window.devicePixelRatio;
    final double ratio = width / 640;
    var timestr = DateTime.now().toString();
    Message message=Message(
      time: timestr.split(".")[0],
      content: content,
      type: type,
      width: width,
      ratio: ratio
    );
    _messagelist.add(message);
    var replytime = DateTime.now().toString();
    int rnum = Random().nextInt(len);
    _messagelist.add(Message(
        time: replytime.split(".")[0],
        content: replyData[rnum],
        type: 3,
        width: width,
        ratio: ratio
    ));
    //print('-----test2------');
    notifyListeners();
  }

  addMap(List list,int type){
    final double aWidth = window.physicalSize.width;
    final double width = aWidth / window.devicePixelRatio;
    final double ratio = width / 640;
    var timestr = DateTime.now().toString();
    Message message=Message(
      time: timestr.split(".")[0],
      title: list[0],
      content: list[1],
      type: type,
      width: width,
      ratio: ratio
    );
    _messagelist.add(message);
    var replytime = DateTime.now().toString();
    int rnum = Random().nextInt(len);
    _messagelist.add(Message(
        time: replytime.split(".")[0],
        content: replyData[rnum],
        type: 3,
        width: width,
        ratio: ratio
    ));
    notifyListeners();
  }

}
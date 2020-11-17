/*
 * @Author: lidan6
 * @Date: 2020-10-13 14:41:38
 * @LastEditors: lidan6
 * @LastEditTime: 2020-11-16 14:02:43
 * @Description: 
 */

import 'dart:typed_data';

import 'package:flutter/material.dart';

class WeixinModel with ChangeNotifier {
  bool menutag = true;
  bool emojitag = true;
  bool jietuShowTag = true;
  Uint8List jietuPic;
  Map get weixindata => {
    "menutag": menutag,
    "emojitag": emojitag,
    "jietuShowTag": jietuShowTag,
    "jietuPic": jietuPic
  };
  
  setMenuTag(bool tag){
    menutag = tag;
    //notifyListeners();
  }

  setEmojiTag(bool tag){
    emojitag = tag;
    //notifyListeners();
  }

  setJietuTag(bool tag){
    jietuShowTag = tag;
    //notifyListeners();
  }

  setJietuPic(Uint8List pic){
    jietuPic = pic;
  }

}


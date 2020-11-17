/*
 * @Author: lidan6
 * @Date: 2020-10-13 14:41:38
 * @LastEditors: lidan6
 * @LastEditTime: 2020-11-12 14:27:39
 * @Description: 
 */
import 'package:multi_image_picker/multi_image_picker.dart';

class Message {
  String time;
  String title;
  String content;
  Asset asset;
  int type;
  double width;
  double ratio;
  Message({
    this.time,
    this.title,
    this.content,
    this.asset,
    this.type,
    this.width,
    this.ratio
  });
}
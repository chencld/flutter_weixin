/*
 * @Author: lidan6
 * @Date: 2020-10-21 14:01:22
 * @LastEditors: lidan6
 * @LastEditTime: 2020-11-16 17:59:04
 * @Description: 
 */
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:flutter_weixin/model/message_model.dart';
import 'package:flutter_weixin/model/weixin_model.dart';
import 'package:flutter_weixin/widget/message.dart';
import 'package:flutter_weixin/widget/map_widget.dart';
import 'package:flutter_weixin/widget/emotion_widget.dart';
import 'package:flutter_weixin/widget/content_box.dart';

class WeixinPage extends StatefulWidget {
  @override
  _WeixinPageState createState() => _WeixinPageState();
}
class _WeixinPageState extends State < WeixinPage > {
  String error = 'No Error Dectected';
  String inputVal;
  final TextEditingController _inputController = new TextEditingController();
  ScrollController _listcontroller = ScrollController();
  GlobalKey repaintWidgetKey = GlobalKey(); // 绘图key值

  /// 截屏图片生成图片流ByteData
  Future<ByteData> _capturePngToByteData() async {
    try {
      RenderRepaintBoundary boundary = repaintWidgetKey.currentContext
          .findRenderObject();
      double dpr = window.devicePixelRatio; // 获取当前设备的像素比
      var image = await boundary.toImage(pixelRatio: dpr);
      ByteData _byteData = await image.toByteData(format: ImageByteFormat.png);
      return _byteData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future < void > loadImages(callback) async {
    try {
      List<Asset> resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "照片",
          allViewTitle: "照片",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
      if(!mounted) return;
      callback(resultList);
    } on Exception catch (e) {
      error = e.toString();
    }
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    //Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  @override
  Widget build(BuildContext context) {
    final double aWidth = window.physicalSize.width;
    final double width = aWidth / window.devicePixelRatio;
    final double ratio = width / 640;
    //var messageModel = Provider.of < MessageModel > (context);
    //var weixinModel = Provider.of < WeixinModel > (context);

    return RepaintBoundary(
      key: repaintWidgetKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "喵～",
            style: TextStyle(
              fontSize: 36 * ratio,
              color: Colors.white
            ),
          ),
          toolbarHeight: 88.0 * ratio,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFF2D2C33),
                Color(0xFF18171A),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ),
        body: Container(
          color: Color(0xFFEBEBEB),
          child: Stack(
            children: [
              Consumer < MessageModel > (
                builder: (context, MessageModel messagemodel, _) {
                  List messageList = messagemodel.messagedata["messageList"];
                  if (messageList.length > 0)
                  Timer(Duration(milliseconds: 500),
                      () => _listcontroller.jumpTo(_listcontroller.position.maxScrollExtent));

                  return ListView(
                    controller: _listcontroller,
                    padding: EdgeInsets.only(bottom: 360 * ratio),
                    children: List.generate(messageList.length, (index) {
                      Message _message = messageList[index];
                      return Column(
                        children: [
                          timeText(_message.time, _message.ratio),
                          contentBox(_message,context)
                        ]
                      );
                    }),
                  );
                }
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(bottom:30),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 245, 247, 1),
                    border: Border(
                      top: BorderSide(
                        color: Color.fromRGBO(203, 203, 204, .8),
                        width: 1 * ratio
                      ),
                    )
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ClickButton(56 * ratio, 'images/voice_message.png', () {

                          // }),
                          Container(
                            width: 398 * ratio,
                            constraints: BoxConstraints(
                              maxHeight: 72 * ratio * 3,
                              minHeight: 72 * ratio,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFFB4B6BA),
                                width: 1.0 * ratio
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(11 * ratio)),
                              color: Color(0xFFFDFDFE)
                            ),
                            child: Consumer2 < MessageModel,WeixinModel > (
                              builder: (context, MessageModel messagemodel, WeixinModel weixinmodel, _) {
                                return TextField(
                                  controller: _inputController,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.send,
                                  toolbarOptions: ToolbarOptions(
                                    copy: true,
                                    cut: true,
                                    paste: true,
                                    selectAll: true
                                  ),
                                  onTap:(){
                                    weixinmodel.setMenuTag(true);
                                    weixinmodel.setEmojiTag(true);
                                    weixinmodel.notifyListeners();
                                  },
                                  onChanged: (value) {
                                    inputVal = value;
                                  },
                                  onEditingComplete: (){
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    if(_inputController.text.isNotEmpty) messagemodel.addMessage(_inputController.text, 1);
                                    _inputController.clear();
                                  },
                                );
                              }
                            ),
                          ),
                          Consumer < WeixinModel > (
                            builder: (context, WeixinModel weixinmodel, _) {
                              return ClickButton(56 * ratio, 'images/emoji_stickers.png', () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                bool emojitag = weixinmodel.weixindata["emojitag"];
                                weixinmodel.setMenuTag(true);
                                weixinmodel.setEmojiTag(!emojitag);
                                weixinmodel.notifyListeners();
                              });
                            }
                          ),
                          Consumer < WeixinModel > (
                            builder: (context, WeixinModel weixinmodel, _) {
                              return ClickButton(56 * ratio, 'images/more_button.png', () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                bool menutag = weixinmodel.weixindata["menutag"];
                                weixinmodel.setMenuTag(!menutag);
                                weixinmodel.setEmojiTag(true);
                                weixinmodel.notifyListeners();
                              });
                            }
                          ),
                        ]
                      ),
                      Consumer < WeixinModel > (
                        builder: (context, WeixinModel weixinmodel, _) {
                          return Offstage(
                            offstage: weixinmodel.weixindata["menutag"],
                            child: Container(
                              padding: EdgeInsets.all(30 * ratio),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Consumer < MessageModel > (
                                        builder: (context, MessageModel messagemodel, _) {
                                          return ClickButton(118 * ratio, 'images/icon_photo.png', () {
                                            loadImages((resultList) {
                                              if(resultList.length>0) messagemodel.addImage(resultList, 0);
                                            });
                                          });
                                        }
                                      ),
                                      Text("照片")
                                    ]
                                  ),
                                  Column(
                                    children: [
                                      Consumer < MessageModel > (
                                        builder: (context, MessageModel messagemodel, _) {
                                          return ClickButton(118 * ratio, 'images/icon_location.png', () {
                                            Navigator.of(context).push(
                                              new MaterialPageRoute(
                                                builder: (context) {
                                                  return MapWidget((mapList){
                                                    if(mapList.length>0) messagemodel.addMap(mapList, 2);
                                                  });
                                                }
                                              )
                                            );
                                          });
                                        }
                                      ),
                                      Text("位置")
                                    ]
                                  ),
                                  Column(
                                    children: [
                                      Consumer < WeixinModel > (
                                        builder: (context, WeixinModel weixinmodel, _) {
                                          return ClickButton(118 * ratio, 'images/icon_jietu.png', () async{
                                            ByteData sourceByteData = await _capturePngToByteData();
                                            if(sourceByteData != null){
                                              Uint8List sourceBytes = sourceByteData.buffer.asUint8List();
                                              weixinmodel.setJietuPic(sourceBytes);
                                              weixinmodel.setJietuTag(false);
                                              weixinmodel.notifyListeners();
                                            }
                                            else{
                                              Fluttertoast.showToast(
                                                msg: "请稍等～",
                                                toastLength: Toast.LENGTH_LONG,
                                              );
                                            }
                                          });
                                        }
                                      ),
                                      Text("截图")
                                    ]
                                  ),
                                ]
                              ),
                            )
                          );
                        }
                      ),
                      Consumer < WeixinModel > (
                        builder: (context, WeixinModel weixinmodel, _) {
                          return Offstage(
                            offstage: weixinmodel.weixindata["emojitag"],
                            child:EmotionWidget(textController:_inputController)
                          );
                        }
                      )
                    ]
                  )
                )
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Consumer < WeixinModel > (
                  builder: (context, WeixinModel weixinmodel, _) {
                    Uint8List jietuPic = weixinmodel.weixindata["jietuPic"];
                    return Offstage(
                        offstage: weixinmodel.weixindata["jietuShowTag"],
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0x33000000)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:  [
                              jietuPic != null ? Image.memory(
                                jietuPic,
                                width: 200,
                                fit: BoxFit.fitWidth,
                              ):Text(""),
                              GestureDetector(
                                onTap: () async {
                                  await _requestPermission();
                                  if(jietuPic.isNotEmpty){
                                    await ImageGallerySaver.saveImage(jietuPic);
                                    Fluttertoast.showToast(
                                      msg: "保存成功～",
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                  }
                                  weixinmodel.setJietuTag(true);
                                  weixinmodel.notifyListeners();
                                },
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'images/share_tag.png',
                                      width: 50 * ratio,
                                      height: 50 * ratio,
                                    ),
                                    SizedBox(width: 6,),
                                    Text(
                                      "保存",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ],
                                )
                              )
                            ],
                          )
                        )
                    );
                  }
                )
              )
            ],
          ),
        )
      )
    );
  }
}

Widget ClickButton(size, picUrl, callback) {
  return SizedBox(
    width: size,
    child: IconButton(
      icon: ImageIcon(
        AssetImage(picUrl),
        size: size,
      ),
      padding: EdgeInsets.all(0),
      onPressed: () {
        callback();
      },
    ),
  );
}

Widget timeText(str, ratio) {
  return Center(
    child: Container(
      padding: EdgeInsets.fromLTRB(12 * ratio, 6 * ratio, 12 * ratio, 6 * ratio),
      margin: EdgeInsets.fromLTRB(0, 52 * ratio, 0, 26 * ratio),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10 * ratio)),
        color: Color(0xFFCFCFCF)
      ),
      child: Text(
        str,
        style: TextStyle(
          fontSize: 23 * ratio,
          color: Colors.white,
        ),
      ),
    ),
  );
}
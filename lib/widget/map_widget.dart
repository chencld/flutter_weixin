/*
 * @Author: lidan6
 * @Date: 2020-09-30 16:29:32
 * @LastEditors: lidan6
 * @LastEditTime: 2020-11-12 15:47:18
 * @Description: 
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:amap_all_fluttify/amap_all_fluttify.dart';
import 'package:permission_handler/permission_handler.dart';
Future<bool> requestPermission() async {
  final status = await Permission.location.request();
  if (status == PermissionStatus.granted) {
    return true;
  } else {
    //toast('需要定位权限!');
    return false;
  }
}

class MapWidget extends StatefulWidget {
  Function callback;
  MapWidget(this.callback,{
    Key key
  }): super(key: key);
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State < MapWidget > with AmapSearchDisposeMixin{
  AmapController _mapController;
  final TextEditingController _inputController = new TextEditingController();
  LatLng _latLngNew;
  String _cityCode,_cityName;
  List _poiTitleList = [];
  int _tapIndex = 0;
  bool isAndroid = false;
  bool searchTag = false;
  bool listClickTag = false;
  bool firstTag = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      isAndroid = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: < Widget > [
          Flexible(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: < Widget > [
                AmapView(
                  zoomLevel: 16.0,
                  rotateGestureEnabled: false,
                  markers: <MarkerOption>[],
                  onMapCreated: (controller) async {
                    _mapController = controller;
                    // 等待用户授权
                    if (await requestPermission()) {
                      // 初始位置周边信息
                      await controller.showMyLocation(MyLocationOption(show: true));
                    }
                  },
                  onMapMoveEnd: (MapMove move) async {
                    LatLng _myLocation;
                    if(firstTag){
                      _myLocation = await _mapController ?.getLocation();
                      firstTag = false;
                    }
                    else{
                      _myLocation = move.latLng;
                    }
                    if(listClickTag || searchTag){
                      listClickTag = false;
                      searchTag = false;
                    }
                    else{
                      var location = await AmapLocation.fetchLocation();
                      String cityCode = location.cityCode;
                      _cityName = location.city;
                      _cityCode = cityCode ?? '010';
                      // 搜索附近
                      var myPoiList = await AmapSearch.searchAround(_myLocation, city: _cityCode);
                      List _tempList = [];
                      await Future.forEach(myPoiList, (item) async {
                        String title = await item.title;
                        String address = await item.address;
                        LatLng location = await item.latLng;
                        _tempList.add([title, address, location]);
                      });
                      setState(() {
                        _tapIndex = 0;
                        _poiTitleList = _tempList;
                      });
                    }
                  },
                ),
                Positioned(
                  child: Image.asset(
                    "images/map_arrow.png",
                    width: 30,
                  ),
                ),
                Positioned(
                  left: 15,
                  top: 50,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 60,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(6))
                      ),
                      child: Text(
                        "取消",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70
                        ),
                      ),
                    ),
                  )
                ),
                Positioned(
                  right: 15,
                  top: 50,
                  child: InkWell(
                    onTap: () {
                      widget.callback(_poiTitleList[_tapIndex]);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 60,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF84D55A),
                        borderRadius: BorderRadius.all(Radius.circular(6))
                      ),
                      child: Text(
                        "发送",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white
                        ),
                      ),
                    ),
                  )
                )
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: < Widget > [
                    // 输入地点搜索周边
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: '搜索地点',
                        prefixIcon: Icon(Icons.search, color: Colors.green, ),
                      ),
                      onSubmitted: (value) async {
                        List _tempList = [];
                        final poiList = await AmapSearch.searchKeyword(value, city: _cityName);
                        await Future.forEach(poiList, (item) async {
                          String title = await item.title;
                          String address = await item.address;
                          LatLng location = await item.latLng;
                          _tempList.add([title, address, location]);
                        });
                        setState(() {
                            searchTag = true;
                            _poiTitleList = _tempList;
                            _tapIndex = 0;
                            _mapController.setCenterCoordinate(_tempList[0][2]);
                          });
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                    Expanded(
                      // 列表展示周边信息
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(_poiTitleList ?.length, (int index) {
                            return InkWell(
                              onTap: () {
                                // 第二次点击即选取此坐标
                                setState(() {
                                  listClickTag = true;
                                  _tapIndex = index;
                                  _latLngNew = _poiTitleList[index][2];
                                  _mapController.setCenterCoordinate(_latLngNew);
                                });
                                // 设置中心点为选中的坐标
                                //LatLng _latlng = LatLng(_poiTitleList[index][2].latitude,_poiTitleList[index][2].longitude);
                                //_mapController.clearMarkers(_poiTitleList);
                                // _mapController.addMarker(MarkerOption(
                                //   title: _poiTitleList[index][0],
                                //   latLng: _latLngNew,
                                //   iconProvider: AssetImage("images/map_arrow.png"),
                                // ));
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: 8, left: 4, right: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: < Widget > [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: < Widget > [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: < Widget > [
                                              Text(
                                                _poiTitleList[index][0],
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontWeight: FontWeight.w500), ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 4),
                                                child: Text(
                                                  _poiTitleList[index][1],
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 13), ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _tapIndex == index ? Icon(Icons.done, color: Colors.green, ) : Container()
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Container(
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          })
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ), )
        ],
      ),
    );
  }
}
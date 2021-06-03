import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_switch/flutter_switch.dart';
import 'package:newsapp/constants/constants.dart';
import 'package:newsapp/model/datamodel.dart';
import 'package:newsapp/widget/loader.dart';
import 'package:sizer/sizer.dart';
import 'package:sizer/sizer_util.dart' as s;

class Home extends StatefulWidget {
  final String title;
  const Home({Key key, this.title}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController _scrollController = new ScrollController();

  ArticleData articleData;

  List<Articles> data = new List();

  String from, too;

  String oldFrom, oldTo;

  bool _enable = false;
  int pageIndx;
  int pageCount = 1;

  @override
  // ignore: must_call_super
  void initState() {
    var fromDatee = DateTime.now();
    final DateFormat format = DateFormat('yyyy-MM-dd');
    var f = fromDatee.subtract(Duration(days: 2));
    var fr = format.format(f);
    var to = f.subtract(Duration(days: 7));
    var t = format.format(to);
    setState(() {
      oldFrom = fr;
      oldTo = t;
    });
    superFetch();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          superFetch();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  superFetch() async {
    setState(() {
      pageIndx = pageCount++;
    });
    var refUrl =
        "https://newsapi.org/v2/everything?q=covid&from=$too&to=$from&pageSize=15&apiKey=$apiKey2&page=${pageIndx.toString()}";
    var res = await http.get(refUrl);
    print(refUrl);
    if (res.statusCode == 200) {
      setState(() {
        var decodedJson = jsonDecode(res.body);
        articleData = ArticleData.fromJson(decodedJson);
        data.addAll(articleData.articles);
        print(data);
      });
    } else {
      throw Exception('Failed to load Articles from NewsApi.org');
    }
  }

  getDate(date) {
    var aa = DateTime.parse(date);
    final DateFormat format = DateFormat('dd-MM-yyyy HH:mm');
    final String formatted = format.format(aa);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
      child: Text(
        formatted,
        style: TextStyle(
            fontSize: SizerUtil.deviceType == s.DeviceType.Mobile
                ? 10.0.sp
                : 10.0.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.6),
        toolbarHeight:
            SizerUtil.deviceType == s.DeviceType.Mobile ? 5.0.h : 6.0.h,
        title: Text(
          widget.title,
          style: TextStyle(
              fontSize: SizerUtil.deviceType == s.DeviceType.Mobile
                  ? 14.0.sp
                  : 15.0.sp),
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 40.0.w,
                  height: SizerUtil.deviceType == s.DeviceType.Mobile
                      ? 3.0.h
                      : 4.0.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _enable == false
                          ? Text(
                              "Latest",
                              style: TextStyle(
                                  fontSize: SizerUtil.deviceType ==
                                          s.DeviceType.Mobile
                                      ? 12.0.sp
                                      : 13.0.sp,
                                  color: Colors.white),
                            )
                          : Text(
                              "Latest",
                              style: TextStyle(
                                  fontSize: SizerUtil.deviceType ==
                                          s.DeviceType.Mobile
                                      ? 12.0.sp
                                      : 13.0.sp),
                            ),
                      FlutterSwitch(
                        height: SizerUtil.deviceType == s.DeviceType.Mobile
                            ? 4.0.h
                            : 4.0.h,
                        width: SizerUtil.deviceType == s.DeviceType.Mobile
                            ? 10.0.w
                            : 11.0.w,
                        padding: SizerUtil.deviceType == s.DeviceType.Mobile
                            ? 4.0
                            : 8.0,
                        toggleSize: SizerUtil.deviceType == s.DeviceType.Mobile
                            ? 15
                            : 24.0,
                        borderRadius:
                            SizerUtil.deviceType == s.DeviceType.Mobile
                                ? 10.0
                                : 14.0,
                        activeColor: Colors.amber,
                        value: _enable,
                        onToggle: (value) {
                          setState(() {
                            _enable = value;
                          });
                        },
                      ),
                      _enable == true
                          ? Text(
                              "Old",
                              style: TextStyle(
                                  fontSize: SizerUtil.deviceType ==
                                          s.DeviceType.Mobile
                                      ? 12.0.sp
                                      : 13.0.sp,
                                  color: Colors.white),
                            )
                          : Text(
                              "Old",
                              style: TextStyle(
                                fontSize:
                                    SizerUtil.deviceType == s.DeviceType.Mobile
                                        ? 12.0.sp
                                        : 13.0.sp,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            articleData == null
                ? Container(
                    height: SizerUtil.deviceType == s.DeviceType.Mobile
                        ? 100.0.h
                        : 100.0.h,
                    child: Center(
                      child: BeatPulse(
                        color: Colors.black26,
                        size: 40.0,
                      ),
                    ),
                  )
                : Container(
                    height: SizerUtil.deviceType == s.DeviceType.Mobile
                        ? 100.0.h
                        : 100.0.h,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, index) {
                        var article = data[index];
                        print(article);
                        DateTime aa = DateTime.parse(article.publishedAt);
                        if (_enable == true) {
                          if (aa.isBefore(DateTime.parse(oldFrom)) &&
                              aa.isAfter(DateTime.parse(oldTo))) {
                            return Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0.0, 10.0, 0.0),
                                    child: Text(
                                      article.title,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: SizerUtil.deviceType ==
                                                  s.DeviceType.Mobile
                                              ? 12.0.sp
                                              : 13.0.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: SizerUtil.deviceType ==
                                                  s.DeviceType.Mobile
                                              ? 15.0.h
                                              : 17.0.h,
                                          width: 66.0.w,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  article.description ?? "",
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      fontSize: SizerUtil
                                                                  .deviceType ==
                                                              s.DeviceType
                                                                  .Mobile
                                                          ? 10.0.sp
                                                          : 10.0.sp),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        6.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  article.source.name,
                                                  style: TextStyle(
                                                      fontSize: SizerUtil
                                                                  .deviceType ==
                                                              s.DeviceType
                                                                  .Mobile
                                                          ? 10.0.sp
                                                          : 10.0.sp),
                                                ),
                                              ),
                                              getDate(article.publishedAt),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 15.0.h,
                                          width: 26.0.w,
                                          child: article.urlToImage == null
                                              ? null
                                              : Image.network(
                                                  article.urlToImage),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0.0, 10.0, 0.0),
                                  child: Text(
                                    article.title,
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: SizerUtil.deviceType ==
                                                s.DeviceType.Mobile
                                            ? 12.0.sp
                                            : 13.0.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: SizerUtil.deviceType ==
                                                s.DeviceType.Mobile
                                            ? 15.0.h
                                            : 17.0.h,
                                        width: 66.0.w,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                article.description ?? "",
                                                maxLines: 3,
                                                style: TextStyle(
                                                    fontSize: SizerUtil
                                                                .deviceType ==
                                                            s.DeviceType.Mobile
                                                        ? 10.0.sp
                                                        : 10.0.sp),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                article.source.name,
                                                style: TextStyle(
                                                    fontSize: SizerUtil
                                                                .deviceType ==
                                                            s.DeviceType.Mobile
                                                        ? 10.0.sp
                                                        : 10.0.sp),
                                              ),
                                            ),
                                            getDate(article.publishedAt),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 15.0.h,
                                        width: 26.0.w,
                                        child: article.urlToImage == null
                                            ? null
                                            : Image.network(article.urlToImage),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

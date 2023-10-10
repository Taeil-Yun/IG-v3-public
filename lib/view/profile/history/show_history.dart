import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class ShowHistoryScreen extends StatefulWidget {
  const ShowHistoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ShowHistoryScreen> createState() => _ShowHistoryScreenState();
}

class _ShowHistoryScreenState extends State<ShowHistoryScreen> {
  late PageController _controller;

  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int beforeIndex = 0;
  int scrollCount = 2;
  int minimumYear = 2018;
  int minimumMonth = 1;

  List weekTextList = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    _controller = PageController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        backgroundColor: ColorConfig.defaultWhite,
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black,),
        ),
        title: const ig-publicAppBarTitle(
          title: '공연 히스토리',
          color: Colors.black,
        ),
        actions: [
          TextButton(
            onPressed: () {
              print(123);
            },
            child: CustomTextBuilder(
              text: '추가하기',
              fontColor: const Color(0xFF9393a7),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: ColorConfig.defaultWhite,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFf7f5ff),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    child: Row(
                      children: [
                        CustomTextBuilder(text: 'a')
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    prevMonth(),
                    CustomTextBuilder(
                      text: '$year년 $month월',
                      fontColor: const Color(0xFF121016),
                      fontSize: 18.0.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    nextMonth(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 8.0),
                  child: Row(
                    children: List.generate(weekTextList.length, (index) {
                      return Container(
                        width: ((MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: CustomTextBuilder(
                          text: weekTextList[index],
                          fontColor: const Color(0xFF686889),
                          fontSize: 12.0.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: PageView.builder(
                      controller: _controller,
                      reverse: true,
                      itemCount: scrollCount,
                      onPageChanged: (value) {
                        if (value > beforeIndex) {
                          setState(() {
                            month--;
                        
                            if (month < 1) {
                              month = 12;
                              year--;
                            }
                        
                            if (DateTime(year, month).millisecondsSinceEpoch > DateTime(minimumYear, minimumMonth).millisecondsSinceEpoch) {
                              scrollCount++;
                            }
                        
                            beforeIndex = value;
                          });
                        } else {
                          setState(() {
                            month++;
                        
                            if (month > 12) {
                              month = 1;
                              year++;
                            }
                        
                            scrollCount--;
                        
                            if (value == 0) {
                              scrollCount = 2;
                            }
                        
                            beforeIndex = value;
                          });
                        }
                      },
                      itemBuilder: (context, snapshot) {
                        return dateViewer(year, month);
                      }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dateViewer(int years, int monthes) {
    DateTime firstDate = DateTime(years, monthes, 1);
    DateTime lastDate = DateTime(years, monthes + 1, 0);

    return Wrap(
      children: List.generate(lastDate.day + firstDate.weekday - 1, (index) {
        index = ((index - (firstDate.weekday)) + firstDate.weekday) + 1;

        // 앞의 빈자리를 계산해준다.
        if (index < firstDate.weekday) {
          return Container(
            width: (MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7,
            height: ((MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7) * 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          );
        }
        // 실제 달력 요일 부분
        return InkWell(
          onTap: () {
            if ((index - firstDate.weekday) + 1 == 1) {
              historyEditBottomSheet();
            } else if ((index - firstDate.weekday) + 1 == 2) {
              historyDetailBottomSheet();
            } else {
              addTicketImages();
            }
          },
          child: Container(
            width: (MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7,
            height: ((MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7) * 1.5,
            decoration: BoxDecoration(
              color: const Color(0xFFf7f7fa),
              borderRadius: BorderRadius.circular(4.0.r),
              border: year == DateTime.now().year && month == DateTime.now().month && index == (DateTime.now().day + firstDate.weekday - 1)
                ? Border.all(
                  width: 1.0,
                  color: ColorConfig().primary(),
                )
                : null,
              image: (index - firstDate.weekday) + 1 == 3
                ? const DecorationImage(
                  image: AssetImage('assets/img/d_main_bg_poster.jpeg'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                )
                : null,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            child: (index - firstDate.weekday) + 1 != 3 ? Center(
              child: CustomTextBuilder(
                text: '${index - (firstDate.weekday) + 1}',
                fontColor: const Color(0xFF9393a7),
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w800,
              ),
            ) : null,
          ),
        );
      }),
    );
  }

  Widget prevMonth() {
    return IconButton(
      onPressed: !(DateTime(year, month).millisecondsSinceEpoch <= DateTime(minimumYear, minimumMonth).millisecondsSinceEpoch) ? () {
        _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
      } : null,
      icon: Icon(
        Icons.arrow_back_ios_new_outlined,
        color: !(DateTime(year, month).millisecondsSinceEpoch <= DateTime(minimumYear, minimumMonth).millisecondsSinceEpoch) ? Colors.black : Colors.grey,
        size: 24.0.sp,
      ),
    );
  }

  Widget nextMonth() {
    return IconButton(
      onPressed: !(year == DateTime.now().year && month == DateTime.now().month) ? () {
        _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
      } : null,
      icon: Icon(
        Icons.arrow_forward_ios_outlined,
        color: !(year == DateTime.now().year && month == DateTime.now().month) ? Colors.black : Colors.grey,
        size: 24.0.sp,
      ),
    );
  }

  Future addTicketImages() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 218.0,
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: ColorConfig.defaultWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'profileImageRegist',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              InkWell(
                onTap: () {
                  print('permission');
                },
                child: Container(
                  height: 42.0,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: ColorConfig.defaultWhite,
                    border: Border.all(
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.photo_outlined,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 23.0),
                          child: const Text(
                            'getImageFromgallery',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  print('permission2');
                },
                child: Container(
                  height: 42.0,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: ColorConfig.defaultWhite,
                    border: Border.all(
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 23.0),
                          child: const Text(
                            'getImageFromCamera',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future historyEditBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        int yearForDetail = DateTime.now().year;
        int monthForDetail = DateTime.now().month;
        int yearSelect = 0;
        int monthSelect = 0;
        int daySelect = 0;

        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 689.0,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: ColorConfig.defaultWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                DateTime firstDate = DateTime(yearForDetail, monthForDetail, 1);
                DateTime lastDate = DateTime(yearForDetail, monthForDetail + 1, 0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'addHistory',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Container(
                      height: 110.0,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 90.0,
                            height: 110.0,
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0.0,
                                  width: 88.0,
                                  height: 108.0,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0.0,
                                  right: 8.0,
                                  child: InkWell(
                                    onTap: () {
                                      print('teass');
                                    },
                                    child: Container(
                                      width: 16.0,
                                      height: 16.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ColorConfig.defaultBlack.withOpacity(0.16),
                                            blurRadius: 4.0,
                                            offset: const Offset(0.0, 2.0),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.close,
                                          size: 12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 28.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DateTime(yearForDetail, monthForDetail).millisecondsSinceEpoch <= DateTime(minimumYear, minimumMonth).millisecondsSinceEpoch
                            ? const Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: 20.0,
                            )
                            : InkWell(
                              onTap: () {
                                setState(() {
                                  monthForDetail--;
                
                                  if (monthForDetail < 1) {
                                    monthForDetail = 12;
                                    yearForDetail--;
                                  }
                                });
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: 20.0,
                              ),
                            ),
                          Container(
                            height: 24.0,
                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              child: Text('$yearForDetail년 $monthForDetail월'),
                            ),
                          ),
                          yearForDetail == DateTime.now().year && monthForDetail == DateTime.now().month
                            ? const Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 20.0,
                            )
                            : InkWell(
                              onTap: () {
                                setState(() {
                                  monthForDetail++;

                                  if (monthForDetail > 12) {
                                    monthForDetail = 1;
                                    yearForDetail++;
                                  }
                                });
                              },
                              child: const Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 20.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: List.generate(weekTextList.length, (index) {
                          return Container(
                            width: (MediaQuery.of(context).size.width - 40.0) / 7,
                            margin: const EdgeInsets.only(bottom: 12.0),
                            alignment: Alignment.center,
                            child: Text(
                              weekTextList[index],
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Wrap(
                        children: List.generate(lastDate.day + firstDate.weekday - 1, (index) {
                          index = ((index - (firstDate.weekday)) + firstDate.weekday) + 1;

                          // 앞의 빈자리를 계산해준다.
                          if (index < firstDate.weekday) {
                            return Container(
                              width: (MediaQuery.of(context).size.width - 40.1 - 140.0) / 7,
                              height: 32.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                            );
                          }
                          // 실제 달력 요일 부분
                          return InkWell(
                            onTap: () {
                              setState(() {
                                daySelect = index - firstDate.weekday + 1;
                                yearSelect = yearForDetail;
                                monthSelect = monthForDetail;
                              });
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 40.1 - 140.0) / 7,
                              height: 32.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                              decoration: BoxDecoration(
                                color: yearSelect == yearForDetail && monthSelect == monthForDetail && daySelect == index - (firstDate.weekday) + 1
                                  ? ColorConfig().primaryLight()
                                  : ColorConfig.transparent,
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Center(
                                child: Text(
                                  '${index - (firstDate.weekday) + 1}',
                                  style: TextStyle(
                                    color: yearSelect == yearForDetail && monthSelect == monthForDetail && daySelect == index - (firstDate.weekday) + 1
                                      ? ColorConfig().primary()
                                      : Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 88.0,
                          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 20.0),
                          decoration: BoxDecoration(
                            color: ColorConfig.defaultWhite,
                            boxShadow: [
                              BoxShadow(
                                color: ColorConfig.defaultBlack.withOpacity(0.06),
                                blurRadius: 4.0,
                                offset: const Offset(0.0, -2.0),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  print('asdasdasda');
                                },
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 56.0) / 2,
                                  height: 54.0,
                                  margin: const EdgeInsets.only(right: 16.0),
                                  decoration: BoxDecoration(
                                    color: ColorConfig.defaultWhite,
                                    border: Border.all(
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'resetText',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  print('asdasdasda');
                                },
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 56.0) / 2,
                                  height: 54.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'save',
                                      style: TextStyle(
                                        color: ColorConfig.defaultWhite,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        );
      },
    );
  }

  Future historyDetailBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 646.0,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: ColorConfig.defaultWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 부분
                Container(
                  height: 364.0,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ColorConfig.defaultBlack.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                      ),
                      PageView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Center(
                            child: Container(
                              width: 210.0,
                              height: 300.0,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 10.0,
                        left: (MediaQuery.of(context).size.width - 60.0) / 2,
                        child: Container(
                          width: 60.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: ColorConfig.defaultWhite,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10.0,
                        left: (MediaQuery.of(context).size.width - 60.0) / 2,
                        child: Row(
                          children: List.generate(4, (index) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                color: index == 0 ? ColorConfig.defaultWhite : ColorConfig.defaultWhite.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                // 정보 부분
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '젠틀맨스 가이드: 사랑과 살인편',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 13.0, 20.0, 20.0),
                    child: Column(
                      children: [
                        Container(
                          height: 28.0,
                          alignment: Alignment.topCenter,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 16.0),
                                child: const Text(
                                  '일정',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const Text(
                                  '2021.10.30 (토) 오후 2시',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          height: 28.0,
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 16.0),
                                    child: const Text(
                                      '위치',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                      '극장이름',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 28.0,
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 16.0),
                                    child: const Text(
                                      '출연',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                      '유연석, 오만석',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 28.0,
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 16.0),
                                    child: const Text(
                                      '좌석',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                      'B6',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 16.0),
                                  child: const Text(
                                    '수량',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const Text(
                                    '1인',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

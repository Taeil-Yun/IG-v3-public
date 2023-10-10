import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';

class MainEarnPointScreen extends StatefulWidget {
  const MainEarnPointScreen({super.key});

  @override
  State<MainEarnPointScreen> createState() => _MainEarnPointScreenState();
}

class _MainEarnPointScreenState extends State<MainEarnPointScreen> with TickerProviderStateMixin {
  late ScrollController customScrollViewController;
  late TabController sliverTabBarController;

  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    customScrollViewController = ScrollController();

    sliverTabBarController = TabController(
      length: 3,
      vsync: this,  // vsync에 this 형태로 전달해줘야 애니메이션이 활성화됨
    );
    sliverTabBarController.addListener(handleTabSelection);
  }

  void handleTabSelection() {
    if (sliverTabBarController.indexIsChanging || sliverTabBarController.index != currentTabIndex) {
      setState(() {
        currentTabIndex = sliverTabBarController.index;
      });
    }
  }

  // sliver appbar 축소 or 확대 체크 함수
  bool get isSliverAppBarExpanded {
    return customScrollViewController.hasClients && customScrollViewController.offset > kToolbarHeight; //kExpandedHeight - kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: CustomScrollView(
        controller: customScrollViewController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          // sliver appbar
          SliverAppBar(
            leading: ig-publicAppBarLeading(
              press: () {},
              icon: Container(
                margin: const EdgeInsets.only(left: 10.0),
                child: SVGStringBuilder(
                  image: 'assets/img/logo-primary.svg',
                ),
              ),
            ),
            leadingWidth: 100.0,
            toolbarHeight: const ig-publicAppBar().preferredSize.height,
            // expandedHeight: 174.0.w,
            pinned: true,
            elevation: 0.0,
            backgroundColor: ColorConfig.defaultWhite,
            // flexibleSpace: FlexibleSpaceBar(
            //   title: Container(
            //     padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 6.0),
            //     child: Row(
            //       children: [
            //         Container(
            //           width: 72.0.w,
            //           height: 72.0.w,
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(36.0.r),
            //             image: DecorationImage(
            //               image: AssetImage('assets/img/d_main_bg_poster.jpeg'),
            //               fit: BoxFit.cover,
            //               filterQuality: FilterQuality.high,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            actions: [
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Icon(Icons.abc, color: ColorConfig.defaultBlack),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 94.0.w,
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 6.0),
              color: ColorConfig.defaultWhite,
              child: Row(
                children: [
                  Container(
                    width: 72.0.w,
                    height: 72.0.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36.0.r),
                      image: const DecorationImage(
                        image: AssetImage('assets/img/d_main_bg_poster.jpeg'),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4.0),
                          child: CustomTextBuilder(
                            text: '아이디123',
                            fontColor: ColorConfig.defaultBlack,
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 16.0.w,
                              height: 16.0.w,
                              margin: const EdgeInsets.only(right: 4.0),
                              color: Colors.red,
                            ),
                            CustomTextBuilder(
                              text: '199,999',
                              fontColor: ColorConfig().primary(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // tabbar sliver header
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverAppBarDelegate(
              TabBar(
                controller: sliverTabBarController,
                isScrollable: false,
                labelColor: const Color(0xFF121016),
                labelStyle: TextStyle(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelColor: const Color(0xFF9393a7),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w800,
                ),
                indicator: const CustomTabIndicator(
                  color: Color(0xFF121016),
                  height: 4.0,
                  tabPosition: TabPosition.bottom,
                  horizontalPadding: 12.0,
                ),
                tabs: const [
                  Tab(
                    text: '전체',
                  ),
                  Tab(
                    text: '진행중',
                  ),
                  Tab(
                    text: '완료 3',
                  ),
                ],
              ),
              isSliverAppBarExpanded,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: const Color(0xFFe7e7f1),
                  child: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
                      child: Column(
                        children: List.generate(100, (index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: ColorConfig.defaultWhite,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8.0),
                                        child: CustomTextBuilder(
                                          text: '미션',
                                          fontColor: ColorConfig().primary(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: '원하는 날짜 선택하기',
                                        fontColor: const Color(0xFF121016),
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: [
                                      CustomTextBuilder(
                                        text: '1,500',
                                        fontColor: ColorConfig().primary(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      Container(
                                        width: 16.0.w,
                                        height: 16.0.w,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    Container(color: Colors.blue,),
                    Container(color: Colors.pink,),
                  ][currentTabIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
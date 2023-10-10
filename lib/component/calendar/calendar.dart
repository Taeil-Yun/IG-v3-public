library date_range_picker;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:ig-public_v3/costant/colors.dart';

/// 날짜 선택 대화 상자의 초기 표시 모드
///
/// 사용 가능한 연도 목록을 표시하거나
/// 처음에 [showDatePicker]를 호출하여 표시되는 대화 상자의 월별 달력.
enum DatePickerMode {
  day, // 월과 일을 선택하기 위한 날짜 선택기 UI를 표시
  year, // 연도를 선택하기 위한 날짜 선택기 UI를 표시
}

const double _kDatePickerHeaderPortraitHeight = 72.0;
const double _kDatePickerHeaderLandscapeWidth = 168.0;

const Duration _kMonthScrollDuration = Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // 토요일에 시작하는 31일 (month)

const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2); // 요일 헤더용과 월 헤더용

const double _kMonthPickerPortraitWidth = 330.0;
const double _kMonthPickerLandscapeWidth = 344.0;

const double _kDialogActionBarHeight = 52.0;
const double _kDatePickerLandscapeHeight =
    _kMaxDayPickerHeight + _kDialogActionBarHeight;

// 선택한 날짜를 큰 글꼴로 표시하고 연도와 일 모드를 전환
class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    Key? key,
    required this.selectedFirstDate,
    this.selectedLastDate,
    required this.mode,
    required this.onModeChanged,
    required this.orientation,
  })  : assert(selectedFirstDate != null),
        assert(mode != null),
        assert(orientation != null),
        super(key: key);

  final DateTime selectedFirstDate;
  final DateTime? selectedLastDate;
  final DatePickerMode mode;
  final ValueChanged<DatePickerMode> onModeChanged;
  final Orientation orientation;

  void _handleChangeMode(DatePickerMode value) {
    if (value != mode) onModeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final TextTheme headerTextTheme = themeData.primaryTextTheme;
    Color? dayColor;
    Color? yearColor;
    switch (themeData.primaryColorBrightness) {
      case Brightness.light:
        dayColor = mode == DatePickerMode.day ? Colors.black87 : Colors.black54;
        yearColor =
            mode == DatePickerMode.year ? Colors.black87 : Colors.black54;
        break;
      case Brightness.dark:
        dayColor = mode == DatePickerMode.day ? Colors.white : Colors.white70;
        yearColor = mode == DatePickerMode.year ? Colors.white : Colors.white70;
        break;
    }
    final TextStyle dayStyle =
        headerTextTheme.headline4!.copyWith(color: dayColor, height: 1.4);
    final TextStyle yearStyle =
        headerTextTheme.subtitle1!.copyWith(color: yearColor, height: 1.4);

    Color? backgroundColor;
    switch (themeData.brightness) {
      case Brightness.light:
        backgroundColor = themeData.primaryColor;
        break;
      case Brightness.dark:
        backgroundColor = themeData.backgroundColor;
        break;
    }

    double? width;
    double? height;
    EdgeInsets? padding;
    switch (orientation) {
      case Orientation.portrait:
        width = _kMonthPickerPortraitWidth;
        height = _kDatePickerHeaderPortraitHeight;
        padding = const EdgeInsets.symmetric(horizontal: 8.0);
        break;
      case Orientation.landscape:
        height = _kDatePickerLandscapeHeight;
        width = _kDatePickerHeaderLandscapeWidth;
        padding = const EdgeInsets.all(8.0);
        break;
    }
    Widget renderYearButton(date) {
      return IgnorePointer(
        ignoring: mode != DatePickerMode.day,
        ignoringSemantics: false,
        child: _DateHeaderButton(
          color: backgroundColor,
          onTap: Feedback.wrapForTap(
              () => _handleChangeMode(DatePickerMode.year), context),
          child: Semantics(
            selected: mode == DatePickerMode.year,
            child: Text(localizations.formatYear(date), style: yearStyle),
          ),
        ),
      );
    }

    Widget renderDayButton(date) {
      return IgnorePointer(
        ignoring: mode == DatePickerMode.day,
        ignoringSemantics: false,
        child: _DateHeaderButton(
          color: backgroundColor,
          onTap: Feedback.wrapForTap(
              () => _handleChangeMode(DatePickerMode.day), context),
          child: Semantics(
            selected: mode == DatePickerMode.day,
            child: Text(
              localizations.formatMediumDate(date),
              style: dayStyle,
              textScaleFactor: 0.5,
            ),
          ),
        ),
      );
    }

    final Widget startHeader = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        renderYearButton(selectedFirstDate),
        renderDayButton(selectedFirstDate),
      ],
    );
    final Widget endHeader = selectedLastDate != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              renderYearButton(selectedLastDate),
              renderDayButton(selectedLastDate),
            ],
          )
        : Container();

    return Container(
      width: width,
      height: height,
      padding: padding,
      color: backgroundColor,
      child: orientation == Orientation.portrait
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [startHeader, endHeader],
            )
          : Column(
              children: [
                SizedBox(
                  width: width,
                  child: startHeader,
                ),
                SizedBox(
                  width: width,
                  child: endHeader,
                ),
              ],
            ),
    );
  }
}

class _DateHeaderButton extends StatelessWidget {
  const _DateHeaderButton({
    Key? key,
    this.onTap,
    this.color,
    this.child,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      type: MaterialType.button,
      color: color,
      child: InkWell(
        borderRadius: kMaterialEdges[MaterialType.button],
        highlightColor: theme.highlightColor,
        splashColor: theme.splashColor,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(_kDayPickerRowHeight,
        constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1));
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _kDayPickerGridDelegate = _DayPickerGridDelegate();

/// 주어진 달의 날짜를 표시하고 날짜를 선택가능
///
/// 날짜는 각 날짜에 대해 하나의 열이 있는 직사각형 그리드에 정렬
///
/// 요일 선택 위젯은 거의 직접 사용X 대신 [showDatePicker]를 (날짜 선택 대화 상자를 생성) 사용
class DayPicker extends StatefulWidget {
  /// 요일 선택기를 생성
  ///
  /// 거의 직접 사용X 대신 [MonthPicker]의 일부로 사용
  DayPicker({
    Key? key,
    required this.selectedFirstDate,
    this.selectedLastDate,
    required this.currentDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.displayedMonth,
    this.selectableDayPredicate,
  })  : assert(selectedFirstDate != null),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!selectedFirstDate.isBefore(firstDate) &&
            (selectedLastDate == null || !selectedLastDate.isAfter(lastDate))),
        assert(selectedLastDate == null ||
            !selectedLastDate.isBefore(selectedFirstDate)),
        super(key: key);

  /// 현재 선택된 날짜
  ///
  /// 이 날짜는 date_picker에서 강조 표시
  final DateTime selectedFirstDate;
  final DateTime? selectedLastDate;

  /// date_picker가 표시되는 시점의 현재 날짜
  final DateTime currentDate;

  /// 사용자가 요일을 선택하면 호출
  final ValueChanged<List<DateTime?>> onChanged;

  /// 사용자가 선택할 수 있는 가장 빠른 날짜
  final DateTime firstDate;

  /// 사용자가 선택할 수 있는 마지막 날짜
  final DateTime lastDate;

  /// date_picker에 의해 날짜가 표시되는 월
  final DateTime displayedMonth;

  /// 선택 가능한 날짜를 사용자가 커스텀하기 위해 선택가능한 요일 서술
  final SelectableDayPredicate? selectableDayPredicate;

  static const List<int> _daysInMonth = <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  /// 역산에 따라 한 달의 일 수를 반환
  /// 그레고리 언 달력
  ///
  /// 그레고리력 개혁에 의해 도입된 윤년 논리를 적용
  /// 1582년도 이전의 날짜에 대해서는 유효한 결과를 제공 X
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) return 29;
      return 28;
    }
    return _daysInMonth[month - 1];
  }

  @override
  State<DayPicker> createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPicker> {
  bool useDateRange = false;

  /// 축약된 요일을 표시하는 위젯을 빌드 첫 번째 위젯은
  /// 반환된 목록은 현재 로케일의 첫 번째 요일에 해당
  ///
  /// ex)
  /// ┌ 일요일은 미국의 첫 번째 요일(en_US)
  /// |
  /// S M T W T F S <-- 반환된 목록에는 이러한 위젯이 포함
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ 하지만 영국은 월요일(ko_KR)
  /// |
  /// M T W T F S S <-- 반환된 목록에는 이러한 위젯이 포함
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  List<Widget> _getDayHeaders(
      TextStyle? headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) break;
    }
    return result;
  }

  /// 해당 주의 첫 번째 날부터 시작하는 오프셋을 계산
  /// [월요일]에 해당
  ///
  /// 미국 달력
  /// ex) 2017년 9월 1일은 달력에서 금요일에 해당
  ///
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  ///
  /// 월의 첫 번째 날에 대한 오프셋은 선행 공백의 수
  /// 달력에서 5
  ///
  /// 유럽 달력
  /// 주의 첫 번째 요일이 일요일이 아니라 월요일
  ///
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  ///
  /// 따라서 오프셋은 5가 아니라 4
  ///
  /// - [DateTime.weekday]는 요일에 대한 인덱스를 1 제공
  /// 월요일에 떨어진다.
  /// - [MaterialLocalizations.firstDayOfWeekIndex]는 0부터 시작하는 인덱스를 제공
  /// [MaterialLocalizations.narrowWeekdays] 목록에 추가
  /// - [MaterialLocalizations.narrowWeekdays] 목록은 지역화된 이름을 제공
  /// 일요일로 시작하여 토요일로 끝남
  int _computeFirstDayOffset(
      int year, int month, MaterialLocalizations localizations) {
    // 0부터 시작하는 요일, 0은 월요일
    final int weekdayFromMonday = DateTime(year, month).weekday - 1;
    // 0부터 시작하는 요일, 0은 일요일
    final int firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday는 월요일 기반으로 다시 계산
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // 달력에 나타나는 첫 번째 요일 사이의 일 수, 해당 월의 1일에 해당하는 날짜
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;
    final int daysInMonth = DayPicker.getDaysInMonth(year, month);
    final int firstDayOffset =
        _computeFirstDayOffset(year, month, localizations);
    final List<Widget> labels = <Widget>[];

    labels.addAll(_getDayHeaders(themeData.textTheme.caption, localizations));

    for (int i = 0; true; i += 1) {
      // 1부터 시작하는 날짜, ex) 1월의 경우 1-31, 2월의 경우 1-29 (윤년)
      final int day = i - firstDayOffset + 1;

      if (day > daysInMonth) break;

      if (day < 1) {
        labels.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(widget.firstDate) ||
            (widget.selectableDayPredicate != null &&
                !widget.selectableDayPredicate!(dayToBuild));
        BoxDecoration? decoration;
        TextStyle? itemStyle = themeData.textTheme.bodyText2;
        final bool isSelectedFirstDay = widget.selectedFirstDate.year == year &&
            widget.selectedFirstDate.month == month &&
            widget.selectedFirstDate.day == day;
        final bool? isSelectedLastDay = widget.selectedLastDate != null
            ? (widget.selectedLastDate!.year == year &&
                widget.selectedLastDate!.month == month &&
                widget.selectedLastDate!.day == day)
            : null;
        final bool? isInRange = widget.selectedLastDate != null
            ? (dayToBuild.isBefore(widget.selectedLastDate!) &&
                dayToBuild.isAfter(widget.selectedFirstDate))
            : null;
        if (isSelectedFirstDay &&
            (isSelectedLastDay == null || isSelectedLastDay)) {
          itemStyle = TextStyle(
            color: ColorConfig().primary(),
          );
          decoration = BoxDecoration(
            color: ColorConfig().primaryLight(),
            shape: BoxShape.circle,
          );
        } else if (isSelectedFirstDay) {
          // 선택한 요일은 background 표시와 대조되는 텍스트 색
          itemStyle = TextStyle(color: ColorConfig().primary());
          decoration = BoxDecoration(
            color: ColorConfig().primaryLight(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50.0),
              bottomLeft: Radius.circular(50.0),
            ),
          );
        } else if (isSelectedLastDay != null && isSelectedLastDay) {
          itemStyle = TextStyle(color: ColorConfig().primary());
          decoration = BoxDecoration(
            color: ColorConfig().primaryLight(),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(50.0),
              bottomRight: Radius.circular(50.0),
            ),
          );
        } else if (isInRange != null && isInRange) {
          itemStyle = TextStyle(color: ColorConfig().primary());
          decoration = BoxDecoration(
            color: ColorConfig().primaryLight(),
            shape: BoxShape.rectangle,
          );
        } else if (disabled) {
          itemStyle = themeData.textTheme.bodyText2!
              .copyWith(color: themeData.disabledColor);
        } else if (widget.currentDate.year == year &&
            widget.currentDate.month == month &&
            widget.currentDate.day == day) {
          // 현재 날짜는 다른 텍스트 색
          itemStyle = TextStyle(
            color: ColorConfig().primary(),
          );
        }

        Widget dayWidget = Container(
          margin: const EdgeInsets.symmetric(vertical: 3.0),
          decoration: decoration,
          child: Center(
            child: Semantics(
              // 우리는 날짜와 관계없이 월의 날짜를 먼저 말하기를 원함
              // 로케일별 기본 설정 또는 TextDirection
              // 접근성 사용자는
              // 그들이 보고 있는 날짜의 나머지 날짜 이전의 날짜
              // 해당 월의 일 그렇게 하기 위해 우리는 월의 일을 앞에 붙입니다.
              // 형식이 지정된 전체 날짜
              label:
                  '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedFirstDay ||
                  isSelectedLastDay != null && isSelectedLastDay,
              child: ExcludeSemantics(
                child: Text(localizations.formatDecimal(day), style: itemStyle),
              ),
            ),
          ),
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              DateTime? first, last;
              if (widget.selectedLastDate != null) {
                first = dayToBuild;
                last = null;
              } else {
                if (dayToBuild.compareTo(widget.selectedFirstDate) <= 0) {
                  first = dayToBuild;
                  last = widget.selectedFirstDate;
                } else {
                  first = widget.selectedFirstDate;
                  last = dayToBuild;
                }
              }
              widget.onChanged([first, last]);
            },
            child: dayWidget,
          );
        }

        labels.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 85.0,
                height: _kDayPickerRowHeight,
                padding: const EdgeInsets.only(top: 2.0),
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: ExcludeSemantics(
                    child: Text(
                      localizations.formatMonthYear(widget.displayedMonth),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Text(
                      '기간',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // ig-publicSwitch(
                    //   type: SwitchType.cupertino,
                    //   value: useDateRange,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       useDateRange = value;
                    //     });
                    //   },
                    //   activeColor: ig-publicColors.black1,
                    //   trackColor: ig-publicColors.backgroundGray1,
                    //   thumbColor: ig-publicColors.defaultWhite,
                    // ),
                  ],
                ),
              ),
            ],
          ),
          // 달력(요일) 부분
          Flexible(
            child: GridView.custom(
              physics: const ClampingScrollPhysics(),
              gridDelegate: _kDayPickerGridDelegate,
              childrenDelegate:
                  SliverChildListDelegate(labels, addRepaintBoundaries: false),
            ),
          ),
        ],
      ),
    );
  }
}

/// 월 선택을 허용하는 스크롤 가능한 월 리스트
///
/// 각 월에 대해 하나의 열이 있는 직사각형 그리드에 날짜를 표시
/// 요일
///
/// [MonthPicker] 위젯은 거의 직접 사용X 대신 [showDatePicker] (날짜 선택 대화 상자)를 사용
class MonthPicker extends StatefulWidget {
  /// [MonthPicker]를 생성
  ///
  /// 거의 직접 사용X 대신 [showDatePicker]로 사용
  MonthPicker({
    Key? key,
    required this.selectedFirstDate,
    this.selectedLastDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.selectableDayPredicate,
  })  : assert(selectedFirstDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!selectedFirstDate.isBefore(firstDate) &&
            (selectedLastDate == null || !selectedLastDate.isAfter(lastDate))),
        assert(selectedLastDate == null ||
            !selectedLastDate.isBefore(selectedFirstDate)),
        super(key: key);

  /// 현재 선택된 날짜, 강조 표시
  final DateTime selectedFirstDate;
  final DateTime? selectedLastDate;

  /// 사용자가 월을 선택할 때 호출
  final ValueChanged<List<DateTime?>> onChanged;

  /// 사용자가 선택할 수 있는 가장 빠른 날짜
  final DateTime firstDate;

  /// 사용자가 선택할 수 있는 마지막 날짜
  final DateTime lastDate;

  /// 선택 가능한 날짜를 커스텀하기위해 선택가능한 요일 서술
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // 초기에 미리 선택된 날짜를 표시
    int monthPage;
    if (widget.selectedLastDate == null) {
      monthPage = _monthDelta(widget.firstDate, widget.selectedFirstDate);
    } else {
      monthPage = _monthDelta(widget.firstDate, widget.selectedLastDate!);
    }
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();

    // 페이드 애니메이션 설정
    _chevronOpacityController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _chevronOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _chevronOpacityController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLastDate == null) {
      final int monthPage =
          _monthDelta(widget.firstDate, widget.selectedFirstDate);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    } else if (oldWidget.selectedLastDate == null ||
        widget.selectedLastDate != oldWidget.selectedLastDate) {
      final int monthPage =
          _monthDelta(widget.firstDate, widget.selectedLastDate!);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }
  }

  late MaterialLocalizations localizations;
  late TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
  }

  late DateTime _todayDate;
  late DateTime _currentDisplayedMonthDate;
  Timer? _timer;
  PageController? _dayPickerController;
  late AnimationController _chevronOpacityController;
  late Animation<double> _chevronOpacityAnimation;

  void _updateCurrentDate() {
    _todayDate = DateTime.now();
    final DateTime tomorrow =
        DateTime(_todayDate.year, _todayDate.month, _todayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow += const Duration(seconds: 1); // 놓치지않게 반올림
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  static int _monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// 월이 잘린 날짜에 월을 추가
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month = _addMonthsToMonthDate(widget.firstDate, index);
    return DayPicker(
      key: ValueKey<DateTime>(month),
      selectedFirstDate: widget.selectedFirstDate,
      selectedLastDate: widget.selectedLastDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_nextMonthDate), textDirection);
      _dayPickerController!
          .nextPage(duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_previousMonthDate), textDirection);
      _dayPickerController!
          .previousPage(duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  /// 허용 가능한 가장 빠른 달이 표시되면 True
  bool get _isDisplayingFirstMonth {
    return !_currentDisplayedMonthDate
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  /// 허용 가능한 최신 월이 표시되면 True
  bool get _isDisplayingLastMonth {
    return !_currentDisplayedMonthDate
        .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  late DateTime _previousMonthDate;
  late DateTime _nextMonthDate;

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kMonthPickerPortraitWidth,
      height: _kMaxDayPickerHeight,
      child: Stack(
        children: <Widget>[
          Semantics(
            sortKey: _MonthPickerSortKey.calendar,
            child: NotificationListener<ScrollStartNotification>(
              onNotification: (_) {
                _chevronOpacityController.forward();
                return false;
              },
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  _chevronOpacityController.reverse();
                  return false;
                },
                child: PageView.builder(
                  key: ValueKey<DateTime?>(widget.selectedFirstDate == null
                      ? widget.selectedFirstDate
                      : widget.selectedLastDate),
                  controller: _dayPickerController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _monthDelta(widget.firstDate, widget.lastDate) + 1,
                  itemBuilder: _buildItems,
                  // onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),

          /// 전 달로 이동
          PositionedDirectional(
            top: 0.0,
            start: 0.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.previousMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: _isDisplayingFirstMonth
                      ? null
                      : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
              ),
            ),
          ),

          /// 다음 달로 이동
          PositionedDirectional(
            top: 0.0,
            start: 120.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.nextMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: _isDisplayingLastMonth
                      ? null
                      : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    super.dispose();
  }
}

// 월 내 최상위 위젯의 시맨틱 순회 순서를 정의, picker
class _MonthPickerSortKey extends OrdinalSortKey {
  static const _MonthPickerSortKey previousMonth = _MonthPickerSortKey(1.0);
  static const _MonthPickerSortKey nextMonth = _MonthPickerSortKey(2.0);
  static const _MonthPickerSortKey calendar = _MonthPickerSortKey(3.0);

  const _MonthPickerSortKey(double order) : super(order);
}

/// 연도를 선택할 수 있도록 스크롤 가능한 연도 리스트
///
/// [YearPicker] 위젯은 거의 직접 사용X 대신 [showDatePicker]를 (날짜 선택 대화 상자) 사용
class YearPicker extends StatefulWidget {
  /// YearPicker를 생성
  ///
  /// [selectedDate] 및 [onChanged] 인수는 null이 아니어야 함
  /// [lastDate]는 [firstDate] 이후이어야 함
  ///
  /// 거의 직접 사용X 대신 [showDatePicker] 사용
  YearPicker({
    Key? key,
    required this.selectedFirstDate,
    this.selectedLastDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
  })  : assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// 현재 선택된 날짜
  ///
  /// 이 날짜는 date_picker에서 강조 표시
  final DateTime selectedFirstDate;
  final DateTime? selectedLastDate;

  /// 사용자가 연도룰 선택할 때
  final ValueChanged<List<DateTime?>> onChanged;

  /// 사용자가 선택할 수 있는 가장 빠른 날짜
  final DateTime firstDate;

  /// 사용자가 선택할 수 있는 가장 늦은 날짜
  final DateTime lastDate;

  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  static const double _itemExtent = 50.0;
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();
    int offset;
    if (widget.selectedLastDate != null) {
      offset = widget.lastDate.year - widget.selectedLastDate!.year;
    } else {
      offset = widget.selectedFirstDate.year - widget.firstDate.year;
    }
    scrollController = ScrollController(
      // 초기 스크롤 위치를 현재 선택된 날짜의 연도로 이동
      initialScrollOffset: offset * _itemExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle? style = themeData.textTheme.bodyText2;
    return ListView.builder(
      controller: scrollController,
      itemExtent: _itemExtent,
      itemCount: widget.lastDate.year - widget.firstDate.year + 1,
      itemBuilder: (BuildContext context, int index) {
        final int year = widget.firstDate.year + index;
        final bool isSelected = year == widget.selectedFirstDate.year ||
            (widget.selectedLastDate != null &&
                year == widget.selectedLastDate!.year);
        final TextStyle? itemStyle = isSelected
            ? themeData.textTheme.headline5!
                .copyWith(color: themeData.colorScheme.secondary)
            : style;
        return InkWell(
          key: ValueKey<int>(year),
          onTap: () {
            List<DateTime?> changes;
            if (widget.selectedLastDate == null) {
              DateTime newDate = DateTime(year, widget.selectedFirstDate.month,
                  widget.selectedFirstDate.day);
              changes = [newDate, newDate];
            } else {
              changes = [
                DateTime(year, widget.selectedFirstDate.month,
                    widget.selectedFirstDate.day),
                null
              ];
            }
            widget.onChanged(changes);
          },
          child: Center(
            child: Semantics(
              selected: isSelected,
              child: Text(year.toString(), style: itemStyle),
            ),
          ),
        );
      },
    );
  }
}

class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({
    Key? key,
    this.initialFirstDate,
    this.initialLastDate,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.initialDatePickerMode,
    this.applyPress,
    this.resetPress,
  }) : super(key: key);

  final DateTime? initialFirstDate;
  final DateTime? initialLastDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final DatePickerMode? initialDatePickerMode;
  final Function()? resetPress;
  final Function()? applyPress;

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  @override
  void initState() {
    super.initState();
    _selectedFirstDate = widget.initialFirstDate;
    _selectedLastDate = widget.initialLastDate;
    _mode = widget.initialDatePickerMode;
  }

  bool _announcedInitialDate = false;

  late MaterialLocalizations localizations;
  late TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        localizations.formatFullDate(_selectedFirstDate!),
        textDirection,
      );
      if (_selectedLastDate != null) {
        SemanticsService.announce(
          localizations.formatFullDate(_selectedLastDate!),
          textDirection,
        );
      }
    }
  }

  DateTime? _selectedFirstDate;
  DateTime? _selectedLastDate;
  DatePickerMode? _mode;
  final GlobalKey _pickerKey = GlobalKey();

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
        break;
      case TargetPlatform.linux:
        break;
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.windows:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(
            localizations.formatMonthYear(_selectedFirstDate!), textDirection);
        if (_selectedLastDate != null) {
          SemanticsService.announce(
              localizations.formatMonthYear(_selectedLastDate!), textDirection);
        }
      } else {
        SemanticsService.announce(
            localizations.formatYear(_selectedFirstDate!), textDirection);
        if (_selectedLastDate != null) {
          SemanticsService.announce(
              localizations.formatYear(_selectedLastDate!), textDirection);
        }
      }
    });
  }

  void _handleYearChanged(List<DateTime?> changes) {
    assert(changes.length == 2);
    _vibrate();
    setState(() {
      _mode = DatePickerMode.day;
      _selectedFirstDate = changes[0];
      _selectedLastDate = changes[1];
    });
  }

  void _handleDayChanged(List<DateTime?> changes) {
    assert(changes.length == 2);
    _vibrate();
    setState(() {
      _selectedFirstDate = changes[0];
      _selectedLastDate = changes[1];
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    List<DateTime> result = [];
    if (_selectedFirstDate != null) {
      result.add(_selectedFirstDate!);
      if (_selectedLastDate != null) {
        result.add(_selectedLastDate!);
      }
    }
    Navigator.pop(context, result);
  }

  Widget? _buildPicker() {
    assert(_mode != null);
    switch (_mode) {
      case DatePickerMode.day:
        return MonthPicker(
          key: _pickerKey,
          selectedFirstDate: _selectedFirstDate!,
          selectedLastDate: _selectedLastDate,
          onChanged: _handleDayChanged,
          firstDate: widget.firstDate!,
          lastDate: widget.lastDate!,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return YearPicker(
          key: _pickerKey,
          selectedFirstDate: _selectedFirstDate!,
          selectedLastDate: _selectedLastDate,
          onChanged: _handleYearChanged,
          firstDate: widget.firstDate!,
          lastDate: widget.lastDate!,
        );
      default:
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget picker = Flexible(
      child: SizedBox(
        height: _kMaxDayPickerHeight,
        child: _buildPicker(),
      ),
    );
    final Widget actions = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: ColorConfig.defaultWhite,
        boxShadow: [
          BoxShadow(
              color: ColorConfig.defaultBlack.withOpacity(0.06),
              offset: const Offset(0.0, -0.2),
              blurRadius: 4,
              spreadRadius: 1)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: (_kMonthPickerPortraitWidth / 2) - 28,
            height: 54.0,
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: widget.resetPress ?? _handleCancel,
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1.0,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: const Text(
                '리셋',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(
            width: (_kMonthPickerPortraitWidth / 2) - 28,
            height: 54.0,
            child: TextButton(
              onPressed: widget.applyPress ?? _handleOk,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                textStyle: MaterialStateProperty.all(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: const Text(
                '필터',
                style: TextStyle(
                  color: ColorConfig.defaultWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    final Dialog dialog = Dialog(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          // ignore: unnecessary_null_comparison
          assert(orientation != null);
          // final Widget header = _DatePickerHeader(
          //   selectedFirstDate: _selectedFirstDate!,
          //   selectedLastDate: _selectedLastDate,
          //   mode: _mode!,
          //   onModeChanged: _handleModeChanged,
          //   orientation: orientation,
          // );
          switch (orientation) {
            case Orientation.portrait:
              return SizedBox(
                width: _kMonthPickerPortraitWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // header,
                    Container(
                      color: ColorConfig.defaultWhite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          picker,
                          actions,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            case Orientation.landscape:
              return SizedBox(
                height: _kDatePickerLandscapeHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // header,
                    Flexible(
                      child: Container(
                        width: _kMonthPickerLandscapeWidth,
                        color: theme.dialogBackgroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[picker, actions],
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }
}

/// 활성화된 날짜 선택에 대한 날짜를 예측하기 위한 서명
///
/// [showDatePicker]를 참조
// typedef bool SelectableDayPredicate(DateTime day);
typedef SelectableDayPredicate = bool Function(DateTime day);

/// 머테리얼 디자인 날짜 선택기가 포함된 대화 상자를 표시
///
/// 반환된 [Future]는 다음과 같은 경우 사용자가 선택한 날짜로 확인
/// 사용자가 대화 상자를 닫습니다. 사용자가 대화를 취소하면 null이 반환
///
/// 선택적인 [selectableDayPredicate] 함수를 사용자 정의하기 위해 전달가능
/// 선택을 활성화할 요일. 제공되는 경우 해당 날짜만
/// [selectableDayPredicate]가 true를 반환하면 선택 가능
///
/// 선택적 [initialDatePickerMode] 인수를 사용하여
/// 연도 또는 월+일 선택기 모드에서 처음에 date_picker
/// 기본 월+일이며 null이 아니어야 함
///
/// 선택적 [locale] 인수를 사용하여 날짜의 로케일을 설정가능
/// 선택기. 기본값은 [Localizations]에서 제공하는 주변 로케일
///
/// 선택적 [textDirection] 인수를 사용하여 텍스트 방향을 설정가능
/// (RTL 또는 LTR) 날짜 선택기. 주변 텍스트 방향으로 기본 설정
/// [방향성]에서 제공합니다. [locale]과 [textDirection]이 둘 다 아닌 경우
/// null, [textDirection]은 [locale]에 대해 선택된 방향을 재정의
///
/// `context` 인수는 [showDialog]에 전달
Future<List<DateTime>?> showDatePicker({
  required BuildContext context,
  required DateTime initialFirstDate,
  required DateTime initialLastDate,
  required DateTime firstDate,
  required DateTime lastDate,
  final Function()? resetPress,
  final Function()? applyPress,
  SelectableDayPredicate? selectableDayPredicate,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  Locale? locale,
  TextDirection? textDirection,
}) async {
  assert(!initialFirstDate.isBefore(firstDate),
      'initialDate must be on or after firstDate');
  assert(!initialLastDate.isAfter(lastDate),
      'initialDate must be on or before lastDate');
  assert(!initialFirstDate.isAfter(initialLastDate),
      'initialFirstDate must be on or before initialLastDate');
  assert(
      !firstDate.isAfter(lastDate), 'lastDate must be on or after firstDate');
  assert(
      selectableDayPredicate == null ||
          selectableDayPredicate(initialFirstDate) ||
          selectableDayPredicate(initialLastDate),
      'Provided initialDate must satisfy provided selectableDayPredicate');
  // ignore: unnecessary_null_comparison
  assert(
      initialDatePickerMode != null, 'initialDatePickerMode must not be null');

  Widget child = _DatePickerDialog(
    initialFirstDate: initialFirstDate,
    initialLastDate: initialLastDate,
    firstDate: firstDate,
    lastDate: lastDate,
    selectableDayPredicate: selectableDayPredicate,
    initialDatePickerMode: initialDatePickerMode,
    applyPress: applyPress,
    resetPress: resetPress,
  );

  if (textDirection != null) {
    child = Directionality(
      textDirection: textDirection,
      child: child,
    );
  }

  if (locale != null) {
    child = Localizations.override(
      context: context,
      locale: locale,
      child: child,
    );
  }

  return await showDialog<List<DateTime>>(
    context: context,
    builder: (BuildContext context) => child,
  );
}

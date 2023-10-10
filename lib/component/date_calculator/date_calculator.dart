import 'package:intl/intl.dart';

///
/// 날짜 계산기
///
class DateCalculatorWrapper {
  ///
  /// 요일 또는 시간 계산기
  ///
  String daysCalculator(String uploadDate) {
    // 현재 시간
    DateTime today = DateTime.now();

    // 결과값
    String result = '';

    // 현재날짜 - 업로드 날짜
    int days = int.parse(today.difference(DateTime.parse(uploadDate).toLocal()).inDays.toString());

    if (days > 7) {  // 계산된 일수가 7일을 초과할 때
      result = DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(uploadDate).toLocal());
    } else if (days > 0) {  // 계산된 일수가 1~7일 사이일 때
      result = '$days일전';
    } else {  // 계산된 일수가 하루 미만일 때
      // 현재시간 - 업로드 시간
      int hours = int.parse(today.difference(DateTime.parse(uploadDate).toLocal()).inHours.toString());

      if (hours > 0) {  // 계산된 시간이 1~23시간 사이일 때
        result = '$hours시간전';
      } else {  // 계산된 시간이 1시간 미만일 때
        // 현재시간 - 업로드 분
        int minutes = int.parse(today.difference(DateTime.parse(uploadDate).toLocal()).inMinutes.toString());

        if (minutes > 0) {  // 계산된 분이 1~59분 사이일 때
          result = '$minutes분전';
        } else {  // 1분 미만일 때
          result = '방금';
        }
      }
    }
    
    return result;
  }

  ///
  /// 종료일까지 남은일수 계산기
  /// ex)
  ///   - 오늘 = 2022/06/07
  ///   - 종료일 = 2022/06/12
  /// <br/>
  ///   종료 예정일 - 현재 시간 = 남은기간
  ///
  expiredDate(String date) {
    // 현재시간
    DateTime now = DateTime.now();

    // 현재날짜 - 종료날짜
    int expDays = int.parse(DateTime.parse(date).toLocal().difference(now).inDays.toString());

    // 시간
    int expHours = int.parse(DateTime.parse(date).toLocal().difference(now).inHours.toString());

    if (expHours < 24) {
      expDays = 0;
    }

    return expDays;
  }
  
  ///
  /// 종료일까지 남은일수의 시간 계산기
  /// ex)
  ///   - 오늘 = 2022/06/07 12:00:00
  ///   - 종료일 = 2022/06/12 18:00:00
  /// <br/>
  ///   종료 예정시간 - 현재 시간 = 남은시간
  ///
  expiredHoursForDate(String date) {
    // 현재시간
    DateTime now = DateTime.now();

    // 현재날짜 - 종료날짜
    int expDays = int.parse(DateTime.parse(date).toLocal().difference(now).inHours.toString());
    int exps = int.parse(DateTime.parse(date).toLocal().difference(now).inDays.toString());

    if (expDays <= 0) {
      expDays = 0;
    } else if (expDays >= 24 * exps) {
      expDays = expDays ~/ (exps + 1);
    }

    return expDays;
  }

  ///
  /// 종료일까지 남은일수의 분 계산기
  /// ex)
  ///   - 오늘 = 2022/06/07 12:00:00
  ///   - 종료일 = 2022/06/12 18:30:00
  /// <br/>
  ///   종료 예정시간 - 현재 시간 = 남은시간
  ///
  expiredMinutesForDate(String date) {
    // 현재시간
    DateTime now = DateTime.now();

    // 현재날짜 - 종료날짜
    int expDays = int.parse(DateTime.parse(date).toLocal().difference(now).inMinutes.toString());

    if (expDays <= 0) {
      expDays = 0;
    }

    return expDays;
  }
  
  calculatorAMPM(String date, {bool? useAMPM}) {
    String ampm = '';

    if (DateTime.parse(date).toLocal().hour < 12) {
      ampm = '오전 ${DateTime.parse(date).toLocal().hour}시 ${DateTime.parse(date).toLocal().minute}분';

      if (DateTime.parse(date).toLocal().hour <= 0) {
        ampm = '오전 ${DateTime.parse(date).toLocal().hour + 12}시 ${DateTime.parse(date).toLocal().minute}분';
      }
    } else {
      ampm = '오후 ${DateTime.parse(date).toLocal().hour - 12}시 ${DateTime.parse(date).toLocal().minute}분';
    }

    if(useAMPM == true) {
      if (DateTime.parse(date).toLocal().hour < 12) {
        ampm = '${DateTime.parse(date).toLocal().hour}:${DateTime.parse(date).toLocal().minute} AM';

        if (DateTime.parse(date).toLocal().hour <= 0) {
          ampm = '${DateTime.parse(date).toLocal().hour + 12}:${DateTime.parse(date).toLocal().minute} AM';
        }
      } else {
        if (DateTime.parse(date).toLocal().hour - 12 < 10 && DateTime.parse(date).toLocal().minute < 10) {
          ampm = '0${DateTime.parse(date).toLocal().hour - 12}:0${DateTime.parse(date).toLocal().minute} PM';
        } else if (DateTime.parse(date).toLocal().hour - 12 >= 10 && DateTime.parse(date).toLocal().minute < 10) {
          ampm = '${DateTime.parse(date).toLocal().hour - 12}:0${DateTime.parse(date).toLocal().minute} PM';
        } else if (DateTime.parse(date).toLocal().hour - 12 < 10 && DateTime.parse(date).toLocal().minute >= 10) {
          ampm = '0${DateTime.parse(date).toLocal().hour - 12}:${DateTime.parse(date).toLocal().minute} PM';
        } else {
          ampm = '${DateTime.parse(date).toLocal().hour - 12}:${DateTime.parse(date).toLocal().minute} PM';
        }
      }
    }

    return ampm;
  }

  String deadlineCalculator(String deadline) {
    // 현재 시간
    DateTime today = DateTime.now();

    // 결과값
    String result = '';

    // 마감기간 - 현재날짜
    int days = int.parse(DateTime.parse(deadline).toLocal().difference(today.toLocal()).inDays.toString());

    if (days <= 7 && days > 0) {  // 계산된 일수가 7일 이하일때
      result = '$days일 남음';
    } else if (days <= 0) {  // 계산된 일수가 하루 이하일 때
      // 마감시간 - 현재시간
      int hours = int.parse(DateTime.parse(deadline).toLocal().difference(today.toLocal()).inHours.toString());

      if (hours > 0) {  // 계산된 시간이 1~23시간 사이일 때
        result = '$hours시간 남음';
      } else {  // 계산된 시간이 1시간 미만일 때
        // 마감시간 - 현재시간
        int minutes = int.parse(DateTime.parse(deadline).toLocal().difference(today.toLocal()).inMinutes.toString());

        if (minutes > 0) {  // 계산된 분이 1~59분 사이일 때
          result = '$minutes분 남음';
        } else {  // 1분 미만일 때
          int seconds = int.parse(DateTime.parse(deadline).toLocal().difference(today.toLocal()).inSeconds.toString());

          if (minutes <= 0 && seconds <= 0) {
            result = '사용기간 종료';
          }
        }
      }
    } else {
      result = DateFormat('yy년 M월 d일까지').format(DateTime.parse(deadline).toLocal());
    }
    
    return result;
  }

  String endTimeCalculator(String endTime) {
    // 현재 날짜
    DateTime today = DateTime.now();
    // 현재 시간
    int nowHour = DateTime.now().hour;
    // 현재 분
    int nowMinute = DateTime.now().minute;

    // 결과값
    String result = '';

    // 종료날짜 - 현재날짜
    int days = int.parse(DateTime.parse(endTime).toLocal().difference(today.toLocal()).inDays.toString());
    // 종료시간 - 현재시간
    int hours = DateTime.parse(endTime).toLocal().hour - nowHour;
    // 종료 분 - 현재 분
    int minutes = DateTime.parse(endTime).toLocal().minute - nowMinute;

    if (DateTime.parse(endTime).toLocal().hour < nowHour) {
      hours = 24 + hours;
    }
    
    if (DateTime.parse(endTime).toLocal().minute < nowMinute) {
      minutes = 60 + minutes;
    }

    if (days == 0) {
      result = '$hours시간 $minutes분 남음';
    } else if (days == 0 && hours == 0) {
      result = '$minutes분 남음';
    } else {
      result = '$days일 $hours시간 $minutes분 남음';
    }

    return result;
  }
}
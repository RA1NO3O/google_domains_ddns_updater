import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  static String handleDateTimeString(String dateTime) {
    String nowTime =
        DateTime.now().toString().split('.')[0].replaceAll('-', '/');
    int nowYear = int.parse(nowTime.split(' ')[0].split('/')[0]);
    int nowMonth = int.parse(nowTime.split(' ')[0].split('/')[1]);
    int nowDay = int.parse(nowTime.split(' ')[0].split('/')[2]);
    int nowHour = int.parse(nowTime.split(' ')[1].split(':')[0]);
    int nowMinute = int.parse(nowTime.split(' ')[1].split(':')[1]);

    dateTime = dateTime.split('.')[0].replaceAll('-', '/');
    int oldYear = int.parse(dateTime.split(' ')[0].split('/')[0]);
    int oldMonth = int.parse(dateTime.split(' ')[0].split('/')[1]);
    int oldDay = int.parse(dateTime.split(' ')[0].split('/')[2]);
    int oldHour = int.parse(dateTime.split(' ')[1].split(':')[0]);
    int oldMinute = int.parse(dateTime.split(' ')[1].split(':')[1]);

    var now = DateTime(nowYear, nowMonth, nowDay, nowHour, nowMinute);
    var old = DateTime(oldYear, oldMonth, oldDay, oldHour, oldMinute);
    var difference = now.difference(old);
    if (difference.inDays > 1 && difference.inDays < 10) {
      return '${difference.inDays}天前';
    } else if (difference.inDays == 1) {
      return '昨天'.toString();
    } else if (difference.inHours >= 1 && difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 1 && difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inMinutes <= 1) {
      return '刚刚';
    } else if (difference.inDays >= 365) {
      return '${difference.inDays ~/ 365}年前';
    }
    return '$oldMonth月$oldDay日';
  }

  String get handle {
    String nowTime =
        DateTime.now().toString().split('.')[0].replaceAll('-', '/');
    int nowYear = int.parse(nowTime.split(' ')[0].split('/')[0]);
    int nowMonth = int.parse(nowTime.split(' ')[0].split('/')[1]);
    int nowDay = int.parse(nowTime.split(' ')[0].split('/')[2]);
    int nowHour = int.parse(nowTime.split(' ')[1].split(':')[0]);
    int nowMinute = int.parse(nowTime.split(' ')[1].split(':')[1]);

    var now = DateTime(nowYear, nowMonth, nowDay, nowHour, nowMinute);
    var difference = now.difference(this);
    if (difference.inDays > 1 && difference.inDays < 10) {
      return '${difference.inDays}天前';
    } else if (difference.inDays == 1) {
      return '昨天'.toString();
    } else if (difference.inHours >= 1 && difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 1 && difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inMinutes <= 1) {
      return '刚刚';
    } else if (difference.inDays >= 365) {
      return '${difference.inDays ~/ 365}年前';
    }
    return '$month月$day日';
  }
}

String convertBasicTimeFormat(String t) {
  var dt = DateTime.parse(t);
  var result = DateFormat.yMMMd('zh_CN').add_Hms().add_EEEE().format(dt);
  return result;
}

String convertBasicDateFormatString(String d) {
  var result = '';
  if (d != '' && d != 'null') {
    result = DateFormat.yMMMd('zh_CN').format(DateTime.parse(d));
  }
  return result;
}

String convertBasicDateFormat(DateTime d) =>
    DateFormat('yyyy-MM-dd HH:mm:ss').format(d);

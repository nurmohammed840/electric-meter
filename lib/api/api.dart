import 'dart:convert';
import 'package:http/http.dart' as http;

import 'customer.dart';
import 'date.dart';

const apiUrl = "https://prepaid.desco.org.bd/api/unified/customer";

class MeterNo {
  MeterNo({this.accountNo, this.meterNo});
  MeterNo.fromAccountNo(String account) : accountNo = account, meterNo = null;
  MeterNo.fromMeterNo(String meter) : meterNo = meter, accountNo = null;

  String? accountNo;
  String? meterNo;

  static MeterNo? from(String input) {
    if (input.length == 8) {
      return MeterNo.fromAccountNo(input);
    }
    if (input.length > 8) {
      return MeterNo.fromMeterNo(input);
    }
    return null;
  }

  String accountOrMeterNumber() {
    if (accountNo != null) {
      return accountNo!;
    }
    if (meterNo != null) {
      return meterNo!;
    }
    throw "unreachable";
  }

  @override
  String toString() {
    List<String> parts = [];
    if (accountNo != null) parts.add('accountNo=$accountNo');
    if (meterNo != null) parts.add('meterNo=$meterNo');
    return parts.join('&');
  }
}

Future<T> fetchJson<T>(
  String url,
  T Function(Map<String, dynamic>) fromJson,
) async {
  final res = await http.get(Uri.parse(url));

  // print(url);
  // print(res.body);

  if (res.statusCode == 200) {
    return fromJson(jsonDecode(res.body));
  } else {
    throw Exception('Failed to load data, status: ${res.statusCode}');
  }
}

Future<Response<Info>> getCustomerInfo(MeterNo meterInfo) async {
  final url = "$apiUrl/getCustomerInfo?$meterInfo";
  return fetchJson(url, parseResponse(Info.fromJson));
}

Future<Response<List<DailyConsumption>>> getDailyConsumptions(
  MeterNo meterInfo,
  Date from,
  Date to,
) async {
  final url =
      "$apiUrl/getCustomerDailyConsumption?$meterInfo&dateFrom=$from&dateTo=$to";

  return fetchJson(url, parseResponseMany(DailyConsumption.fromJson));
}

Future<Response<Balance>> getBalance(MeterNo meterInfo) async {
  final url = "$apiUrl/getBalance?$meterInfo";
  return fetchJson(url, parseResponse(Balance.fromJson));
}

Future<Response<List<RechargeReceipt>>> getRechargeHistorys(
  MeterNo meterInfo,
  Date from,
  Date to,
) async {
  final url = "$apiUrl/getRechargeHistory?$meterInfo&dateFrom=$from&dateTo=$to";
  return fetchJson(url, parseResponseMany(RechargeReceipt.fromJson));
}

Future<Response<List<MonthlyConsumption>>> getMonthlyConsumption(
  MeterNo meterInfo,
  Month from,
  Month to,
) async {
  final url =
      "$apiUrl/getCustomerMonthlyConsumption?$meterInfo&monthFrom=$from&monthTo=$to";

  return fetchJson(url, parseResponseMany(MonthlyConsumption.fromJson));
}

import 'dart:convert';

import 'package:desco_usage/types.dart';

import 'date.dart';

const prettyPrint = JsonEncoder.withIndent("  ");

Response<T> Function(Map<String, dynamic>) parseResponse<T>(
  T Function(Map<String, dynamic> json) fromJsonT,
) {
  return (json) => Response(
    code: json['code'],
    desc: json['desc'],
    data: json['data'] == null ? null : fromJsonT(json['data']),
  );
}

Response<List<T>> Function(Map<String, dynamic>) parseResponseMany<T>(
  T Function(Map<String, dynamic> json) fromJsonT,
) {
  return (json) => Response(
    code: json['code'],
    desc: json['desc'],
    data: json['data'] == null
        ? null
        : List.from(json["data"].map((v) => fromJsonT(v))),
  );
}

class Response<T> {
  Response({required this.code, required this.desc, this.data});

  final int code;
  final String desc;
  final T? data;

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'code': code,
      'desc': desc,
      'data': data == null ? null : toJsonT(data as T),
    };
  }

  T getData() {
    if (data == null) {
      throw desc;
    }
    return data!;
  }

  @override
  String toString() => 'Response(code: $code, desc: $desc, data: $data)';
}

class Info extends JsonSerializable {
  Info({
    this.accountNo,
    this.contactNo,
    this.customerName,
    this.feederName,
    this.installationAddress,
    this.installationDate,
    this.meterNo,
    this.phaseType,
    this.registerDate,
    this.sanctionLoad,
    this.tariffSolution,
    this.meterModel,
    this.transformer,
    this.sdName,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    accountNo: json["accountNo"],
    contactNo: json["contactNo"],
    customerName: json["customerName"],
    feederName: json["feederName"],
    installationAddress: json["installationAddress"],
    installationDate: Date.from(DateTime.parse(json["installationDate"])),
    meterNo: json["meterNo"],
    phaseType: json["phaseType"],
    registerDate: json["registerDate"],
    sanctionLoad: json["sanctionLoad"],
    tariffSolution: json["tariffSolution"],
    meterModel: json["meterModel"],
    transformer: json["transformer"],
    sdName: json["SDName"],
  );

  String? meterNo;
  String? customerName;
  String? tariffSolution;

  String? accountNo;
  String? contactNo;
  String? feederName;
  String? installationAddress;
  Date? installationDate;
  String? phaseType;
  dynamic registerDate;
  int? sanctionLoad;
  String? meterModel;
  String? transformer;
  String? sdName;

  @override
  Map<String, dynamic> toJson() => {
    "accountNo": accountNo,
    "contactNo": contactNo,
    "customerName": customerName,
    "feederName": feederName,
    "installationAddress": installationAddress,
    "installationDate": installationDate.toString(),
    "meterNo": meterNo,
    "phaseType": phaseType,
    "registerDate": registerDate,
    "sanctionLoad": sanctionLoad,
    "tariffSolution": tariffSolution,
    "meterModel": meterModel,
    "transformer": transformer,
    "SDName": sdName,
  };
}

class DailyConsumption {
  DailyConsumption({
    required this.accountNo,
    required this.consumedTaka,
    required this.consumedUnit,
    required this.meterNo,
    required this.date,
    required this.sanctionLoad,
    required this.tariffSolution,
    this.installationAddress,
    this.phaseType,
    this.customerName,
    this.importReactiveEnergyIncrement,
  });

  factory DailyConsumption.fromJson(Map<String, dynamic> json) =>
      DailyConsumption(
        accountNo: json["accountNo"],
        consumedTaka: json["consumedTaka"]?.toDouble(),
        consumedUnit: json["consumedUnit"]?.toDouble(),
        customerName: json["customerName"],
        importReactiveEnergyIncrement: json["importReactiveEnergyIncrement"],
        installationAddress: json["installationAddress"],
        meterNo: json["meterNo"],
        date: Date.from(DateTime.parse(json["date"])),
        phaseType: json["phaseType"],
        sanctionLoad: json["sanctionLoad"],
        tariffSolution: json["tariffSolution"],
      );

  String accountNo;
  String meterNo;

  double consumedTaka;
  double consumedUnit;

  Date date;
  int sanctionLoad;
  String tariffSolution;

  String? phaseType;
  String? customerName;
  dynamic importReactiveEnergyIncrement;
  String? installationAddress;

  Map<String, dynamic> toJson() => {
    "accountNo": accountNo,
    "consumedTaka": consumedTaka,
    "consumedUnit": consumedUnit,
    "customerName": customerName,
    "importReactiveEnergyIncrement": importReactiveEnergyIncrement,
    "installationAddress": installationAddress,
    "meterNo": meterNo,
    "date": date.toString(),
    "phaseType": phaseType,
    "sanctionLoad": sanctionLoad,
    "tariffSolution": tariffSolution,
  };

  @override
  String toString() {
    return prettyPrint.convert(toJson());
  }
}

class MonthlyConsumption {
  MonthlyConsumption({
    required this.accountNo,
    required this.meterNo,
    required this.consumedTaka,
    required this.consumedUnit,
    required this.customerName,
    required this.installationAddress,
    required this.phaseType,
    required this.sanctionLoad,
    required this.maximumDemand,
    required this.tariffSolution,
    required this.month,
    required this.apf,
  });

  factory MonthlyConsumption.fromJson(Map<String, dynamic> json) =>
      MonthlyConsumption(
        accountNo: json["accountNo"],
        meterNo: json["meterNo"],
        consumedTaka: json["consumedTaka"]?.toDouble(),
        consumedUnit: json["consumedUnit"]?.toDouble(),
        customerName: json["customerName"],
        installationAddress: json["installationAddress"],
        phaseType: json["phaseType"],
        sanctionLoad: json["sanctionLoad"],
        maximumDemand: json["maximumDemand"]?.toDouble(),
        tariffSolution: json["tariffSolution"],
        month: json["month"],
        apf: json["APF"],
      );

  String accountNo;
  String meterNo;
  double consumedTaka;
  double consumedUnit;
  String customerName;
  String installationAddress;
  String phaseType;
  int sanctionLoad;
  double maximumDemand;
  String tariffSolution;
  String month;
  double apf;

  Map<String, dynamic> toJson() => {
    "accountNo": accountNo,
    "meterNo": meterNo,
    "consumedTaka": consumedTaka,
    "consumedUnit": consumedUnit,
    "customerName": customerName,
    "installationAddress": installationAddress,
    "phaseType": phaseType,
    "sanctionLoad": sanctionLoad,
    "maximumDemand": maximumDemand,
    "tariffSolution": tariffSolution,
    "month": month,
    "APF": apf,
  };

  @override
  String toString() {
    return prettyPrint.convert(toJson());
  }
}

class Balance {
  Balance({
    required this.accountNo,
    required this.meterNo,
    required this.balance,
    required this.currentMonthConsumption,
    required this.readingTime,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
    accountNo: json["accountNo"],
    meterNo: json["meterNo"],
    balance: json["balance"]?.toDouble(),
    currentMonthConsumption: json["currentMonthConsumption"]?.toDouble(),
    readingTime: Date.from(DateTime.parse(json["readingTime"])),
  );

  String accountNo;
  String meterNo;
  double balance;
  double currentMonthConsumption;
  Date readingTime;

  Map<String, dynamic> toJson() => {
    "accountNo": accountNo,
    "meterNo": meterNo,
    "balance": balance,
    "currentMonthConsumption": currentMonthConsumption,
    "readingTime": readingTime.toString(),
  };

  @override
  String toString() {
    return prettyPrint.convert(toJson());
  }
}

class RechargeReceipt {
  RechargeReceipt({
    required this.accountNo,
    required this.meterNo,
    required this.orderId,
    required this.token,
    required this.sequence,
    required this.totalAmount,
    required this.energyAmount,
    required this.chargeAmount,
    required this.rechargeDate,
    required this.rechargeOperator,
    required this.rebate,
    required this.chargeItems,
    required this.orderStatus,
    required this.vat,
  });

  factory RechargeReceipt.fromJson(Map<String, dynamic> json) =>
      RechargeReceipt(
        accountNo: json["accountNo"],
        meterNo: json["meterNo"],
        orderId: _removeLeadingZeros(json["orderID"]),
        token: _formatToken(json["token"], 4),
        sequence: json["sequence"],
        totalAmount: json["totalAmount"],
        energyAmount: json["energyAmount"]?.toDouble(),
        chargeAmount: json["chargeAmount"]?.toDouble(),
        rechargeDate: DateTime.parse(json["rechargeDate"]),
        rechargeOperator: json["rechargeOperator"],
        rebate: json["rebate"]?.toDouble(),
        chargeItems: List<ChargeItem>.from(
          json["chargeItems"].map((x) => ChargeItem.fromJson(x)),
        ),
        orderStatus: json["orderStatus"],
        vat: json["VAT"]?.toDouble(),
      );

  String accountNo;
  String meterNo;
  String orderId;
  String token;
  String sequence;
  double totalAmount;
  double energyAmount;
  double chargeAmount;
  DateTime rechargeDate;
  String rechargeOperator;
  double rebate;
  List<ChargeItem> chargeItems;
  String orderStatus;
  double vat;

  Map<String, dynamic> toJson() => {
    "accountNo": accountNo,
    "meterNo": meterNo,
    "orderID": orderId,
    "token": token,
    "sequence": sequence,
    "totalAmount": totalAmount,
    "energyAmount": energyAmount,
    "chargeAmount": chargeAmount,
    "rechargeDate": rechargeDate.toIso8601String(),
    "rechargeOperator": rechargeOperator,
    "rebate": rebate,
    "chargeItems": List<dynamic>.from(chargeItems.map((x) => x.toJson())),
    "orderStatus": orderStatus,
    "VAT": vat,
  };

  @override
  String toString() {
    return prettyPrint.convert(toJson());
  }
}

class ChargeItem {
  ChargeItem({required this.chargeItemName, required this.chargeAmount});

  factory ChargeItem.fromJson(Map<String, dynamic> json) => ChargeItem(
    chargeItemName: json["chargeItemName"],
    chargeAmount: json["chargeAmount"],
  );
  String chargeItemName;
  double chargeAmount;

  Map<String, dynamic> toJson() => {
    "chargeItemName": chargeItemName,
    "chargeAmount": chargeAmount,
  };

  @override
  String toString() {
    return prettyPrint.convert(toJson());
  }
}

String _removeLeadingZeros(String s) => s.replaceFirst(RegExp(r'^0+'), '');

String _formatToken(String input, int sp) {
  final buffer = StringBuffer();

  for (int i = 0; i < input.length; i++) {
    if (i > 0 && i % sp == 0) {
      buffer.write('  ');
    }
    buffer.write(input[i]);
  }

  return buffer.toString();
}

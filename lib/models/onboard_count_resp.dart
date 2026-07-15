// To parse this JSON data, do
//
//     final onboardCountResp = onboardCountRespFromMap(jsonString);

import 'dart:convert';

OnboardCountResp onboardCountRespFromMap(String str) => OnboardCountResp.fromMap(json.decode(str));

String onboardCountRespToMap(OnboardCountResp data) => json.encode(data.toMap());

class OnboardCountResp {
  final bool? success;
  final dynamic error;
  final Count? count;

  OnboardCountResp({
    this.success,
    this.error,
    this.count,
  });

  factory OnboardCountResp.fromMap(Map<String, dynamic> json) => OnboardCountResp(
    success: json["success"],
    error: json["error"],
    count: json["count"] == null ? null : Count.fromMap(json["count"]),
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "error": error,
    "count": count?.toMap(),
  };
}

class Count {
  final String? dsACompleted;
  final String? connectorCompleted;
  final String? aggregatorCompleted;
  final String? dsAPending;
  final String? connectorPending;
  final String? aggregatorPending;
  final String? aggregatorVisit;
  final String? appraiserPending;
  final String? appraiserCompleted;

  Count({
    this.dsACompleted,
    this.connectorCompleted,
    this.aggregatorCompleted,
    this.dsAPending,
    this.connectorPending,
    this.aggregatorPending,
    this.aggregatorVisit,
    this.appraiserPending,
    this.appraiserCompleted
  });

  factory Count.fromMap(Map<String, dynamic> json) => Count(
    dsACompleted: json["dsA_Completed"],
    connectorCompleted: json["connector_Completed"],
    aggregatorCompleted: json["aggregator_Completed"],
    dsAPending: json["dsA_Pending"],
    connectorPending: json["connector_Pending"],
    aggregatorPending: json["aggregator_Pending"],
    aggregatorVisit: json["aggregator_Visit"],
    appraiserPending: json["appraiser_Pending"],
    appraiserCompleted: json["appraiser_Completed"],
  );

  Map<String, dynamic> toMap() => {
    "dsA_Completed": dsACompleted,
    "connector_Completed": connectorCompleted,
    "aggregator_Completed": aggregatorCompleted,
    "dsA_Pending": dsAPending,
    "connector_Pending": connectorPending,
    "aggregator_Pending": aggregatorPending,
    "aggregator_Visit": aggregatorVisit,
    "appraiser_Pending": appraiserPending,
    "appraiser_Completed": appraiserCompleted,
  };
}

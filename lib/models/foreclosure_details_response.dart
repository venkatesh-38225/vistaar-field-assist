import 'package:re_kyc_mobile_app/models/loan_details_res.dart';

class ForeClosureDetailsResponse {
  final String? lan;
  final String? fullName;
  final Branch? branch;
  final double? pos;
  final Legal? legal;
  final String? custId;
  final String? dpd;
  final String? totalOutstanding;
  final String? principalOutstanding;
  final String? mobile;
  final String? alternateMobile;
  final String? residentialAddress;
  final String? propertyAddress;

  ForeClosureDetailsResponse({
    this.lan,
    this.fullName,
    this.branch,
    this.pos,
    this.legal,
    this.custId,
    this.dpd,
    this.totalOutstanding,
    this.principalOutstanding,
    this.mobile,
    this.alternateMobile,
    this.propertyAddress,
    this.residentialAddress,
  });

  factory ForeClosureDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ForeClosureDetailsResponse(
      lan: json['lan'] as String?,
      fullName: json['custName'] as String?,
      mobile: json['mobile'] as String?,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      pos: (json['pos'] as num?)?.toDouble(),
      legal: json['legal'] != null ? Legal.fromJson(json['legal']) : null,
      custId: json['custId'] as String?,
      dpd: json['dpd'] as String?,
      totalOutstanding: json['totalOutstandingExclFc']?.toString(),
      principalOutstanding: json['principalOutstanding']?.toString(),
      alternateMobile: json['alternateMobile']?.toString(),
      residentialAddress: json['residentialAddress']?.toString(),
      propertyAddress: json['propertyAddress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lan': lan,
      'fullName': fullName,
      'branch': branch?.toJson(),
      'pos': pos,
      'legal': legal?.toJson(),
      'custId': custId,
      'dpd': dpd,
      'totalOutstanding': totalOutstanding,
      'principalOutstanding': principalOutstanding,
      'mobile': mobile,
      'alternateMobile': alternateMobile,
      'residentialAddress': residentialAddress,
      'propertyAddress': propertyAddress,
    };
  }
}

class LoanDetailsResponse {
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

  LoanDetailsResponse({
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
    this.residentialAddress
  });

  factory LoanDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LoanDetailsResponse(
      lan: json['lan'] as String?,
      fullName: json['fullName'] as String?,
      mobile: json['mobile'] as String?,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      pos: (json['pos'] as num?)?.toDouble(),
      legal: json['legal'] != null ? Legal.fromJson(json['legal']) : null,
      custId: json['custId'] as String?,
      dpd: json['dpd'] as String?,
      totalOutstanding: json['totalOutstanding']?.toString(),
      principalOutstanding: json['principalOutstanding']?.toString(),
      alternateMobile: json['alternateMobile']?.toString(),
      residentialAddress: json['residentialAddress']?.toString(),
      propertyAddress: json['propertyAddress']?.toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'lan':lan,
      'fullName': fullName,
      'branch': branch?.toJson(),
      'pos': pos,
      'legal': legal?.toJson(),
    };
  }
}

class Branch {
  final String? branchCode;
  final String? branchName;
  final String? region;
  final String? zone;
  final String? megaZone;

  Branch({
    this.branchCode,
    this.branchName,
    this.region,
    this.zone,
    this.megaZone,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchCode: json['branchCode'] as String?,
      branchName: json['branchName'] as String?,
      region: json['region'] as String?,
      zone: json['zone'] as String?,
      megaZone: json['megaZone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchCode': branchCode,
      'branchName': branchName,
      'region': region,
      'zone': zone,
      'megaZone': megaZone,
    };
  }
}

class Legal {
  final String? sec25;
  final String? sec138;
  final String? arbitration;
  final String? sarfaesi;
  final String? lrn;
  final String? sec25File;
  final String? sec138File;
  final String? arbitrationFile;
  final String? sarfaesiFile;
  final String? lrnFile;

  Legal({
    this.sec25,
    this.sec138,
    this.arbitration,
    this.sarfaesi,
    this.lrn,
    this.sec25File,
    this.sec138File,
    this.arbitrationFile,
    this.sarfaesiFile,
    this.lrnFile,
  });

  factory Legal.fromJson(Map<String, dynamic> json) {
    return Legal(
      sec25: json['sec25'] as String?,
      sec138: json['sec138'] as String?,
      arbitration: json['arbitration'] as String?,
      sarfaesi: json['sarfaesi'] as String?,
      lrn: json['lrn'] as String?,
      sec25File: json['sec25File'] as String?,
      sec138File: json['sec138File'] as String?,
      arbitrationFile: json['arbitrationFile'] as String?,
      sarfaesiFile: json['sarfaesiFile'] as String?,
      lrnFile: json['lrnFile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sec25': sec25,
      'sec138': sec138,
      'arbitration': arbitration,
      'sarfaesi': sarfaesi,
      'lrn': lrn,
      'sec25File': sec25File,
      'sec138File': sec138File,
      'arbitrationFile': arbitrationFile,
      'sarfaesiFile': sarfaesiFile,
      'lrnFile': lrnFile,
    };
  }
}

class StateItem {
  final String cpCountry;
  final String cpProvince;
  final String cpProvinceName;
  final String? recordStatus;

  StateItem({
    required this.cpCountry,
    required this.cpProvince,
    required this.cpProvinceName,
    this.recordStatus,
  });

  factory StateItem.fromJson(Map<String, dynamic> json) => StateItem(
        cpCountry: (json['cpCountry'] ?? '').toString(),
        cpProvince: (json['cpProvince'] ?? '').toString(),
        cpProvinceName: (json['cpProvinceName'] ?? '').toString(),
        recordStatus: json['recordStatus']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'cpCountry': cpCountry,
        'cpProvince': cpProvince,
        'cpProvinceName': cpProvinceName,
        'recordStatus': recordStatus,
      };
}

class CityItem {
  final String pcProvince;
  final String pcCity;
  final String pcCityName;

  CityItem({
    required this.pcProvince,
    required this.pcCity,
    required this.pcCityName,
  });

  factory CityItem.fromJson(Map<String, dynamic> json) => CityItem(
        pcProvince: (json['pcProvince'] ?? '').toString(),
        pcCity: (json['pcCity'] ?? '').toString(),
        pcCityName: (json['pcCityName'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'pcProvince': pcProvince,
        'pcCity': pcCity,
        'pcCityName': pcCityName,
      };
}

class PinCodeItem {
  final dynamic pincodeId;
  final String pincode;
  final String city;

  PinCodeItem({
    this.pincodeId,
    required this.pincode,
    required this.city,
  });

  factory PinCodeItem.fromJson(Map<String, dynamic> json) => PinCodeItem(
        pincodeId: json['pincodeId'],
        pincode: (json['pincode'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'pincodeId': pincodeId,
        'pincode': pincode,
        'city': city,
      };
}

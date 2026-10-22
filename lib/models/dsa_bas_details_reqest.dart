import 'dart:convert';

DsaBasicDetailsRequest dsaBasicDetailsRequestFromMap(String str) => DsaBasicDetailsRequest.fromMap(json.decode(str));

String dsaBasicDetailsRequestToMap(DsaBasicDetailsRequest data) => json.encode(data.toMap());

class DsaBasicDetailsRequest {
   String? queryType;
   String? pan;
   Data? data;

  DsaBasicDetailsRequest({
    this.queryType,
    this.pan,
    this.data,
  });

  factory DsaBasicDetailsRequest.fromMap(Map<String, dynamic> json) => DsaBasicDetailsRequest(
    queryType: json["queryType"],
    pan: json["pan"],
    data: json["data"] == null ? null : Data.fromMap(json["data"]),
  );

  Map<String, dynamic> toMap() => {
    "queryType": queryType,
    "pan": pan,
    "data": data?.toMap(),
  };
}

class Data {
  final BasicDetails? basicDetails;
  final String? updatedby;

  Data({
    this.basicDetails,
    this.updatedby,
  });

  factory Data.fromMap(Map<String, dynamic> json) => Data(
    basicDetails: json["basicDetails"] == null ? null : BasicDetails.fromMap(json["basicDetails"]),
    updatedby: json["updatedby"],
  );

  Map<String, dynamic> toMap() => {
    "basicDetails": basicDetails?.toMap(),
    "updatedby": updatedby,
  };
}

class BasicDetails {
   String? name;
   String? mobile;
   String? mobileStatus;
   String? email;
   String? emailStatus;
   String? vcpType;
   String? companyType;
   String? companyRegistrationNo;
   String? designation;
   String? pincode;
   String? city;
   String? district;
   String? stateName;
   String? officeAddress;
   String? telephoneNumber;
   String? remarks;
   String? pan;
   DateTime? dobAsperPan;
   String? stateCode;
   String? cityCode;
   dynamic pinCodeId;

  BasicDetails({
    this.name,
    this.mobile,
    this.mobileStatus,
    this.email,
    this.emailStatus,
    this.vcpType,
    this.companyType,
    this.companyRegistrationNo,
    this.designation,
    this.pincode,
    this.city,
    this.district,
    this.stateName,
    this.officeAddress,
    this.telephoneNumber,
    this.remarks,
    this.pan,
    this.dobAsperPan,
    this.stateCode,
    this.cityCode,
    this.pinCodeId,
  });

  factory BasicDetails.fromMap(Map<String, dynamic> json) => BasicDetails(
    name: json["name"],
    mobile: json["mobile"],
    mobileStatus: json["mobileStatus"],
    email: json["email"],
    emailStatus: json["emailStatus"],
    vcpType: json["vcpType"],
    companyType: json["companyType"],
    companyRegistrationNo: json["companyRegistrationNo"],
    designation: json["designation"],
    pincode: json["pincode"],
    city: json["city"],
    district: json["district"],
    stateName: json["stateName"],
    officeAddress: json["officeAddress"],
    telephoneNumber: json["telephoneNumber"],
    remarks: json["remarks"],
    pan: json["pan"],
    dobAsperPan: json["dobAsperPAN"] == null ? null : DateTime.parse(json["dobAsperPAN"]),
    stateCode: json["stateCode"]?.toString(),
    cityCode: json["cityCode"]?.toString(),
    pinCodeId: json["pinCodeId"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "mobile": mobile,
    "mobileStatus": mobileStatus,
    "email": email,
    "emailStatus": emailStatus,
    "vcpType": vcpType,
    "companyType": companyType,
    "companyRegistrationNo": companyRegistrationNo,
    "designation": designation,
    "pincode": pincode,
    "city": city,
    "district": district,
    "stateName": stateName,
    "officeAddress": officeAddress,
    "telephoneNumber": telephoneNumber,
    "remarks": remarks,
    "pan": pan,
    "dobAsperPAN": dobAsperPan?.toIso8601String(),
    "stateCode": stateCode,
    "cityCode": cityCode,
    "pinCodeId": pinCodeId,
  };
}

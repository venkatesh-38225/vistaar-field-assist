// To parse this JSON data, do
//
//     final dsaCustomerList = dsaCustomerListFromMap(jsonString);

import 'dart:convert';

DsaCustomerList dsaCustomerListFromMap(String str) => DsaCustomerList.fromMap(json.decode(str));

String dsaCustomerListToMap(DsaCustomerList data) => json.encode(data.toMap());

class DsaCustomerList {
  final bool? success;
  final dynamic error;
  final List<Datum>? data;

  DsaCustomerList({
    this.success,
    this.error,
    this.data,
  });

  factory DsaCustomerList.fromMap(Map<String, dynamic> json) => DsaCustomerList(
    success: json["success"],
    error: json["error"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
  };
}

class Actions {
  final String? rcuStatus;
  final String? rcuRemarks;
  final String? rbhStatus;
  final String? rbhRemarks;
  final String? zbhStatus;
  final String? zbhRemarks;
  final String? mzbhStatus;
  final String? mzbhRemarks;
  final String? copsStatus;
  final String? copsRemarks;
  final String? channelSpocStatus;
  final String? channelSpocRemarks;

  Actions({
    this.rcuStatus,
    this.rcuRemarks,
    this.rbhStatus,
    this.rbhRemarks,
    this.zbhStatus,
    this.zbhRemarks,
    this.mzbhStatus,
    this.mzbhRemarks,
    this.copsStatus,
    this.copsRemarks,
    this.channelSpocStatus,
    this.channelSpocRemarks,
  });

  factory Actions.fromMap(Map<String, dynamic> json) => Actions(
    rcuStatus: json["rcU_Status"],
    rcuRemarks: json["rcU_Remarks"],
    rbhStatus: json["rbH_Status"],
    rbhRemarks: json["rbH_Remarks"],
    zbhStatus: json["zbH_Status"],
    zbhRemarks: json["zbH_Remarks"],
    mzbhStatus: json["mzbH_Status"],
    mzbhRemarks: json["mzbH_Remarks"],
    copsStatus: json["copS_Status"],
    copsRemarks: json["copS_Remarks"],
    channelSpocStatus: json["channelSpoc_Status"],
    channelSpocRemarks: json["channelSpoc_Remarks"],
  );

  Map<String, dynamic> toMap() => {
    "rcU_Status": rcuStatus,
    "rcU_Remarks": rcuRemarks,
    "rbH_Status": rbhStatus,
    "rbH_Remarks": rbhRemarks,
    "zbH_Status": zbhStatus,
    "zbH_Remarks": zbhRemarks,
    "mzbH_Status": mzbhStatus,
    "mzbH_Remarks": mzbhRemarks,
    "copS_Status": copsStatus,
    "copS_Remarks": copsRemarks,
    "channelSpoc_Status": channelSpocStatus,
    "channelSpoc_Remarks": channelSpocRemarks,
  };
}

class Datum {
  final String? id;
  final BasicDetails? basicDetails;
  final BusinessDetails? businessDetails;
  final BankDetails? bankDetails;
  final String? status;
  final String? createdBy;
  final String? createdDt;
  final String? updatedBy;
  final String? updatedDt;
  final Documents? documents;
  final bool? isSentBack;
  final Actions? actions;
  final String? vcpCode;

  Datum({
    this.id,
    this.basicDetails,
    this.businessDetails,
    this.bankDetails,
    this.status,
    this.createdBy,
    this.createdDt,
    this.updatedBy,
    this.updatedDt,
    this.documents,
    this.isSentBack,
    this.actions,
    this.vcpCode,
  });

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
    id: json["id"],
    basicDetails: json["basicDetails"] == null ? null : BasicDetails.fromMap(json["basicDetails"]),
    businessDetails: json["businessDetails"] == null ? null : BusinessDetails.fromMap(json["businessDetails"]),
    bankDetails: json["bankDetails"] == null ? null : BankDetails.fromMap(json["bankDetails"]),
    status: json["status"],
    createdBy: json["createdBy"],
    createdDt: json["createdDt"],
    updatedBy: json["updatedBy"],
    updatedDt: json["updatedDt"],
    documents: json["documents"] == null ? null : Documents.fromMap(json["documents"]),
    isSentBack: json["isSentBack"],
    actions: json["actions"] == null ? null : Actions.fromMap(json["actions"]),
      vcpCode: json["vcpCode"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "basicDetails": basicDetails?.toMap(),
    "businessDetails": businessDetails?.toMap(),
    "bankDetails": bankDetails?.toMap(),
    "status": status,
    "createdBy": createdBy,
    "createdDt": createdDt,
    "updatedBy": updatedBy,
    "updatedDt": updatedDt,
    "documents": documents?.toMap(),
    "isSentBack": isSentBack,
    "actions": actions?.toMap(),
    "vcpCode" : vcpCode,
  };
}

class BankDetails {
  final BankAcDetails? bankAcDetails;
  final String? contactId;
  final String? fundAcId;
  final String? fundAcValidationId;
  final String? status;
  final String? utr;
  final Results? results;

  BankDetails({
    this.bankAcDetails,
    this.contactId,
    this.fundAcId,
    this.fundAcValidationId,
    this.status,
    this.utr,
    this.results,
  });

  factory BankDetails.fromMap(Map<String, dynamic> json) => BankDetails(
    bankAcDetails: json["bankAcDetails"] == null ? null : BankAcDetails.fromMap(json["bankAcDetails"]),
    contactId: json["contactID"],
    fundAcId: json["fundAcID"],
    fundAcValidationId: json["fundAcValidationID"],
    status: json["status"],
    utr: json["utr"],
    results: json["results"] == null ? null : Results.fromMap(json["results"]),
  );

  Map<String, dynamic> toMap() => {
    "bankAcDetails": bankAcDetails?.toMap(),
    "contactID": contactId,
    "fundAcID": fundAcId,
    "fundAcValidationID": fundAcValidationId,
    "status": status,
    "utr": utr,
    "results": results?.toMap(),
  };
}

class BankAcDetails {
  final String? bankAcNo;
  final String? acHolderName;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;

  BankAcDetails({
    this.bankAcNo,
    this.acHolderName,
    this.ifscCode,
    this.bankName,
    this.branchName,
  });

  factory BankAcDetails.fromMap(Map<String, dynamic> json) => BankAcDetails(
    bankAcNo: json["bankAcNo"],
    acHolderName: json["acHolderName"],
    ifscCode: json["ifscCode"],
    bankName: json["bankName"],
    branchName: json["branchName"],
  );

  Map<String, dynamic> toMap() => {
    "bankAcNo": bankAcNo,
    "acHolderName": acHolderName,
    "ifscCode": ifscCode,
    "bankName": bankName,
    "branchName": branchName,
  };
}

class Results {
  final String? accountStatus;
  final String? registeredName;

  Results({
    this.accountStatus,
    this.registeredName,
  });

  factory Results.fromMap(Map<String, dynamic> json) => Results(
    accountStatus: json["account_status"],
    registeredName: json["registered_name"],
  );

  Map<String, dynamic> toMap() => {
    "account_status": accountStatus,
    "registered_name": registeredName,
  };
}

class BasicDetails {
  final String? name;
  final String? branchCode;
  final String? mobile;
  final String? mobileStatus;
  final String? email;
  final String? emailStatus;
  final String? vcpType;
  final String? companyType;
  final String? companyRegistrationNo;
  final String? designation;
  final String? pincode;
  final String? city;
  final String? district;
  final String? stateName;
  final String? address;
  final String? officeAddress;
  final String? telephoneNumber;
  final String? remarks;
  final String? pan;
  final String? dobAsperPan;
  final String? gender;
  final String? fatherName;
  final String? eduQualification;
  final String? agencyName;
  final String? businessName;
  final bool? isSameIndividualAddress;

  BasicDetails({
    this.name,
    this.branchCode,
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
    this.address,
    this.officeAddress,
    this.telephoneNumber,
    this.remarks,
    this.pan,
    this.dobAsperPan,
    this.gender,
    this.fatherName,
    this.eduQualification,
    this.agencyName,
    this.businessName,
    this.isSameIndividualAddress
  });

  factory BasicDetails.fromMap(Map<String, dynamic> json) => BasicDetails(
    name: json["name"],
    branchCode: json["branchCode"],
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
    address: json["address"],
    officeAddress: json["officeAddress"],
    telephoneNumber: json["telephoneNumber"],
    remarks: json["remarks"],
    pan: json["pan"],
    dobAsperPan: json["dobAsperPAN"],
    gender: json["gender"],
    fatherName: json["fatherName"],
    eduQualification: json["eduQualification"],
    agencyName: json["agencyName"],
    businessName: json["businessName"],
    isSameIndividualAddress: json["isSameIndividualAddress"]
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "branchCode": branchCode,
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
    "address": address,
    "officeAddress": officeAddress,
    "telephoneNumber": telephoneNumber,
    "remarks": remarks,
    "pan": pan,
    "dobAsperPAN": dobAsperPan,
    "gender": gender,
    "fatherName": fatherName,
    "eduQualification": eduQualification,
    "agencyName": agencyName,
    "businessName": businessName,
    "isSameIndividualAddress": isSameIndividualAddress,
  };
}

class BusinessDetails {
  final String? noOfYearsInBusiness;
  final String? nbfcBankParnters;
  final List<NbfcBankParnterDetail>? nbfcBankParnterDetails;
  final String? noOfOfficesInIndia;
  final List<String>? listOfCities;
  final String? noOfEmployees;
  final String? useSubContractorsToService;
  final String? describeServicesOrDeliverables;
  final String? relatedToEmployeeOfVistaar;
  final List<EmployeeRelation>? employeeRelation;
  final String? urcNo;
  final String? willingnessToGoldAppraiser;
  final String? valuationCharges;

  BusinessDetails({
    this.noOfYearsInBusiness,
    this.nbfcBankParnters,
    this.nbfcBankParnterDetails,
    this.noOfOfficesInIndia,
    this.listOfCities,
    this.noOfEmployees,
    this.useSubContractorsToService,
    this.describeServicesOrDeliverables,
    this.relatedToEmployeeOfVistaar,
    this.employeeRelation,
    this.urcNo,
    this.willingnessToGoldAppraiser,
    this.valuationCharges
  });

  factory BusinessDetails.fromMap(Map<String, dynamic> json) => BusinessDetails(
    noOfYearsInBusiness: json["noOfYearsInBusiness"],
    nbfcBankParnters: json["nbfcBankParnters"],
    nbfcBankParnterDetails: json["nbfcBankParnterDetails"] == null ? [] : List<NbfcBankParnterDetail>.from(json["nbfcBankParnterDetails"]!.map((x) => NbfcBankParnterDetail.fromMap(x))),
    noOfOfficesInIndia: json["noOfOfficesInIndia"],
    listOfCities: json["listOfCities"] == null ? [] : List<String>.from(json["listOfCities"]!.map((x) => x)),
    noOfEmployees: json["noOfEmployees"],
    useSubContractorsToService: json["useSubContractorsToService"],
    describeServicesOrDeliverables: json["describeServicesOrDeliverables"],
    relatedToEmployeeOfVistaar: json["relatedToEmployeeOfVistaar"],
    employeeRelation: json["employeeRelation"] == null ? [] : List<EmployeeRelation>.from(json["employeeRelation"]!.map((x) => EmployeeRelation.fromMap(x))),
    urcNo: json["urcNo"],
    willingnessToGoldAppraiser: json["willingnessToGoldAppraiser"],
    valuationCharges: json["valuationCharges"],
  );

  Map<String, dynamic> toMap() => {
    "noOfYearsInBusiness": noOfYearsInBusiness,
    "nbfcBankParnters": nbfcBankParnters,
    "nbfcBankParnterDetails": nbfcBankParnterDetails == null ? [] : List<dynamic>.from(nbfcBankParnterDetails!.map((x) => x.toMap())),
    "noOfOfficesInIndia": noOfOfficesInIndia,
    "listOfCities": listOfCities == null ? [] : List<dynamic>.from(listOfCities!.map((x) => x)),
    "noOfEmployees": noOfEmployees,
    "useSubContractorsToService": useSubContractorsToService,
    "describeServicesOrDeliverables": describeServicesOrDeliverables,
    "relatedToEmployeeOfVistaar": relatedToEmployeeOfVistaar,
    "employeeRelation": employeeRelation == null ? [] : List<dynamic>.from(employeeRelation!.map((x) => x.toMap())),
    "urcNo": urcNo,
    "willingnessToGoldAppraiser": willingnessToGoldAppraiser,
    "valuationCharges": valuationCharges,
  };
}

class EmployeeRelation {
  final String? name;
  final String? relationship;

  EmployeeRelation({
    this.name,
    this.relationship,
  });

  factory EmployeeRelation.fromMap(Map<String, dynamic> json) => EmployeeRelation(
    name: json["name"],
    relationship: json["relationship"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "relationship": relationship,
  };
}

class Documents {
  final String? photo;
  final String? signature;
  final String? pan;
  final String? addressProof;
  final String? companyPAN;
  final String? officeAddressProof;
  final String? addressProofType;
  final String? officeAddressProofType;
  final String? entityProofType;
  final String? entityProof;
  final String? dsa;
  final String? urc;
  final String? eSign;
  final String? otherDoc;

  Documents({
    this.photo,
    this.signature,
    this.pan,
    this.addressProof,
    this.companyPAN,
    this.officeAddressProof,
    this.entityProof,
    this.addressProofType,
    this.officeAddressProofType,
    this.entityProofType,
    this.dsa,
    this.urc,
    this.eSign,
    this.otherDoc,
  });

  factory Documents.fromMap(Map<String, dynamic> json) => Documents(
    photo: json["photo"],
    signature: json["signature"],
    pan: json["pan"],
    addressProof: json["addressProof"],
    companyPAN: json["companyPAN"],
    officeAddressProof: json["officeAddressProof"],
    addressProofType: json["addressProofType"],
    officeAddressProofType: json["officeAddressProofType"],
    entityProofType: json["entityProofType"],
    entityProof: json["entityProof"],
    dsa: json["dsa"],
    urc: json["urc"],
    eSign: json["eSign"],
    otherDoc: json["otherDoc"],
  );

  Map<String, dynamic> toMap() => {
    "photo": photo,
    "signature": signature,
    "pan": pan,
    "addressProof": addressProof,
    "addressProofType": addressProofType,
    "companyPAN": companyPAN,
    "officeAddressProof": officeAddressProof,
    "officeAddressProofType": officeAddressProofType,
    "entityProof": entityProof,
    "entityProofType": entityProofType,
    "dsa": dsa,
    "urc": urc,
    "eSign": eSign,
    "otherDoc": otherDoc,
  };
}

class NbfcBankParnterDetail {
  final String? companyName;
  final String? product;
  final String? nameOfContact;
  final String? mobileNo;

  NbfcBankParnterDetail({
    this.companyName,
    this.product,
    this.nameOfContact,
    this.mobileNo,
  });

  factory NbfcBankParnterDetail.fromMap(Map<String, dynamic> json) => NbfcBankParnterDetail(
    companyName: json["companyName"],
    product: json["product"],
    nameOfContact: json["nameOfContact"],
    mobileNo: json["mobileNo"],
  );

  Map<String, dynamic> toMap() => {
    "companyName": companyName,
    "product": product,
    "nameOfContact": nameOfContact,
    "mobileNo": mobileNo,
  };

}

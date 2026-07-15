// To parse this JSON data, do
//
//     final eSignMessageModel = eSignMessageModelFromMap(jsonString);

import 'dart:convert';

ESignMessageModel eSignMessageModelFromMap(String str) => ESignMessageModel.fromMap(json.decode(str));

String eSignMessageModelToMap(ESignMessageModel data) => json.encode(data.toMap());

class ESignMessageModel {
  final String? id;
  final bool? isAgreement;
  final String? agreementType;
  final String? agreementStatus;
  final String? fileName;
  final DateTime? createdAt;
  final bool? selfSigned;
  final String? selfSignType;
  final int? noOfPages;
  final List<SigningParty>? signingParties;
  final SignRequestDetails? signRequestDetails;
  final String? channel;
  final OtherDocDetails? otherDocDetails;
  final AttachedEstampDetails? attachedEstampDetails;

  ESignMessageModel({
    this.id,
    this.isAgreement,
    this.agreementType,
    this.agreementStatus,
    this.fileName,
    this.createdAt,
    this.selfSigned,
    this.selfSignType,
    this.noOfPages,
    this.signingParties,
    this.signRequestDetails,
    this.channel,
    this.otherDocDetails,
    this.attachedEstampDetails,
  });

  factory ESignMessageModel.fromMap(Map<String, dynamic> json) => ESignMessageModel(
    id: json["id"],
    isAgreement: json["is_agreement"],
    agreementType: json["agreement_type"],
    agreementStatus: json["agreement_status"],
    fileName: json["file_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    selfSigned: json["self_signed"],
    selfSignType: json["self_sign_type"],
    noOfPages: json["no_of_pages"],
    signingParties: json["signing_parties"] == null ? [] : List<SigningParty>.from(json["signing_parties"]!.map((x) => SigningParty.fromMap(x))),
    signRequestDetails: json["sign_request_details"] == null ? null : SignRequestDetails.fromMap(json["sign_request_details"]),
    channel: json["channel"],
    otherDocDetails: json["other_doc_details"] == null ? null : OtherDocDetails.fromMap(json["other_doc_details"]),
    attachedEstampDetails: json["attached_estamp_details"] == null ? null : AttachedEstampDetails.fromMap(json["attached_estamp_details"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "is_agreement": isAgreement,
    "agreement_type": agreementType,
    "agreement_status": agreementStatus,
    "file_name": fileName,
    "created_at": createdAt?.toIso8601String(),
    "self_signed": selfSigned,
    "self_sign_type": selfSignType,
    "no_of_pages": noOfPages,
    "signing_parties": signingParties == null ? [] : List<dynamic>.from(signingParties!.map((x) => x.toMap())),
    "sign_request_details": signRequestDetails?.toMap(),
    "channel": channel,
    "other_doc_details": otherDocDetails?.toMap(),
    "attached_estamp_details": attachedEstampDetails?.toMap(),
  };
}

class AttachedEstampDetails {
  AttachedEstampDetails();

  factory AttachedEstampDetails.fromMap(Map<String, dynamic> json) => AttachedEstampDetails(
  );

  Map<String, dynamic> toMap() => {
  };
}

class OtherDocDetails {
  final bool? webHookAvailable;

  OtherDocDetails({
    this.webHookAvailable,
  });

  factory OtherDocDetails.fromMap(Map<String, dynamic> json) => OtherDocDetails(
    webHookAvailable: json["web_hook_available"],
  );

  Map<String, dynamic> toMap() => {
    "web_hook_available": webHookAvailable,
  };
}

class SignRequestDetails {
  final String? name;
  final DateTime? requestedOn;
  final DateTime? expireOn;
  final String? identifier;
  final String? requesterType;

  SignRequestDetails({
    this.name,
    this.requestedOn,
    this.expireOn,
    this.identifier,
    this.requesterType,
  });

  factory SignRequestDetails.fromMap(Map<String, dynamic> json) => SignRequestDetails(
    name: json["name"],
    requestedOn: json["requested_on"] == null ? null : DateTime.parse(json["requested_on"]),
    expireOn: json["expire_on"] == null ? null : DateTime.parse(json["expire_on"]),
    identifier: json["identifier"],
    requesterType: json["requester_type"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "requested_on": requestedOn?.toIso8601String(),
    "expire_on": expireOn?.toIso8601String(),
    "identifier": identifier,
    "requester_type": requesterType,
  };
}

class SigningParty {
  final String? name;
  final String? status;
  final String? type;
  final String? signatureType;
  final String? identifier;
  final int? signingIndex;
  final String? reason;
  final DateTime? expireOn;

  SigningParty({
    this.name,
    this.status,
    this.type,
    this.signatureType,
    this.identifier,
    this.signingIndex,
    this.reason,
    this.expireOn,
  });

  factory SigningParty.fromMap(Map<String, dynamic> json) => SigningParty(
    name: json["name"],
    status: json["status"],
    type: json["type"],
    signatureType: json["signature_type"],
    identifier: json["identifier"],
    signingIndex: json["signing_index"],
    reason: json["reason"],
    expireOn: json["expire_on"] == null ? null : DateTime.parse(json["expire_on"]),
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "status": status,
    "type": type,
    "signature_type": signatureType,
    "identifier": identifier,
    "signing_index": signingIndex,
    "reason": reason,
    "expire_on": expireOn?.toIso8601String(),
  };
}

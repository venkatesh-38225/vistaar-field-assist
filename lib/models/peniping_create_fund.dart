// To parse this JSON data, do
//
//     final penipingCreateFund = penipingCreateFundFromMap(jsonString);

import 'dart:convert';

PenipingCreateFund penipingCreateFundFromMap(String str) => PenipingCreateFund.fromMap(json.decode(str));

String penipingCreateFundToMap(PenipingCreateFund data) => json.encode(data.toMap());

class PenipingCreateFund {
  final String? id;
  final String? entity;
  final String? contactId;
  final String? accountType;
  final BankAccount? bankAccount;
  final dynamic batchId;
  final bool? active;
  final int? createdAt;

  PenipingCreateFund({
    this.id,
    this.entity,
    this.contactId,
    this.accountType,
    this.bankAccount,
    this.batchId,
    this.active,
    this.createdAt,
  });

  factory PenipingCreateFund.fromMap(Map<String, dynamic> json) => PenipingCreateFund(
    id: json["id"],
    entity: json["entity"],
    contactId: json["contact_id"],
    accountType: json["account_type"],
    bankAccount: json["bank_account"] == null ? null : BankAccount.fromMap(json["bank_account"]),
    batchId: json["batch_id"],
    active: json["active"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "entity": entity,
    "contact_id": contactId,
    "account_type": accountType,
    "bank_account": bankAccount?.toMap(),
    "batch_id": batchId,
    "active": active,
    "created_at": createdAt,
  };
}

class BankAccount {
  final String? ifsc;
  final String? bankName;
  final String? name;
  final List<dynamic>? notes;
  final String? accountNumber;

  BankAccount({
    this.ifsc,
    this.bankName,
    this.name,
    this.notes,
    this.accountNumber,
  });

  factory BankAccount.fromMap(Map<String, dynamic> json) => BankAccount(
    ifsc: json["ifsc"],
    bankName: json["bank_name"],
    name: json["name"],
    notes: json["notes"] == null ? [] : List<dynamic>.from(json["notes"]!.map((x) => x)),
    accountNumber: json["account_number"],
  );

  Map<String, dynamic> toMap() => {
    "ifsc": ifsc,
    "bank_name": bankName,
    "name": name,
    "notes": notes == null ? [] : List<dynamic>.from(notes!.map((x) => x)),
    "account_number": accountNumber,
  };
}

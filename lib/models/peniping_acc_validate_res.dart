// To parse this JSON data, do
//
//     final penipingAccountValidate = penipingAccountValidateFromMap(jsonString);

import 'dart:convert';

PenipingAccountValidate penipingAccountValidateFromMap(String str) => PenipingAccountValidate.fromMap(json.decode(str));

String penipingAccountValidateToMap(PenipingAccountValidate data) => json.encode(data.toMap());

class PenipingAccountValidate {
  final String? id;
  final String? entity;
  final FundAccount? fundAccount;
  final String? status;
  final int? amount;
  final String? currency;
  final Notes? notes;
  final Results? results;
  final int? createdAt;
  final dynamic utr;

  PenipingAccountValidate({
    this.id,
    this.entity,
    this.fundAccount,
    this.status,
    this.amount,
    this.currency,
    this.notes,
    this.results,
    this.createdAt,
    this.utr,
  });

  factory PenipingAccountValidate.fromMap(Map<String, dynamic> json) => PenipingAccountValidate(
    id: json["id"],
    entity: json["entity"],
    fundAccount: json["fund_account"] == null ? null : FundAccount.fromMap(json["fund_account"]),
    status: json["status"],
    amount: json["amount"],
    currency: json["currency"],
    notes: json["notes"] == null ? null : Notes.fromMap(json["notes"]),
    results: json["results"] == null ? null : Results.fromMap(json["results"]),
    createdAt: json["created_at"],
    utr: json["utr"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "entity": entity,
    "fund_account": fundAccount?.toMap(),
    "status": status,
    "amount": amount,
    "currency": currency,
    "notes": notes?.toMap(),
    "results": results?.toMap(),
    "created_at": createdAt,
    "utr": utr,
  };
}

class FundAccount {
  final String? id;
  final String? entity;
  final String? contactId;
  final String? accountType;
  final BankAccount? bankAccount;
  final dynamic batchId;
  final bool? active;
  final int? createdAt;
  final BankAccount? details;

  FundAccount({
    this.id,
    this.entity,
    this.contactId,
    this.accountType,
    this.bankAccount,
    this.batchId,
    this.active,
    this.createdAt,
    this.details,
  });

  factory FundAccount.fromMap(Map<String, dynamic> json) => FundAccount(
    id: json["id"],
    entity: json["entity"],
    contactId: json["contact_id"],
    accountType: json["account_type"],
    bankAccount: json["bank_account"] == null ? null : BankAccount.fromMap(json["bank_account"]),
    batchId: json["batch_id"],
    active: json["active"],
    createdAt: json["created_at"],
    details: json["details"] == null ? null : BankAccount.fromMap(json["details"]),
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
    "details": details?.toMap(),
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

class Notes {
  final String? randomKey1;
  final String? randomKey2;

  Notes({
    this.randomKey1,
    this.randomKey2,
  });

  factory Notes.fromMap(Map<String, dynamic> json) => Notes(
    randomKey1: json["random_key_1"],
    randomKey2: json["random_key_2"],
  );

  Map<String, dynamic> toMap() => {
    "random_key_1": randomKey1,
    "random_key_2": randomKey2,
  };
}

class Results {
  final dynamic accountStatus;
  final dynamic registeredName;
  final dynamic utr;

  Results({
    this.accountStatus,
    this.registeredName,
    this.utr,
  });

  factory Results.fromMap(Map<String, dynamic> json) => Results(
    accountStatus: json["account_status"],
    registeredName: json["registered_name"],
    utr: json["utr"],
  );

  Map<String, dynamic> toMap() => {
    "account_status": accountStatus,
    "registered_name": registeredName,
    "utr": utr,
  };
}

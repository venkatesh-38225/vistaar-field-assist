// To parse this JSON data, do
//
//     final penipingCreateCustomer = penipingCreateCustomerFromMap(jsonString);

import 'dart:convert';

PenipingCreateCustomer penipingCreateCustomerFromMap(String str) => PenipingCreateCustomer.fromMap(json.decode(str));

String penipingCreateCustomerToMap(PenipingCreateCustomer data) => json.encode(data.toMap());

class PenipingCreateCustomer {
  final String? id;
  final String? entity;
  final String? name;
  final String? contact;
  final String? email;
  final String? type;
  final String? referenceId;
  final dynamic batchId;
  final bool? active;
  final Notes? notes;
  final int? createdAt;

  PenipingCreateCustomer({
    this.id,
    this.entity,
    this.name,
    this.contact,
    this.email,
    this.type,
    this.referenceId,
    this.batchId,
    this.active,
    this.notes,
    this.createdAt,
  });

  factory PenipingCreateCustomer.fromMap(Map<String, dynamic> json) => PenipingCreateCustomer(
    id: json["id"],
    entity: json["entity"],
    name: json["name"],
    contact: json["contact"],
    email: json["email"],
    type: json["type"],
    referenceId: json["reference_id"],
    batchId: json["batch_id"],
    active: json["active"],
    notes: json["notes"] == null ? null : Notes.fromMap(json["notes"]),
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "entity": entity,
    "name": name,
    "contact": contact,
    "email": email,
    "type": type,
    "reference_id": referenceId,
    "batch_id": batchId,
    "active": active,
    "notes": notes?.toMap(),
    "created_at": createdAt,
  };
}

class Notes {
  final String? noteKey;

  Notes({
    this.noteKey,
  });

  factory Notes.fromMap(Map<String, dynamic> json) => Notes(
    noteKey: json["note_key"],
  );

  Map<String, dynamic> toMap() => {
    "note_key": noteKey,
  };
}

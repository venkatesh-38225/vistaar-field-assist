// To parse this JSON data, do
//
//     final branchListRes = branchListResFromMap(jsonString);

import 'dart:convert';

BranchListRes branchListResFromMap(String str) => BranchListRes.fromMap(json.decode(str));

String branchListResToMap(BranchListRes data) => json.encode(data.toMap());

class BranchListRes {
  final List<D>? d;

  BranchListRes({
    this.d,
  });

  factory BranchListRes.fromMap(Map<String, dynamic> json) => BranchListRes(
    d: json["d"] == null ? [] : List<D>.from(json["d"]!.map((x) => D.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "d": d == null ? [] : List<dynamic>.from(d!.map((x) => x.toMap())),
  };
}

class D {
  final String? type;
  final String? branchcode;
  final String? branchname;
  final String? cluster;
  final int? lat;
  final String? latlng;
  final int? lng;
  final String? state;

  D({
    this.type,
    this.branchcode,
    this.branchname,
    this.cluster,
    this.lat,
    this.latlng,
    this.lng,
    this.state,
  });

  factory D.fromMap(Map<String, dynamic> json) => D(
    type: json["__type"],
    branchcode: json["Branchcode"],
    branchname: json["Branchname"],
    cluster: json["Cluster"],
    lat: json["Lat"],
    latlng: json["Latlng"],
    lng: json["Lng"],
    state: json["State"],
  );

  Map<String, dynamic> toMap() => {
    "__type": type,
    "Branchcode": branchcode,
    "Branchname": branchname,
    "Cluster": cluster,
    "Lat": lat,
    "Latlng": latlng,
    "Lng": lng,
    "State": state,
  };
}

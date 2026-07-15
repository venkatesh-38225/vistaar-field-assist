
import 'dart:convert';

TokenApiResponse tokenApiResponseFromJson(String str) => TokenApiResponse.fromJson(json.decode(str));

String tokenApiResponseToJson(TokenApiResponse data) => json.encode(data.toJson());

class TokenApiResponse {
  final int statusCode;
  final Body body;
  final TokenApiResponseHeaders headers;
  final Request request;

  TokenApiResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.request,
  });

  TokenApiResponse copyWith({
    int? statusCode,
    Body? body,
    TokenApiResponseHeaders? headers,
    Request? request,
  }) =>
      TokenApiResponse(
        statusCode: statusCode ?? this.statusCode,
        body: body ?? this.body,
        headers: headers ?? this.headers,
        request: request ?? this.request,
      );

  factory TokenApiResponse.fromJson(Map<String, dynamic> json) => TokenApiResponse(
    statusCode: json["statusCode"],
    body: Body.fromJson(json["body"]),
    headers: TokenApiResponseHeaders.fromJson(json["headers"]),
    request: Request.fromJson(json["request"]),
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "body": body.toJson(),
    "headers": headers.toJson(),
    "request": request.toJson(),
  };
}

class Body {
  final String accessToken;
  final int expiresIn;
  final String tokenType;
  final String scope;
  final String consentValidTill;
  final String digilockerid;
  final String name;
  final String dob;
  final String gender;
  final String eaadhaar;
  final String referenceKey;
  final String mobile;
  final String refreshToken;
  final String newAccount;

  Body({
    required this.accessToken,
    required this.expiresIn,
    required this.tokenType,
    required this.scope,
    required this.consentValidTill,
    required this.digilockerid,
    required this.name,
    required this.dob,
    required this.gender,
    required this.eaadhaar,
    required this.referenceKey,
    required this.mobile,
    required this.refreshToken,
    required this.newAccount,
  });

  Body copyWith({
    String? accessToken,
    int? expiresIn,
    String? tokenType,
    String? scope,
    String? consentValidTill,
    String? digilockerid,
    String? name,
    String? dob,
    String? gender,
    String? eaadhaar,
    String? referenceKey,
    String? mobile,
    String? refreshToken,
    String? newAccount,
  }) =>
      Body(
        accessToken: accessToken ?? this.accessToken,
        expiresIn: expiresIn ?? this.expiresIn,
        tokenType: tokenType ?? this.tokenType,
        scope: scope ?? this.scope,
        consentValidTill: consentValidTill ?? this.consentValidTill,
        digilockerid: digilockerid ?? this.digilockerid,
        name: name ?? this.name,
        dob: dob ?? this.dob,
        gender: gender ?? this.gender,
        eaadhaar: eaadhaar ?? this.eaadhaar,
        referenceKey: referenceKey ?? this.referenceKey,
        mobile: mobile ?? this.mobile,
        refreshToken: refreshToken ?? this.refreshToken,
        newAccount: newAccount ?? this.newAccount,
      );

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    accessToken: json["access_token"],
    expiresIn: json["expires_in"],
    tokenType: json["token_type"],
    scope: json["scope"],
    consentValidTill: json["consent_valid_till"],
    digilockerid: json["digilockerid"],
    name: json["name"],
    dob: json["dob"],
    gender: json["gender"],
    eaadhaar: json["eaadhaar"],
    referenceKey: json["reference_key"],
    mobile: json["mobile"],
    refreshToken: json["refresh_token"],
    newAccount: json["new_account"],
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "expires_in": expiresIn,
    "token_type": tokenType,
    "scope": scope,
    "consent_valid_till": consentValidTill,
    "digilockerid": digilockerid,
    "name": name,
    "dob": dob,
    "gender": gender,
    "eaadhaar": eaadhaar,
    "reference_key": referenceKey,
    "mobile": mobile,
    "refresh_token": refreshToken,
    "new_account": newAccount,
  };
}

class TokenApiResponseHeaders {
  final String date;
  final String contentType;
  final String transferEncoding;
  final String connection;
  final String server;
  final String vary;
  final String cacheControl;
  final String pragma;
  final String expires;
  final String accessControlAllowHeaders;
  final String xXssProtection;
  final String xContentTypeOptions;
  final String referrerPolicy;
  final String strictTransportSecurity;

  TokenApiResponseHeaders({
    required this.date,
    required this.contentType,
    required this.transferEncoding,
    required this.connection,
    required this.server,
    required this.vary,
    required this.cacheControl,
    required this.pragma,
    required this.expires,
    required this.accessControlAllowHeaders,
    required this.xXssProtection,
    required this.xContentTypeOptions,
    required this.referrerPolicy,
    required this.strictTransportSecurity,
  });

  TokenApiResponseHeaders copyWith({
    String? date,
    String? contentType,
    String? transferEncoding,
    String? connection,
    String? server,
    String? vary,
    String? cacheControl,
    String? pragma,
    String? expires,
    String? accessControlAllowHeaders,
    String? xXssProtection,
    String? xContentTypeOptions,
    String? referrerPolicy,
    String? strictTransportSecurity,
  }) =>
      TokenApiResponseHeaders(
        date: date ?? this.date,
        contentType: contentType ?? this.contentType,
        transferEncoding: transferEncoding ?? this.transferEncoding,
        connection: connection ?? this.connection,
        server: server ?? this.server,
        vary: vary ?? this.vary,
        cacheControl: cacheControl ?? this.cacheControl,
        pragma: pragma ?? this.pragma,
        expires: expires ?? this.expires,
        accessControlAllowHeaders: accessControlAllowHeaders ?? this.accessControlAllowHeaders,
        xXssProtection: xXssProtection ?? this.xXssProtection,
        xContentTypeOptions: xContentTypeOptions ?? this.xContentTypeOptions,
        referrerPolicy: referrerPolicy ?? this.referrerPolicy,
        strictTransportSecurity: strictTransportSecurity ?? this.strictTransportSecurity,
      );

  factory TokenApiResponseHeaders.fromJson(Map<String, dynamic> json) => TokenApiResponseHeaders(
    date: json["date"],
    contentType: json["content-type"],
    transferEncoding: json["transfer-encoding"],
    connection: json["connection"],
    server: json["server"],
    vary: json["vary"],
    cacheControl: json["cache-control"],
    pragma: json["pragma"],
    expires: json["expires"],
    accessControlAllowHeaders: json["access-control-allow-headers"],
    xXssProtection: json["x-xss-protection"],
    xContentTypeOptions: json["x-content-type-options"],
    referrerPolicy: json["referrer-policy"],
    strictTransportSecurity: json["strict-transport-security"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "content-type": contentType,
    "transfer-encoding": transferEncoding,
    "connection": connection,
    "server": server,
    "vary": vary,
    "cache-control": cacheControl,
    "pragma": pragma,
    "expires": expires,
    "access-control-allow-headers": accessControlAllowHeaders,
    "x-xss-protection": xXssProtection,
    "x-content-type-options": xContentTypeOptions,
    "referrer-policy": referrerPolicy,
    "strict-transport-security": strictTransportSecurity,
  };
}

class Request {
  final Uri uri;
  final String method;
  final RequestHeaders headers;

  Request({
    required this.uri,
    required this.method,
    required this.headers,
  });

  Request copyWith({
    Uri? uri,
    String? method,
    RequestHeaders? headers,
  }) =>
      Request(
        uri: uri ?? this.uri,
        method: method ?? this.method,
        headers: headers ?? this.headers,
      );

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    uri: Uri.fromJson(json["uri"]),
    method: json["method"],
    headers: RequestHeaders.fromJson(json["headers"]),
  );

  Map<String, dynamic> toJson() => {
    "uri": uri.toJson(),
    "method": method,
    "headers": headers.toJson(),
  };
}

class RequestHeaders {
  final String accept;
  final String contentType;
  final int contentLength;

  RequestHeaders({
    required this.accept,
    required this.contentType,
    required this.contentLength,
  });

  RequestHeaders copyWith({
    String? accept,
    String? contentType,
    int? contentLength,
  }) =>
      RequestHeaders(
        accept: accept ?? this.accept,
        contentType: contentType ?? this.contentType,
        contentLength: contentLength ?? this.contentLength,
      );

  factory RequestHeaders.fromJson(Map<String, dynamic> json) => RequestHeaders(
    accept: json["accept"],
    contentType: json["Content-Type"],
    contentLength: json["content-length"],
  );

  Map<String, dynamic> toJson() => {
    "accept": accept,
    "Content-Type": contentType,
    "content-length": contentLength,
  };
}

class Uri {
  final String protocol;
  final bool slashes;
  final dynamic auth;
  final String host;
  final int port;
  final String hostname;
  final dynamic hash;
  final dynamic search;
  final dynamic query;
  final String pathname;
  final String path;
  final String href;

  Uri({
    required this.protocol,
    required this.slashes,
    required this.auth,
    required this.host,
    required this.port,
    required this.hostname,
    required this.hash,
    required this.search,
    required this.query,
    required this.pathname,
    required this.path,
    required this.href,
  });

  Uri copyWith({
    String? protocol,
    bool? slashes,
    dynamic auth,
    String? host,
    int? port,
    String? hostname,
    dynamic hash,
    dynamic search,
    dynamic query,
    String? pathname,
    String? path,
    String? href,
  }) =>
      Uri(
        protocol: protocol ?? this.protocol,
        slashes: slashes ?? this.slashes,
        auth: auth ?? this.auth,
        host: host ?? this.host,
        port: port ?? this.port,
        hostname: hostname ?? this.hostname,
        hash: hash ?? this.hash,
        search: search ?? this.search,
        query: query ?? this.query,
        pathname: pathname ?? this.pathname,
        path: path ?? this.path,
        href: href ?? this.href,
      );

  factory Uri.fromJson(Map<String, dynamic> json) => Uri(
    protocol: json["protocol"],
    slashes: json["slashes"],
    auth: json["auth"],
    host: json["host"],
    port: json["port"],
    hostname: json["hostname"],
    hash: json["hash"],
    search: json["search"],
    query: json["query"],
    pathname: json["pathname"],
    path: json["path"],
    href: json["href"],
  );

  Map<String, dynamic> toJson() => {
    "protocol": protocol,
    "slashes": slashes,
    "auth": auth,
    "host": host,
    "port": port,
    "hostname": hostname,
    "hash": hash,
    "search": search,
    "query": query,
    "pathname": pathname,
    "path": path,
    "href": href,
  };
}

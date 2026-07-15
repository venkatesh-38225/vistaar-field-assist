import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:re_kyc_mobile_app/models/aggregator_list_res.dart';
import 'package:re_kyc_mobile_app/models/bank_details_resp.dart';
import 'package:re_kyc_mobile_app/models/branch_list_resp.dart';
import 'package:re_kyc_mobile_app/models/dsa_customer_list_res.dart';
import 'package:re_kyc_mobile_app/models/email_otp_response.dart';
import 'package:re_kyc_mobile_app/models/esign_message_model.dart';
import 'package:re_kyc_mobile_app/models/esign_pdf_model.dart';
import 'package:re_kyc_mobile_app/models/loan_details_res.dart';
import 'package:re_kyc_mobile_app/models/login_response.dart';
import 'package:re_kyc_mobile_app/models/onboard_count_resp.dart';
import 'package:re_kyc_mobile_app/models/peniping_acc_validate_res.dart';
import 'package:re_kyc_mobile_app/models/peniping_account_status.dart';
import 'package:re_kyc_mobile_app/models/peniping_create_cus_response.dart';
import 'package:re_kyc_mobile_app/models/peniping_create_fund.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/models/sarfaesi_res.dart';
import 'package:re_kyc_mobile_app/models/foreclosure_details_response.dart';

import '../models/download_legal_notice_file.dart';
import '../models/get_roll_based_modules.dart';
import '../models/notice_type_option.dart';
import '../models/sarfaesi_details_res.dart';
import '../models/uploaded_notice_res.dart';
import '../models/download_notice_res.dart';
import '../models/legal_billing_res.dart';
import '../models/legal_masters.dart';
import '../models/legal_billing_details_res.dart';

class ApiClient {
  final _client = http.Client();
  final tokenUrl = 'https://api.digitallocker.gov.in/public/oauth2/1/token';
  final _timeLimit = const Duration(seconds: 30);
  // final String key = "rzp_test_OYjmMLmTTjvvkb";
  // final String secret = "AmbE6P2IgryNGQ3bABMSDHms";
  final String basicAuth =
      'Basic ${base64Encode(utf8.encode('rzp_live_wttpRiUPLjNEWp:XfOfOV8WuWYsdCPpNDWOc77L'))}';

  // Live
  // final String baseUrl = 'https://productivity.vistaarfinance.net.in:474/api/';
  // final String legalNoticebaseUrl =
  //     'https://vistaarapis.vistaarfinance.net.in:482/api/';

  // UAT
  final String baseUrl = 'https://productivity.vistaarfinance.net.in:473/api/';
  final String legalNoticebaseUrl =
      'https://vistaarapis.vistaarfinance.net.in:480/api/';

  bool get isDevMode => baseUrl.contains(':473');

  Future<Map<String, dynamic>?> appVersionApi(Object jsonObject) async {
    var url = Uri.parse("${baseUrl}VCP/GetAppVersion?Platform=Android");
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    print("Version URL : $url");
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future<LoginResponse?> loginApi(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}login/ValidateLogin');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);
    if (response.statusCode == 200) {
      var responseBody = response.body;
      return LoginResponse.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<ProfileResponse?> profileApi(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}login/GetUserProfile');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;
      return ProfileResponse.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<OnboardCountResp?> onboardCount(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}VCP/GetVCPCountByUser');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;
      return OnboardCountResp.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<GetRoleBasedModuleList?> getModuleByRole(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}login/GetModulesByRole');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);
    if (response.statusCode == 200) {
      var responseBody = response.body;
      return GetRoleBasedModuleList.fromJson(json.decode(responseBody));
    } else {
      print("Json ${jsonDecode(response.body)}");
      var errorMsg = jsonDecode(response.body)["error"];
      return GetRoleBasedModuleList.fromJson({"error": errorMsg});
    }
  }

  Future<LoanDetailsResponse?> getLoanDetailsApi(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}Legalnotice/GetLanDetails');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;
      return LoanDetailsResponse.fromJson(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadLegalNotice(Object jsonObject) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalNotice/upload');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              "x-api-key": "ht9AfQrZmJnu0Gxl"
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future<DownloadLegalNoticeFile?> downloadLegalNotice(
      Object jsonObject) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalNotice/download');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              "x-api-key": "ht9AfQrZmJnu0Gxl"
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;

      return DownloadLegalNoticeFile.fromJson(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<DsaCustomerList?> dsaCustomerListApi(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}VCP/GetVCPListByEmpID');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;

      return DsaCustomerList.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<EmailOtpRes?> emailOtpSend(Object jsonObject) async {
    var url = Uri.parse("${baseUrl}VCP/VerifyVCPEmail");
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;
      return EmailOtpRes.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<EmailOtpRes?> mobileOtpSend(Object jsonObject) async {
    var url = Uri.parse("${baseUrl}VCP/VerifyVCPMobile");
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;
      return EmailOtpRes.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> addAggregatorApi(Object jsonObject) async {
    var url = Uri.parse("${baseUrl}aggregator/AddAggregator");
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> dsaBasicDetApi(Object jsonObject) async {
    var url = Uri.parse("${baseUrl}VCP/AddVCPBasicDetails");
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future<BranchListRes?> branchListApi() async {
    var url = Uri.parse(
        'https://productivity.vistaarfinance.net.in:446/SVC_Lead.svc/GetBranchList');
    final response = await _client
        .post(
          url,
        )
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;

      return BranchListRes.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> dsaBusinessDetApi(Object jsonObject) async {
    var url = Uri.parse("${baseUrl}VCP/AddVCPBusinessDetails");
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future<AggregatorListRes?> aggregatorList(Object jsonObject) async {
    var url = Uri.parse("${baseUrl}aggregator/GetAggregatorsByEmpID");
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;
      return AggregatorListRes.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateAggregatorAPi(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}aggregator/UpdateAggregator');

    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future getTokenApi(Object jsonObject) async {
    var url =
        Uri.parse('https://api.digitallocker.gov.in/public/oauth2/1/token');
    final response = await _client
        .post(url,
            headers: {"Content-Type": "application/json"}, body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
    } else {
      return null;
    }
  }

  Future getOTPDetails(Object jsonObject) async {
    var url = Uri.parse('https://in.staging.decentro.tech/v2/kyc/aadhaar/otp');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              "client_id": "vistaarfinance_staging",
              "client_secret": "loGqbVjBB24qdiUoMFEZOUl5U1T5Vfx6"
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
    } else {
      return null;
    }
  }

  Future getAadhaarDetails(Object jsonObject) async {
    var url = Uri.parse(
        'https://in.staging.decentro.tech/v2/kyc/aadhaar/otp/validate');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              "client_id": "vistaarfinance_staging",
              "client_secret": "loGqbVjBB24qdiUoMFEZOUl5U1T5Vfx6"
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
    } else {
      return null;
    }
  }

  Future getBankDetails(String ifscCode) async {
    var url =
        Uri.parse('${legalNoticebaseUrl}Shared/getIfscDetails/${ifscCode}');
    final response = await _client.get(url, headers: {
      "Content-Type": "application/json",
      "x-api-key": "ht9AfQrZmJnu0Gxl"
    }).timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;
      return BankDetailsResp.fromMap(json.decode(responseBody));
    } else {
      var responseBody = response.body;
      return BankDetailsResp.fromMap(json.decode(responseBody));
    }
  }

  Future createPenipingContact(Object jsonObject) async {
    const String key = "rzp_live_wttpRiUPLjNEWp";
    const String secret = "XfOfOV8WuWYsdCPpNDWOc77L";
    var url = Uri.parse('https://api.razorpay.com/v1/contacts');

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$key:$secret'))}';

    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': basicAuth,
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 201 || response.statusCode == 200) {
      var responseBody = response.body;

      return PenipingCreateCustomer.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future createPenipingFund(Object jsonObject) async {
    var url = Uri.parse('https://api.razorpay.com/v1/fund_accounts');

    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': basicAuth,
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 201) {
      var responseBody = response.body;

      return PenipingCreateFund.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future penipingAccountValidation(Object jsonObject) async {
    var url =
        Uri.parse('https://api.razorpay.com/v1/fund_accounts/validations');

    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': basicAuth,
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;

      return PenipingAccountValidate.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future penipingAccountStatus(String id) async {
    var url =
        Uri.parse('https://api.razorpay.com/v1/fund_accounts/validations/$id');

    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': basicAuth,
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;

      return PenipingAccountStatus.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<List<NoticeTypeOption>?> getNoticeTypesOptions() async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalNotice/getNoticeTypes');

    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return (responseBody['data'] as List)
            .map((e) => NoticeTypeOption.fromJson(e))
            .toList();
      }
      return responseBody;
    } else {
      return null;
    }
  }

  Future<dynamic> getLanNoticeDetails(String lan) async {
    var url = Uri.parse('${legalNoticebaseUrl}shared/getLanDetails/${lan}');

    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody['success'] == true && responseBody['data'] != null) {
        var data = responseBody['data'];
        return LoanDetailsResponse(
          lan: data['lan']?.toString(),
          fullName: data['custName']?.toString(),
          custId: data['custId']?.toString(),
          totalOutstanding: data['totalOutstanding']?.toString(),
          dpd: data['dpd']?.toString(),
          mobile: data['mobile']?.toString(),
          alternateMobile: data['alternateMobile']?.toString(),
          residentialAddress: data['residentialAddress']?.toString(),
          propertyAddress: data['propertyAddress']?.toString(),
          branch: Branch(
            branchCode: data['branchCode']?.toString(),
            branchName: data['branchName']?.toString(),
            region: data['region']?.toString(),
            zone: data['zone']?.toString(),
            megaZone: data['megaZone']?.toString(),
          ),
          pos: (data['principalOutstanding'] as num?)?.toDouble(),
          legal: data['legal'] != null ? Legal.fromJson(data['legal']) : null,
        );
      }
      return responseBody['message'];
    } else {
      var responseBody = json.decode(response.body);

      return responseBody;
    }
  }

  Future<ForeClosureDetailsResponse?> getForeClosureDetails(String lan) async {
    var url =
        Uri.parse('${legalNoticebaseUrl}shared/getForeclosureStatement/${lan}');

    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        var data = responseBody['data'];
        return ForeClosureDetailsResponse(
          lan: data['lan']?.toString(),
          fullName: data['custName']?.toString(),
          custId: data['custId']?.toString(),
          totalOutstanding: data['totalOutstandingExclFc']?.toString(),
          dpd: data['dpd']?.toString(),
          mobile: data['mobile']?.toString(),
          alternateMobile: data['alternateMobile']?.toString(),
          residentialAddress: data['residentialAddress']?.toString(),
          propertyAddress: data['propertyAddress']?.toString(),
          branch: Branch(
            branchCode: data['branchCode']?.toString(),
            branchName: data['branchName']?.toString(),
            region: data['region']?.toString(),
            zone: data['zone']?.toString(),
            megaZone: data['megaZone']?.toString(),
          ),
          pos: (data['pos'] as num?)?.toDouble(),
          legal: data['legal'] != null ? Legal.fromJson(data['legal']) : null,
        );
      }
      return null;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> vcpUploadDoc(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}VCP/UploadVCPFile');

    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> vcpBankDetails(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}VCP/AddVCPBankDetails');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;

      Map<String, dynamic> value = json.decode(responseBody);
      return value;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateDocStatus(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}VCP/UpdateDocUploadStatus');

    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future getESignPDF(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}DigiSign/GetVCPsignDoc');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      var responseBody = response.body;

      return ESignPdfModel.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future enableESignMessage(Object jsonObject) async {
    var url =
        Uri.parse('https://ext.digio.in:444/v2/client/document/uploadpdf');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
              "Authorization":
                  "Basic QUlIUUo3Q0g3U05DQ0ZaQUtFSEg5VjhTODJMSkFTRFU6N09EQ1ZZTU5KTlJTREFXSjg2Mk5CSVVFWEM5RVJFQ0g="
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = response.body;

      return ESignMessageModel.fromMap(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> initiateESignApi(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}DigiSign/InitiateESign');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  //To get VCP file
  Future<Map<String, dynamic>?> getVCPFile(Object jsonObject) async {
    var url = Uri.parse('${baseUrl}VCP/GetVCPFile');
    final response = await _client
        .post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonObject)
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      return null;
    }
  }

  Future<UploadedNoticeResponse?> getUploadedNotices(String lan) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalNotice/${lan}');

    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      return UploadedNoticeResponse.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<DownloadNoticeResponse?> postDownloadNotice(Object jsonObject) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalNotice/download');

    final response = await _client
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "x-api-key": "ht9AfQrZmJnu0Gxl"
          },
          body: jsonObject,
        )
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      return DownloadNoticeResponse.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<LegalBillingResponse?> getLegalBillingByUser(
      String userId, String status, String role) async {
    var url = Uri.parse(
        '${legalNoticebaseUrl}LegalBilling/getByUser?UserId=$userId&Status=$status&Role=$role');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      return LegalBillingResponse.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<List<Advocate>?> getAllAdvocates() async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalBilling/advocates/getAll');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return (responseBody['data'] as List)
            .map((e) => Advocate.fromJson(e))
            .toList();
      }
    }
    return null;
  }

  Future<List<LegalCategory>?> getAllLegalCategories() async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalBilling/category/getAll');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return (responseBody['data'] as List)
            .map((e) => LegalCategory.fromJson(e))
            .toList();
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> createLegalBilling(Object jsonObject) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalBilling/create');
    final response = await _client
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "x-api-key": "ht9AfQrZmJnu0Gxl"
          },
          body: jsonObject,
        )
        .timeout(_timeLimit);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return json.decode(response.body);
    }
  }

  Future<LegalBillingDetailsResponse?> getLegalBillingById(int id) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalBilling/getById/$id');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      return LegalBillingDetailsResponse.fromJson(json.decode(response.body));
    } else {
      return json.decode(response.body);
    }
  }

  Future<Map<String, dynamic>?> updateLegalBillingStatus(
      Object jsonObject) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalBilling/updateStatus');
    final response = await _client
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "x-api-key": "ht9AfQrZmJnu0Gxl"
          },
          body: jsonObject,
        )
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return json.decode(response.body);
    }
  }

  Future<Map<String, dynamic>?> updateLegalBillingPayment(
      Object jsonObject) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalBilling/updatePayment');
    final response = await _client
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "x-api-key": "ht9AfQrZmJnu0Gxl"
          },
          body: jsonObject,
        )
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return json.decode(response.body);
    }
  }

  Future<Map<String, dynamic>?> resubmitLegalBilling(Object jsonObject) async {
    var url = Uri.parse('${legalNoticebaseUrl}LegalBilling/resubmit');
    final response = await _client
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "x-api-key": "ht9AfQrZmJnu0Gxl"
          },
          body: jsonObject,
        )
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return json.decode(response.body);
    }
  }

  Future<http.Response?> downloadLegalBillingFile(String fileName) async {
    var url = Uri.parse(
        '${legalNoticebaseUrl}LegalBilling/downloadFile?fileName=$fileName');
    try {
      final response = await _client.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-api-key": "ht9AfQrZmJnu0Gxl"
        },
      ).timeout(_timeLimit);

      if (response.statusCode == 200) {
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print("Error downloading file: $e");
      return null;
    }
  }

  //SARFAESI API's

  Future<SarfaesiResponse?> getSarfaesiList(
      String userId, String status, String role) async {
    var url = Uri.parse(
        '${legalNoticebaseUrl}SARFAESI/getByUser?UserId=$userId&Status=$status&Role=$role');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      return SarfaesiResponse.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> createSarfaesi(
      Map<String, dynamic> jsonObject) async {
    final url = Uri.parse('${legalNoticebaseUrl}SARFAESI/create');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "x-api-key": "ht9AfQrZmJnu0Gxl",
            },
            body: jsonEncode(jsonObject),
          )
          .timeout(_timeLimit);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": responseData,
      };
    } catch (e) {
      print("SARFAESI API ERROR: $e");

      return {
        "statusCode": 500,
        "data": {
          "message": e.toString(),
        }
      };
    }
  }

  Future<Map<String, dynamic>?> submitSarfaesi(
      Map<String, dynamic> jsonObject) async {
    final url = Uri.parse('${legalNoticebaseUrl}SARFAESI/submit');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "x-api-key": "ht9AfQrZmJnu0Gxl",
            },
            body: jsonEncode(jsonObject),
          )
          .timeout(_timeLimit);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": responseData,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "message": e.toString(),
        }
      };
    }
  }

  Future<SarfaesiDetailsResponse?> getSarfaesiById(int id) async {
    var url = Uri.parse('${legalNoticebaseUrl}SARFAESI/getById/$id');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      return SarfaesiDetailsResponse.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCollateralsByLan(String lan) async {
    var url = Uri.parse('${legalNoticebaseUrl}Shared/getCollateralsByLan/$lan');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": responseData,
      };
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateSarfaesiStatus(
      Object jsonObject, dynamic reqId) async {
    var url = Uri.parse('${legalNoticebaseUrl}SARFAESI/update/$reqId');
    final response = await _client
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "x-api-key": "ht9AfQrZmJnu0Gxl"
          },
          body: jsonObject,
        )
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadSarfaesiFile({
    required int reqId,
    required String fileType,
    required File file,
    required String createdBy,
  }) async {
    try {
      final url = Uri.parse(
        '${legalNoticebaseUrl}SARFAESI/uploadFile',
      );

      var request = http.MultipartRequest(
        'POST',
        url,
      );

      request.headers.addAll({
        'x-api-key': 'ht9AfQrZmJnu0Gxl',
        'accept': '*/*',
      });

      request.fields['ReqId'] = reqId.toString();
      request.fields['FileType'] = fileType;
      request.fields['CreatedBy'] = createdBy;

      request.files.add(
        await http.MultipartFile.fromPath(
          'File',
          file.path,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      print('UPLOAD STATUS: ${response.statusCode}');
      print('UPLOAD RESPONSE: ${response.body}');

      // Server may return an HTML error page (e.g. 413 Too Large) instead of
      // JSON — guard against FormatException by trying to decode safely.
      dynamic responseData;

      try {
        responseData = json.decode(response.body);
      } catch (e) {
        responseData = {"message": response.body};
      }

      return {
        "statusCode": response.statusCode,
        "data": responseData,
      };
    } catch (e) {
      print("UPLOAD ERROR: $e");

      return {
        "statusCode": 500,
        "data": {
          "message": e.toString(),
        }
      };
    }
  }

  Future<List<String>?> getMappedLans(String empId) async {
    var url =
        Uri.parse('${legalNoticebaseUrl}SARFAESI/getMappedLans?empId=$empId');
    final response = await _client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "ht9AfQrZmJnu0Gxl"
      },
    ).timeout(_timeLimit);

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("Response: ${responseBody}");
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return (responseBody['data'] as List).map((e) => e.toString()).toList();
      }
    }
    return null;
  }

  Future<http.Response?> downloadSarfaesiFile(String fileName) async {
    try {
      final url = Uri.parse(
        '${legalNoticebaseUrl}SARFAESI/downloadFile?fileName=${Uri.encodeComponent(fileName)}',
      );
      final response = await _client.get(
        url,
        headers: {
          'accept': '*/*',
          'x-api-key': 'ht9AfQrZmJnu0Gxl',
        },
      ).timeout(_timeLimit);

      if (response.statusCode == 200) {
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print('downloadSarfaesiFile error: $e');
      return null;
    }
  }
}

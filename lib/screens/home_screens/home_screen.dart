import 'dart:convert';
import 'dart:developer';
// import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/controllers/vcp_application_controller.dart';
import 'package:re_kyc_mobile_app/models/onboard_count_resp.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/screens/connectors/completed_connectors_list.dart';
import 'package:re_kyc_mobile_app/screens/connectors/pending_connectors_list.dart';
import 'package:re_kyc_mobile_app/screens/home_screens/onboaring_screen.dart';
import 'package:re_kyc_mobile_app/screens/legal_notice/legal_notice_screen.dart';
import 'package:re_kyc_mobile_app/screens/login_screens/login_screen.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/completed_aggregators.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/visited_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/pending_aggregators_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/onboard_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/add_appraiser.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/completed_dsa_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/vcp_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/pending_dsa_list.dart';
import 'package:re_kyc_mobile_app/screens/legal_billing/legal_billing_screen.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/sarfaesi_modules_screen.dart';
import 'package:re_kyc_mobile_app/screens/voice_of_team/voice_of_team_screen.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/service/hive_local_storage.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/floating_action_button/speed_dial_child.dart';

import '../../models/get_roll_based_modules.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:re_kyc_mobile_app/route_observer.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/*CarouselSliderController carouselController = CarouselSliderController();
List<String> dashboardImages = [
  'assets/images/dashboard_1.png',
  'assets/images/dashboard_2.png',
  'assets/images/dashboard_3.png',
  'assets/images/dashboard_4.png',
];*/

// class _HomeScreenState extends State<HomeScreen> {
class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  HiveDataBase storeData = HiveDataBase();
  String? employeeId;
  ProfileResponse? profileResponse;
  //Count? onboardCount;
  //var selectedFABLocation = FloatingActionButtonLocation.endFloat;
  //var mini = false;
  //var isDialOpen = ValueNotifier<bool>(false);
  //var renderOverlay = true;
  //var visible = true;
  //var switchLabelPosition = false;
  var extend = false;
  var rmIcons = false;
  // var customDialRoot = false;
  // var closeManually = false;
  // var useRAnimation = true;
  // var speedDialDirection = SpeedDialDirection.up;
  /* var buttonSize = const Size(56.0, 56.0);
  var childrenButtonSize = const Size(56.0, 56.0);*/
  /* var items = [
    FloatingActionButtonLocation.startFloat,
    FloatingActionButtonLocation.startDocked,
    FloatingActionButtonLocation.centerFloat,
    FloatingActionButtonLocation.endFloat,
    FloatingActionButtonLocation.endDocked,
    FloatingActionButtonLocation.startTop,
    FloatingActionButtonLocation.centerTop,
    FloatingActionButtonLocation.endTop,
  ];*/
  final VcpApplicationController vcpController =
      Get.put(VcpApplicationController());
  /* List<Map<String, dynamic>> otherMenuItems = [];
  List<Map<String, dynamic>> completedMenuItems = [];
  List<Map<String, dynamic>> pendingMenuItems = [];
  List<SpeedDialChild> fabChildren = [];*/
  bool isOnBoardingMenuAvailable = false;
  bool isLegalNoticeMenuAvailable = false;
  bool isLegalBillingMenuAvailable = false;
  bool isSARFAESIMenuAvailable = false;
  bool isVoiceOfTeamMenuAvailable = false;
  List<GetRoleBasedModule> sarfaesiModules = [];
  bool isLoading = false;
  String currentVersion = '';
  String legalBillingAccess = '';
  String legalNoticeAccess = '';
  String voiceOfTeamAccess = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    checkAppVersion(); // Called when returning to this screen
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAppVersion();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      employeeId = HiveDataBase().getEmployeeId();
    });
    isLoading = true;
    callProfileApi();
    checkAppVersion();
    _getAppVersion();
    // callOnboardCount();
  }

  void _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        currentVersion = packageInfo.version;
      });
    } catch (e) {
      print("Error $e");
    }
  }

  void fetchMenuItems(List<String> modules) {
    // String employeeId = profileResponse?.data?.employeeId ?? '';
    // String branchCode = profileResponse?.data?.branchCode ?? '';

    // List<Map<String, dynamic>> fetchedCompletedMenuItems = [];
    // List<Map<String, dynamic>> fetchedPendingMenuItems = [];

    final normalizedModules =
        modules.map((e) => e.trim().toUpperCase()).toList();
    isOnBoardingMenuAvailable = normalizedModules.contains("VCP");
    isLegalNoticeMenuAvailable = normalizedModules.contains("LEGAL NOTICE");
    isLegalBillingMenuAvailable = normalizedModules.contains("LEGAL BILLING");
    isSARFAESIMenuAvailable = sarfaesiModules.isNotEmpty;
    isVoiceOfTeamMenuAvailable = normalizedModules.contains("VOICE OF TEAM");
  }

  List<SpeedDialChild> addDefaultSpeedDialMenu() {
    String employeeId = profileResponse?.data?.employeeId ?? '';
    String branchCode = profileResponse?.data?.branchCode ?? '';
    return [
      SpeedDialChild(
        child: !rmIcons ? const Icon(Icons.person) : null,
        backgroundColor: Constant.lightBlueColor,
        foregroundColor: Colors.white,
        labelBackgroundColor: Constant.lightBlueColor,
        label: 'Add Aggregator',
        labelStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        onTap: () {
          Get.to(() => OnboardApplication(
                employeeId: employeeId,
                branchCode: branchCode,
              ));
        },
      ),
      SpeedDialChild(
        child: !rmIcons ? const Icon(Icons.account_tree) : null,
        backgroundColor: Constant.lightBlueColor,
        foregroundColor: Colors.white,
        labelBackgroundColor: Constant.lightBlueColor,
        label: 'Add Connector',
        labelStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        onTap: () {
          Get.to(() => VCPApplication(
                onboardType: 'Connector',
                employeeId: employeeId,
                branchCode: branchCode,
              ));
        },
      ),
      SpeedDialChild(
        child: !rmIcons ? const Icon(Icons.edit_note) : null,
        backgroundColor: Constant.lightBlueColor,
        foregroundColor: Colors.white,
        labelBackgroundColor: Constant.lightBlueColor,
        label: 'Add DSA',
        labelStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        onTap: () {
          Get.to(() => VCPApplication(
                onboardType: 'DSA',
                employeeId: employeeId,
                branchCode: branchCode,
              ));
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    //Widget _buildHomeContainerWidget(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: _buildHomeContainerWidget(context),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  //@override
  //Widget build(BuildContext context) {
  Widget _buildHomeContainerWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Constant.darkBlueColor, Constant.lightBlueColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/vistaar_logo_new.png', height: 50),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentVersion.isNotEmpty) ...[
                  Text(
                    'v$currentVersion',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog(context);
                    }
                  },
                  icon: const ImageIcon(
                    AssetImage('assets/icons/menu.png'),
                    color: Colors.white,
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshHome,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // color: Colors.blue.shade50,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Section
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Constant.lightBlueColor,
                                radius: 25,
                                child: Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profileResponse == null
                                        ? ''
                                        : '${profileResponse!.data!.username}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  // const SizedBox(height: 3),
                                  Text(
                                    profileResponse == null
                                        ? ''
                                        : '${profileResponse!.data!.email}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    profileResponse == null
                                        ? ''
                                        : '${profileResponse!.data!.jobTitle}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(
                            height: 32,
                            thickness: 1,
                            color: Colors.grey,
                          ),

                          // Gender, Age, and DOB Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDetailTile(
                                icon: Icons.mail_outline,
                                title: 'Employee Id',
                                value: profileResponse == null
                                    ? ''
                                    : '${profileResponse!.data!.employeeId}',
                              ),
                              _buildDetailTile(
                                icon: Icons.call,
                                title: 'Contact',
                                value: profileResponse == null
                                    ? ''
                                    : '${profileResponse!.data!.mobile}',
                              ),
                              _buildDetailTile(
                                icon: Icons.home_work_outlined,
                                title: 'Department',
                                value: profileResponse == null
                                    ? ''
                                    : "${profileResponse!.data!.department}",
                                // : "${profileResponse!.data!.department!.split("&")[0]}\n&${profileResponse!.data!.department!.split("&")[1]}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  /*Row(
                children: [
                  Expanded(
                    child: iconLeftCenterTextButton(
                      assetPath: 'assets/icons/onboarding_icon.png',
                      label: "External\nOnboarding",
                      onPressed: () {
                        print("Button pressed");
                      },
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: iconLeftCenterTextButton(
                      assetPath: 'assets/icons/legal_notice_icon.png',
                      label: "Legal\nNotice",
                      onPressed: () {
                        print("Button pressed");
                      },
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),*/
                  const SizedBox(
                    height: 25,
                  ),
                  isOnBoardingMenuAvailable == true
                      ? menuButton(
                          assetPath: 'assets/icons/onboarding.png',
                          label: "External Onboarding",
                          onPressed: () {
                            Get.to(() => const OnBoardingScreen());
                          },
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 5),
                          backgroundColor: Colors.white,
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                  const SizedBox(
                    height: 5,
                  ),
                  isLegalNoticeMenuAvailable == true
                      ? menuButton(
                          assetPath: 'assets/icons/legal_notice.png',
                          label: "Legal Notice",
                          onPressed: () {
                            String employeeIdData =
                                profileResponse?.data?.employeeId ?? '';
                            String branchCodeData =
                                profileResponse?.data?.branchCode ?? '';
                            //Get.to(() => TestScreen());
                            Get.to(() => LegalNoticeScreen(
                                employeeId: employeeIdData,
                                branchCode: branchCodeData));
                          },
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 5),
                          backgroundColor: Colors.white,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  isLegalBillingMenuAvailable == true
                      ? menuButton(
                          assetPath: 'assets/icons/legal_billing.png',
                          label: "Legal Billing",
                          onPressed: () {
                            if (profileResponse != null) {
                              Get.to(() => LegalBillingScreen(
                                    profile: profileResponse!,
                                    access: legalBillingAccess,
                                  ));
                            }
                          },
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 5),
                          backgroundColor: Colors.white,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  isSARFAESIMenuAvailable == true
                      ? menuButton(
                          assetPath: 'assets/icons/sarfaesi.png',
                          label: "SARFAESI",
                          onPressed: () {
                            if (profileResponse != null) {
                              Get.to(() => SarfaesiModulesScreen(
                                  profile: profileResponse!,
                                  modules: sarfaesiModules));
                            }
                          },
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 5),
                          backgroundColor: Colors.white,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  isVoiceOfTeamMenuAvailable == true
                      ? menuButton(
                          assetPath: 'assets/icons/voice_of_team.png',
                          label: "Voice of Team",
                          onPressed: () {
                            if (profileResponse != null) {
                              Get.to(() => VoiceOfTeamScreen(
                                    profile: profileResponse!,
                                    access: voiceOfTeamAccess,
                                  ));
                            }
                          },
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 5),
                          backgroundColor: Colors.white,
                        )
                      : const SizedBox(
                          height: 0,
                        ),

                  /* const SizedBox(height: 20),
              completedMenuItems.isEmpty
                  ? SizedBox()
                  : const Text(
                'Completed Onboarding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constant.mediumBlueColor,
                ),
              ),
              const SizedBox(height: 5),
              completedMenuItems.isEmpty
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : Container(
                width: double.infinity,
                child: Wrap(
                  runSpacing: 5,
                  children: completedMenuItems.map((item) {
                    return InkWell(
                      onTap: item['onTap'] != null
                          ? () => item['onTap']()
                          : null,
                      child: SizedBox(
                        height: 80,
                        width: item['width'] == "m" ? 125 : 145,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(item['icon'],
                                        size: 16,
                                        color: Constant.lightBlueColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      item['label'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Constant.lightBlueColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item['count'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              pendingMenuItems.isEmpty
                  ? SizedBox()
                  : const Text(
                'Pending Onboarding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constant.mediumBlueColor,
                ),
              ),
              const SizedBox(height: 5),
              pendingMenuItems.isEmpty
                  ? SizedBox()
                  : Container(
                width: double.infinity,
                child: Wrap(
                  runSpacing: 5,
                  children: pendingMenuItems.map((item) {
                    return SizedBox(
                      height: 80,
                      width: item['width'] == "m" ? 125 : 145,
                      child: InkWell(
                        onTap: item['onTap'] != null
                            ? () => item['onTap']()
                            : null,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(item['icon'],
                                        size: 16,
                                        color: Constant.lightBlueColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      item['label'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Constant.lightBlueColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item['count'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),*/

                  /*const SizedBox(height: 20),
              const Text(
                'Completed Onboarding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constant.mediumBlueColor,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => CompletedAggregators(
                          employeeId: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.employeeId}'));
                    },
                    child: SizedBox(
                      height: 80,
                      width: 125,
                      child: Card(
                        // color: Constant.mediumBlueColor,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  // SizedBox(width: 5),
                                  Icon(
                                    Icons.groups,
                                    size: 16,
                                    // color: Colors.black87,
                                    color: Constant.lightBlueColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Aggregator',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black87,
                                      color: Constant.lightBlueColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                onboardCount != null
                                    ? onboardCount!.aggregatorCompleted!
                                        .toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  // color: Constant.lightBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => VcpCompletedList(
                          employeeId: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.employeeId}'));
                    },
                    child: SizedBox(
                      height: 80,
                      width: 125,
                      child: Card(
                        // color: Constant.mediumBlueColor,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  SizedBox(width: 20),
                                  Icon(
                                    Icons.edit_road_sharp,
                                    size: 16,
                                    // color: Colors.black87,
                                    color: Constant.lightBlueColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'DSA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black87,
                                      color: Constant.lightBlueColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                onboardCount != null
                                    ? onboardCount!.dsACompleted!.toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  // color: Constant.lightBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => CompletedConnectors(
                          employeeId: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.employeeId}'));
                    },
                    child: SizedBox(
                      height: 80,
                      width: 125,
                      child: Card(
                        // color: Constant.mediumBlueColor,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  // SizedBox(width: 5),
                                  Icon(
                                    Icons.edit_note_sharp,
                                    size: 16,
                                    // color: Colors.black87,
                                    color: Constant.lightBlueColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Connectors',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black87,
                                      color: Constant.lightBlueColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                onboardCount != null
                                    ? onboardCount!.connectorCompleted!
                                        .toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  // color: Constant.lightBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Pending Onboarding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constant.mediumBlueColor,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => AggregatorList(
                          employeeId: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.employeeId}',
                          branchCode: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.branchCode}'));
                    },
                    child: SizedBox(
                      height: 80,
                      width: 125,
                      child: Card(
                        // color: Constant.mediumBlueColor,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.groups,
                                    size: 16,
                                    // color: Colors.black87,
                                    color: Constant.lightBlueColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'visits',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black87,
                                      color: Constant.lightBlueColor,
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 5),
                              Text(
                                onboardCount != null
                                    ? onboardCount!.aggregatorVisit!.toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  // color: Constant.lightBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => VcpList(
                          employeeId: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.employeeId}'));
                    },
                    child: SizedBox(
                      height: 80,
                      width: 125,
                      child: Card(
                        // color: Constant.mediumBlueColor,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  SizedBox(width: 20),
                                  Icon(
                                    Icons.edit_road_sharp,
                                    size: 16,
                                    // color: Colors.black87,
                                    color: Constant.lightBlueColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'DSA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black87,
                                      color: Constant.lightBlueColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                onboardCount != null
                                    ? onboardCount!.dsAPending!.toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  // color: Constant.lightBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => ConnectorsList(
                          employeeId: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.employeeId}'));
                    },
                    child: SizedBox(
                      height: 80,
                      width: 125,
                      child: Card(
                        // color: Constant.mediumBlueColor,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  // SizedBox(width: 5),
                                  Icon(
                                    Icons.edit_note_sharp,
                                    size: 16,
                                    // color: Colors.black87,
                                    color: Constant.lightBlueColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Connectors',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black87,
                                      color: Constant.lightBlueColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                onboardCount != null
                                    ? onboardCount!.connectorPending!.toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  // color: Constant.lightBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => AggregatorsPendingList(
                          employeeId: profileResponse == null
                              ? ''
                              : '${profileResponse!.data!.employeeId}'));
                    },
                    child: SizedBox(
                      height: 80,
                      width: 125,
                      child: Card(
                        // color: Constant.mediumBlueColor,
                        color: Colors.white,
                        // margin: EdgeInsets.only(right: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 10),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  // SizedBox(width: 5),
                                  Icon(
                                    Icons.groups,
                                    size: 16,
                                    // color: Colors.black87,
                                    color: Constant.lightBlueColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Aggregators',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black87,
                                      color: Constant.lightBlueColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                onboardCount != null
                                    ? onboardCount!.aggregatorPending!
                                        .toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  // color: Constant.lightBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),*/
                  const SizedBox(height: 30),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: 'Scroll down to refresh the screen',
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.arrow_downward_sharp,
                        size: 10,
                        color: Colors.grey,
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  /*   Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAverageCard(
                        color: Colors.purpleAccent,
                        title: 'Aggregators',
                        value: '130',
                        icon: Icons.people,
                      ),
                      const SizedBox(height: 10),
                      _buildAverageCard(
                        color: Colors.orangeAccent,
                        title: 'Re-KYC',
                        value: '250',
                        icon: Icons.edit_road_sharp,
                      ),

                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAverageCard(
                        color: Colors.green,
                        title: 'VCP',
                        value: '180',
                        icon: Icons.app_registration_sharp,
                      ),
                      const SizedBox(height: 10),
                      _buildAverageCard(
                        color: Colors.red,
                        title: 'Total',
                        value: '560',
                        icon: Icons.groups,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Onboarding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constant.mediumBlueColor,
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                // padding: const EdgeInsets.all(16),
                childAspectRatio: 1.7,
                children: [
                  InkWell(
                      onTap: () {
                        Get.to(() => const AggregatorList());
                      },
                      child: const DashboardCard(
                          title: 'Onboard Aggregators',
                          color: Constant.lightBlueColor,
                          // color:Colors.blue,
                          // color: Color(0xFFecb459),
                          icon: Icons.group)),
                  InkWell(
                    onTap: () {
                      Get.to(() => const VcpList());
                    },
                    child: const DashboardCard(
                        title: 'Onboard VCP',
                        color: Constant.lightBlueColor,
                        // color:Colors.blue,
                        // color: Color(0xFFfaa61a),
                        icon: Icons.business),
                  ),
                ],
              ),*/
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Constant.lightBlueColor,
              ),
            ),
        ],
      ),
      /*floatingActionButtonLocation: selectedFABLocation,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        mini: mini,
        openCloseDial: isDialOpen,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        dialRoot: customDialRoot
            ? (ctx, open, toggleChildren) {
          return ElevatedButton(
            onPressed: toggleChildren,
            style: ElevatedButton.styleFrom(
              backgroundColor: Constant.mediumYellowColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 18,
              ),
            ),
            child: const Text(
              "Custom Dial Root",
              style: TextStyle(fontSize: 17),
            ),
          );
        }
            : null,
        buttonSize: buttonSize,
        label: extend ? const Text("Open") : null,
        activeLabel: extend ? const Text("Close") : null,
        childrenButtonSize: childrenButtonSize,
        visible: visible,
        direction: speedDialDirection,
        switchLabelPosition: switchLabelPosition,
        closeManually: closeManually,
        renderOverlay: renderOverlay,
        onOpen: () => debugPrint('OPENING DIAL'),
        onClose: () => debugPrint('DIAL CLOSED'),
        useRotationAnimation: useRAnimation,
        tooltip: 'Add new items',
        heroTag: 'speed-dial-hero-tag',
        foregroundColor: Colors.white,
        backgroundColor: Constant.mediumBlueColor,
        activeForegroundColor: Colors.white,
        activeBackgroundColor: Colors.red,
        elevation: 8.0,
        animationCurve: Curves.elasticInOut,
        isOpenOnStart: false,
        shape: customDialRoot
            ? const RoundedRectangleBorder()
            : const StadiumBorder(),
        children: fabChildren,
       */ /* [
          SpeedDialChild(
              child: !rmIcons ? const Icon(Icons.person) : null,
              backgroundColor: Constant.lightBlueColor,
              foregroundColor: Colors.white,
              labelBackgroundColor: Constant.lightBlueColor,
              label: 'Add Aggregator',
              labelStyle: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onTap: () {
                String employeeId = profileResponse == null
                    ? ''
                    : '${profileResponse!.data!.employeeId}';
                String branchCode = profileResponse == null
                    ? ''
                    : '${profileResponse!.data!.branchCode}';
                Get.to(() =>
                    OnboardApplication(
                        employeeId: employeeId, branchCode: branchCode));
              }),
          SpeedDialChild(
            child: !rmIcons ? const Icon(Icons.account_tree) : null,
            backgroundColor: Constant.lightBlueColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: Constant.lightBlueColor,
            label: 'Add Connector',
            labelStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            visible: true,
            onTap: () {
              //  homeScreenController.pushData();
              String employeeId = profileResponse == null
                  ? ''
                  : '${profileResponse!.data!.employeeId}';
              String branchCode = profileResponse == null
                  ? ''
                  : '${profileResponse!.data!.branchCode}';
              Get.to(() =>
                  VCPApplication(
                      onboardType: 'Connector',
                      employeeId: employeeId,
                      branchCode: branchCode));
            },
          ),
          SpeedDialChild(
            child: !rmIcons ? const Icon(Icons.edit_note) : null,
            backgroundColor: Constant.lightBlueColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: Constant.lightBlueColor,
            label: 'Add DSA',
            labelStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            visible: true,
            onTap: () {
              //  homeScreenController.pushData();
              String employeeId = profileResponse == null
                  ? ''
                  : '${profileResponse!.data!.employeeId}';
              String branchCode = profileResponse == null
                  ? ''
                  : '${profileResponse!.data!.branchCode}';
              Get.to(() =>
                  VCPApplication(
                    onboardType: 'DSA',
                    employeeId: employeeId,
                    branchCode: branchCode,
                  ));
            },
          ),
        ],*/ /*
      ),*/
    );
  }

  Widget menuButton({
    required String assetPath,
    required String label,
    required VoidCallback onPressed,
    double height = 95,
    double iconSize = 45,
    EdgeInsets margin = const EdgeInsets.all(8),
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    Color iconColor = Colors.white,
  }) {
    return Container(
      margin: margin,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: backgroundColor,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Constant.mediumBlueColor,
                    radius: 33,
                    child: Image.asset(
                      assetPath,
                      width: iconSize,
                      height: iconSize,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* Widget iconLeftCenterTextButton({
    required String assetPath,
    required String label,
    required VoidCallback onPressed,
    double height = 100,
    double iconSize = 30,
    EdgeInsets margin = const EdgeInsets.all(8),
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    Color iconColor = Colors.white,
  }) {
    return Container(
      margin: margin,
      child: SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Constant.mediumYellowColor,
                radius: 28,
                child: Image.asset(
                  assetPath,
                  width: iconSize,
                  height: iconSize,
                  color: Constant.mediumBlueColor,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  Widget _buildDetailTile(
      {required IconData icon, required String title, required String value}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Constant.mediumYellowColor,
          // backgroundColor: Colors.blue.shade300,
          radius: 24,
          child: Icon(icon, size: 24, color: Constant.mediumBlueColor),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      callProfileApi(),
      checkAppVersion(),
    ]);
  }

  Future<void> callProfileApi() async {
    // var employeeId = '28871';
    // var id = employeeId;

    setState(() {
      isLoading = true;
    });

    ProfileResponse? response =
        await ApiClient().profileApi(json.encode(employeeId));

    print("Profile Response : ${response?.success}");
    if (response != null) {
      if (response.success!) {
        setState(() {
          profileResponse = response;
          vcpController.customerEmail = profileResponse!.data!.employeeId;
          vcpController.branchName = profileResponse!.data!.branchName;
          vcpController.employeeName = profileResponse!.data!.username;
          vcpController.employeeRole = profileResponse!.data!.role;
          vcpController.branchCode = profileResponse!.data!.branchCode;
        });

        await callGetRoleBasedModule(profileResponse?.data?.role ?? "");
      } else {
        if (ApiClient()?.isDevMode == false && employeeId == "54321") {
          profileResponse = ProfileResponse(
            success: true,
            error: null,
            data: Data(
                username: "Test",
                role: "",
                employeeId: employeeId,
                branchName: "HO",
                branchCode: "0010",
                mobile: "9080706050",
                department: "IT",
                jobTitle: "",
                email: "test@vistaarfinance.com"),
          );
          vcpController.customerEmail = "test@vistaarfinance.com";
          vcpController.branchName = "HO";
          vcpController.employeeName = "Test";
          vcpController.employeeRole = "";
          vcpController.branchCode = "0010";
          setState(() {
            isLoading = false;
          });
          await callGetRoleBasedModule(profileResponse?.data?.role ?? "");
        } else {
          GlobalSnackbar.showError(response.error ?? "Failed to fetch profile");
        }
        setState(() {
          isLoading = false;
        });
      }
    } else {
      GlobalSnackbar.showError("Something went wrong");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkAppVersion() async {
    String body = "VCP-OnBoarding";
    Map<String, dynamic>? response =
        await ApiClient().appVersionApi(json.encode(body));
    if (response != null && response['success']) {
      String serverVersion = response['version'];
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // String currentVersion = packageInfo.version;
      String currentVersion = "2.8.1";

      print("Version check : ${serverVersion} ${currentVersion}");
      bool isVersionMismatch = false;
      try {
        List<String> serverParts = serverVersion.split('.');
        List<String> appParts = currentVersion.split('.');
        int maxLen = serverParts.length > appParts.length
            ? serverParts.length
            : appParts.length;
        for (int i = 0; i < maxLen; i++) {
          int sVal =
              i < serverParts.length ? (int.tryParse(serverParts[i]) ?? 0) : 0;
          int aVal = i < appParts.length ? (int.tryParse(appParts[i]) ?? 0) : 0;
          if (sVal != aVal) {
            isVersionMismatch = true;
            break;
          }
        }
      } catch (e) {
        isVersionMismatch = (serverVersion != currentVersion);
      }

      if (isVersionMismatch) {
        _showVersionDialog();
      }
    }
  }

  Future<void> callGetRoleBasedModule(String role) async {
    /* setState(() {
      isLoading = true;
    });*/
    GetRoleBasedModuleList? response =
        await ApiClient().getModuleByRole(json.encode(role));

    print("Re :$response");
    if (response != null) {
      if (response.modules.isNotEmpty) {
        legalBillingAccess = '';
        legalNoticeAccess = '';
        voiceOfTeamAccess = '';
        sarfaesiModules = response.modulesList.where((module) {
          return (module.module ?? '')
              .trim()
              .toUpperCase()
              .contains('SARFAESI');
        }).toList();
        for (var m in response.modulesList) {
          final moduleName = m.module?.trim().toUpperCase();
          if (moduleName == "LEGAL BILLING") {
            legalBillingAccess = m.access ?? '';
          }
          if (moduleName == "LEGAL NOTICE") {
            legalNoticeAccess = m.access ?? '';
          }
          if (moduleName == "VOICE OF TEAM") {
            voiceOfTeamAccess = m.access ?? '';
          }
        }
        fetchMenuItems(response.modules);
      } else {
        GlobalSnackbar.showError(
            response.error ?? "Failed to fetch dashboard data");
        sarfaesiModules = [];
        fetchMenuItems([]);
      }
    } else {
      GlobalSnackbar.showError("Something went wrong");
      sarfaesiModules = [];
      fetchMenuItems([]);
    }
    setState(() {
      isLoading = false;
    });
  }

  /* void callOnboardCount() async {
    // var employeeId = '28871';
    // var employeeId = widget.employeeId;
    OnboardCountResp? response =
    await ApiClient().onboardCount(json.encode(employeeId));
    if (response != null) {
      if (!response.success!) {
        setState(() {
          onboardCount = response.count;
        });
      } else {
        // Get.snackbar("Failed", response.error,
        //     duration: const Duration(seconds: 3),
        //     backgroundColor: Colors.redAccent,
        //     colorText: Colors.white);
        GlobalSnackbar.showError(response.error ?? "Failed to fetch onboarding count");
      }
    } else {
      // Get.snackbar("Failed", 'Something went wrong',
      //     duration: const Duration(seconds: 3),
      //     backgroundColor: Colors.redAccent,
      //     colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }*/

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                storeData.removeUser();
                log('logout employee Id - ${storeData.getEmployeeId()}');
                Get.offAll(() => const LoginScreen());
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text("Mandatory Update"),
            content: const Text(
                "A new version of the app is available on the Play Store. Please update to continue."),
            actions: [
              TextButton(
                onPressed: () {
                  // 1. Log out user session
                  storeData.removeUser();

                  // 2. Open Play Store
                  const playStoreUrl =
                      'https://play.google.com/store/apps/details?id=com.vistaar.field_visit';
                  launchUrl(Uri.parse(playStoreUrl),
                      mode: LaunchMode.externalApplication);

                  // 3. Redirect to the Login screen
                  Get.offAll(() => const LoginScreen());
                },
                child: const Text("Update"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;

  const DashboardCard(
      {super.key,
      required this.title,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Constant.lightBlueColor,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

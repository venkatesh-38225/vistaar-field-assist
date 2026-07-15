import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/controllers/vcp_application_controller.dart';
import 'package:re_kyc_mobile_app/models/onboard_count_resp.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/screens/connectors/completed_connectors_list.dart';
import 'package:re_kyc_mobile_app/screens/connectors/pending_connectors_list.dart';
import 'package:re_kyc_mobile_app/screens/login_screens/login_screen.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/completed_aggregators.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/visited_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/pending_aggregators_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/onboard_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/completed_appraiser_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/completed_dsa_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/pending_appraiser_list.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/vcp_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/pending_dsa_list.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/service/hive_local_storage.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/floating_action_button/speed_dial.dart';
import 'package:re_kyc_mobile_app/widgets/floating_action_button/speed_dial_child.dart';
import 'package:re_kyc_mobile_app/widgets/floating_action_button/speed_dial_direction.dart';

import '../../models/get_roll_based_modules.dart';
import '../onboard_vcp_screens/add_appraiser.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  HiveDataBase storeData = HiveDataBase();
  String? employeeId;
  Count? onboardCount;
  var selectedFABLocation = FloatingActionButtonLocation.endFloat;
  var mini = false;
  var isDialOpen = ValueNotifier<bool>(false);
  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;
  var rmIcons = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = const Size(56.0, 56.0);
  var childrenButtonSize = const Size(56.0, 56.0);
  var items = [
    FloatingActionButtonLocation.startFloat,
    FloatingActionButtonLocation.startDocked,
    FloatingActionButtonLocation.centerFloat,
    FloatingActionButtonLocation.endFloat,
    FloatingActionButtonLocation.endDocked,
    FloatingActionButtonLocation.startTop,
    FloatingActionButtonLocation.centerTop,
    FloatingActionButtonLocation.endTop,
  ];
  final VcpApplicationController vcpController =
      Get.put(VcpApplicationController());
  List<Map<String, dynamic>> otherMenuItems = [];
  List<Map<String, dynamic>> completedMenuItems = [];
  List<Map<String, dynamic>> pendingMenuItems = [];
  List<SpeedDialChild> fabChildren = [];
  bool isAppraiserMenuAvailable = false;
  bool isLegalNoticeMenuAvailable = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      employeeId = HiveDataBase().getEmployeeId();
    });
    // callProfileApi();
    callOnboardCount();
  }

  void fetchMenuItems(List<String> modules) async {
    await Future.delayed(Duration(seconds: 1));

    String employeeId = vcpController.customerEmail ?? '';
    String branchCode = vcpController.branchCode ?? '';

    List<Map<String, dynamic>> fetchedCompletedMenuItems = [];
    List<Map<String, dynamic>> fetchedPendingMenuItems = [];

    if (modules.map((e) => e.trim()).contains("VCP")) {
      fetchedPendingMenuItems.add({
        'label': 'Visits',
        'icon': Icons.directions_walk,
        'onTap': () => Get.to(() =>
            AggregatorList(employeeId: employeeId, branchCode: branchCode)),
        'count': onboardCount?.aggregatorVisit?.toString() ?? '0',
        'width': 'm',
      });

      fetchedCompletedMenuItems.add({
        'label': 'Aggregator',
        'icon': Icons.groups,
        'onTap': () =>
            Get.to(() => CompletedAggregators(employeeId: employeeId)),
        'count': onboardCount?.aggregatorCompleted?.toString() ?? '0',
        'width': 'm'
      });

      fetchedPendingMenuItems.add({
        'label': 'Aggregator',
        'icon': Icons.groups,
        'onTap': () =>
            Get.to(() => AggregatorsPendingList(employeeId: employeeId)),
        'count': onboardCount?.aggregatorPending?.toString() ?? '0',
        'width': 'm'
      });

      fetchedCompletedMenuItems.add({
        'label': 'DSA',
        'icon': Icons.edit_road_sharp,
        'onTap': () => Get.to(() => VcpCompletedList(employeeId: employeeId)),
        'count': onboardCount?.dsACompleted?.toString() ?? '0',
        'width': 'm'
      });

      fetchedPendingMenuItems.add({
        'label': 'DSA',
        'icon': Icons.edit_road_sharp,
        'onTap': () => Get.to(() => VcpList(employeeId: employeeId)),
        'count': onboardCount?.dsAPending?.toString() ?? '0',
        'width': 'm'
      });

      fetchedCompletedMenuItems.add({
        'label': 'Connectors',
        'icon': Icons.edit_note_sharp,
        'onTap': () =>
            Get.to(() => CompletedConnectors(employeeId: employeeId)),
        'count': onboardCount?.connectorCompleted?.toString() ?? '0',
        'width': 'm'
      });

      fetchedPendingMenuItems.add({
        'label': 'Connectors',
        'icon': Icons.edit_note_sharp,
        'onTap': () => Get.to(() => ConnectorsList(employeeId: employeeId)),
        'count': onboardCount?.connectorPending?.toString() ?? '0',
        'width': 'm'
      });
    }
    List<SpeedDialChild> defaultMenu = addDefaultSpeedDialMenu();
    if (modules.map((e) => e.trim()).contains("Appraiser")) {
      fetchedPendingMenuItems.add({
        'label': 'Appraiser',
        'icon': Icons.assignment_ind,
        'onTap': () =>
            Get.to(() => PendingAppraiserList(employeeId: employeeId)),
        'count': onboardCount?.appraiserPending?.toString() ?? '0',
        'width': 'm'
      });

      fetchedCompletedMenuItems.add({
        'label': 'Appraiser',
        'icon': Icons.assignment_ind,
        'onTap': () =>
            Get.to(() => AppraiserCompletedList(employeeId: employeeId)),
        'count': onboardCount?.appraiserCompleted?.toString() ?? '0',
        'width': 'm'
      });

      defaultMenu.add(
        SpeedDialChild(
          child: !rmIcons ? const Icon(Icons.assignment_ind) : null,
          backgroundColor: Constant.lightBlueColor,
          foregroundColor: Colors.white,
          labelBackgroundColor: Constant.lightBlueColor,
          label: 'Add Appraiser',
          labelStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          onTap: () {
            Get.to(() => AddAppraiser(
                  onboardType: 'Appraiser',
                  employeeId: employeeId,
                  branchCode: branchCode,
                ));
          },
        ),
      );
    }

    /* if (!modules.map((e) => e.trim()).contains("Legal Notice")) {
      fetchedPendingMenuItems.add({
        'label': 'Legal Notice',
        'icon': Icons.gavel,
        'onTap': () => null,
        'count': onboardCount?.aggregatorVisit?.toString() ?? '0',
        'width': 'l'
      });

    }*/
    setState(() {
      completedMenuItems = fetchedCompletedMenuItems;
      pendingMenuItems = fetchedPendingMenuItems;
      fabChildren = defaultMenu;
      isLoading = false;
    });
  }

  List<SpeedDialChild> addDefaultSpeedDialMenu() {
    String employeeId = vcpController.customerEmail ?? '';
    String branchCode = vcpController.branchCode ?? '';
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
    return _buildHomeContainerWidget(context);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double menuItemWidth = (screenWidth / 3) - 10;
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          callOnboardCount();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              completedMenuItems.isEmpty
                  ? SizedBox()
                  : const Text(
                      'Completed Onboarding :',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Constant.mediumBlueColor,
                      ),
                    ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : completedMenuItems.isEmpty
                      ? const SizedBox()
                      : SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            runSpacing: 5,
                            children: completedMenuItems.map((item) {
                              return InkWell(
                                onTap: item['onTap'] != null
                                    ? () => item['onTap']()
                                    : null,
                                child: SizedBox(
                                  height: item['width'] == "m"
                                      ? menuItemWidth + 5
                                      : 140, // slightly taller to fit icon top + label + count
                                  width: item['width'] == "m"
                                      ? menuItemWidth + 2
                                      : 145,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 8, // no shadow, just border
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Colors
                                            .grey, // you can customize border color here
                                        width: 1, // 2 dp thin border
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1, vertical: 1),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            item['icon'],
                                            size: 37, // icon on top bigger size
                                            color: Constant.lightBlueColor,
                                          ),
                                          const SizedBox(height: 8),
                                          AutoSizeText(
                                            item['label'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Constant.lightBlueColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "(${item['count']})",
                                            style: const TextStyle(
                                              fontSize:
                                                  15, // count font size ~ icon size 20
                                              fontWeight: FontWeight.normal,
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
                      'Pending Onboarding :',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Constant.mediumBlueColor,
                      ),
                    ),
              const SizedBox(height: 10),
              pendingMenuItems.isEmpty
                  ? const SizedBox(
                      height: 0,
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        runSpacing: 5,
                        children: pendingMenuItems.map((item) {
                          return InkWell(
                            onTap: item['onTap'] != null
                                ? () => item['onTap']()
                                : null,
                            child: SizedBox(
                              height: item['width'] == "m"
                                  ? menuItemWidth + 5
                                  : 140, // slightly taller to fit icon top + label + count
                              width: item['width'] == "m" ? menuItemWidth : 145,
                              child: Card(
                                color: Colors.white,
                                elevation: 8, // no shadow, just border
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Colors
                                        .grey, // you can customize border color here
                                    width: 1, // 2 dp thin border
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item['icon'],
                                        size: 37, // icon on top bigger size
                                        color: Constant.lightBlueColor,
                                      ),
                                      const SizedBox(height: 8),
                                      AutoSizeText(
                                        item['label'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Constant.lightBlueColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "(${item['count']})",
                                        style: const TextStyle(
                                          fontSize:
                                              15, // count font size ~ icon size 20
                                          fontWeight: FontWeight.normal,
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
              const SizedBox(height: 50),
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
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: selectedFABLocation,
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
        /* [
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
        ],*/
      ),
    );
  }

  Widget menuButton({
    required String assetPath, // path to your PNG asset
    required String label,
    required VoidCallback onPressed,
    double height = 110,
    double iconSize = 40,
    EdgeInsets margin = const EdgeInsets.all(10),
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
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: 15),
                  CircleAvatar(
                    backgroundColor: Constant.mediumBlueColor,
                    // backgroundColor: Colors.blue.shade300,
                    radius: 35,
                    child: Image.asset(
                      assetPath,
                      width: iconSize,
                      height: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void callGetRoleBasedModule(String role) async {
    GetRoleBasedModuleList? response =
        await ApiClient().getModuleByRole(json.encode(role));

    if (response != null) {
      if (response.modules.isNotEmpty) {
        fetchMenuItems(response.modules);
      } else {
        // Get.snackbar("Failed", response.error ?? "",
        //     duration: const Duration(seconds: 3),
        //     backgroundColor: Colors.redAccent,
        //     colorText: Colors.white);
        GlobalSnackbar.showError(response.error ?? "Failed to fetch profile");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Get.snackbar("Failed", 'Something went wrong',
      //     duration: const Duration(seconds: 3),
      //     backgroundColor: Colors.redAccent,
      //     colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
      setState(() {
        isLoading = false;
      });
    }
  }

  void callOnboardCount() async {
    setState(() {
      isLoading = true;
    });
    // var employeeId = '28871';
    // var employeeId = widget.employeeId;
    OnboardCountResp? response =
        await ApiClient().onboardCount(json.encode(employeeId));
    if (response != null) {
      if (response.success!) {
        setState(() {
          onboardCount = response.count;
        });
      } else {
        // Get.snackbar("Failed", response.error,
        //     duration: const Duration(seconds: 3),
        //     backgroundColor: Colors.redAccent,
        //     colorText: Colors.white);
        GlobalSnackbar.showError(
            response.error ?? "Failed to fetch onboarding count");
      }
    } else {
      // Get.snackbar("Failed", 'Something went wrong',
      //     duration: const Duration(seconds: 3),
      //     backgroundColor: Colors.redAccent,
      //     colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
    callGetRoleBasedModule(vcpController.employeeRole ?? "");
  }

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
}

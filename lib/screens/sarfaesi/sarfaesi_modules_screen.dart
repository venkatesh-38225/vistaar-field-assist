import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/get_roll_based_modules.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/sarfaesi-14-1/sarfaesi.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/sarfaesi.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class SarfaesiModulesScreen extends StatelessWidget {
  const SarfaesiModulesScreen({
    super.key,
    required this.profile,
    required this.modules,
  });

  final ProfileResponse profile;
  final List<GetRoleBasedModule> modules;

  List<GetRoleBasedModule> get _uniqueModules {
    final seenNames = <String>{};
    return modules.where((module) {
      final normalizedName = (module.module ?? '').trim().toUpperCase();
      return normalizedName.isNotEmpty && seenNames.add(normalizedName);
    }).toList();
  }

  void _openModule(GetRoleBasedModule module) {
    final moduleName = (module.module ?? '').trim();
    final normalizedName = moduleName.toUpperCase();

    if (normalizedName == 'SARFAESI 13(4)') {
      Get.to(() => SarfaesiScreen(
            profile: profile,
            access: module.access ?? '',
          ));
      return;
    }

    if (normalizedName.contains('SARFAESI 14') &&
        normalizedName.contains('PHYSICAL FILING')) {
      Get.to(() => Sarfaesi14PhysicalFilingScreen(
            profile: profile,
            access: module.access ?? '',
          ));
      return;
    }

    GlobalSnackbar.showError(
      '$moduleName screen is not available in this app version',
    );
  }

  _ModuleVisual _visualFor(GetRoleBasedModule module, int index) {
    final name = (module.module ?? '').trim().toUpperCase();

    if (name == 'SARFAESI 13(4)') {
      return const _ModuleVisual(
        tabLabel: 'NOTICE',
        description: 'Manage possession notice cases',
        imageUrl: 'https://img.icons8.com/fluency/160/contract.png',
        accentColor: Color(0xFFE6A10A),
        softColor: Color(0xFFFFF7E5),
        fallbackIcon: Icons.description_outlined,
      );
    }

    if (name.contains('SARFAESI 14') && name.contains('PHYSICAL FILING')) {
      return const _ModuleVisual(
        tabLabel: 'FILING',
        description: 'LAN filing and document checklist',
        imageUrl: 'https://img.icons8.com/fluency/160/courthouse.png',
        accentColor: Color(0xFF1769D2),
        softColor: Color(0xFFEAF3FF),
        fallbackIcon: Icons.account_balance_outlined,
      );
    }

    const fallbackImages = [
      'https://img.icons8.com/fluency/160/scales.png',
      'https://img.icons8.com/fluency/160/documents.png',
      'https://img.icons8.com/fluency/160/law.png',
      'https://img.icons8.com/fluency/160/opened-folder.png',
    ];
    const accentColors = [
      Color(0xFF5B4BC4),
      Color(0xFF008C95),
      Color(0xFFB45A2A),
      Color(0xFF47647F),
    ];
    final color = accentColors[index % accentColors.length];

    return _ModuleVisual(
      tabLabel: 'MODULE ${index + 1}',
      description: 'Open SARFAESI workflow',
      imageUrl: fallbackImages[index % fallbackImages.length],
      accentColor: color,
      softColor: color.withValues(alpha: 0.09),
      fallbackIcon: Icons.folder_copy_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sarfaesiModules = _uniqueModules;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 4,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'SARFAESI Workspace',
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            SizedBox(height: 2),
            CustomText(
              text: 'Legal actions and filings',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFFD8E6F8),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          const SizedBox(height: 4),
          if (sarfaesiModules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  CustomText(
                    text: 'No SARFAESI modules are available',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            )
          else ...[
            for (var index = 0; index < sarfaesiModules.length; index++) ...[
              _buildModuleCard(
                sarfaesiModules[index],
                _visualFor(sarfaesiModules[index], index),
              ),
              if (index != sarfaesiModules.length - 1)
                const SizedBox(height: 12),
            ],
            const SizedBox(height: 22),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 20,
                  color: Constant.mediumBlueColor,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: CustomText(
                    text: 'Modules shown according to your role',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    GetRoleBasedModule module,
    _ModuleVisual visual,
  ) {
    final moduleName = module.module?.trim() ?? '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: visual.accentColor, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openModule(module),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 26, 12, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 76,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: visual.softColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        visual.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          visual.fallbackIcon,
                          size: 42,
                          color: visual.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: moduleName,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0C2A50),
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            text: visual.description,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(
                                text: 'Open module',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: visual.accentColor,
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 17,
                                color: visual.accentColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 100),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: visual.accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: CustomText(
              text: visual.tabLabel,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModuleVisual {
  const _ModuleVisual({
    required this.tabLabel,
    required this.description,
    required this.imageUrl,
    required this.accentColor,
    required this.softColor,
    required this.fallbackIcon,
  });

  final String tabLabel;
  final String description;
  final String imageUrl;
  final Color accentColor;
  final Color softColor;
  final IconData fallbackIcon;
}

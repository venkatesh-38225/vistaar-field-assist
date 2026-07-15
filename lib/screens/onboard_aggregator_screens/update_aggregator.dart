/*

import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class UpdateAggregator extends StatefulWidget {
  const UpdateAggregator({super.key});

  @override
  State<UpdateAggregator> createState() => _UpdateAggregatorState();
}

class _UpdateAggregatorState extends State<UpdateAggregator> {
  bool update = false;
  TextEditingController remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF116bb6), Color(0xFF116bb6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomPaint(
                painter: WavePainter(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Image.asset(
                          'assets/images/v_logo.png',
                          height: 27,
                          width: 27,
                          // color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const CustomText(
                        text: 'Update Aggregator',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                       color: Colors.white,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: 'Onboard Aggregator Details',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                           color: Color(0xFF145a95),
                        ),
                        const Divider(color: Colors.grey),
                        infoRow('Branch Code', '0003'),
                        infoRow('Aggregator Name', 'Thaaranya'),
                        infoRow('Contact No', '9876543210'),
                        infoRow('Email-ID', 'thaaranya.g@vistaar.com'),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => setState(() => update = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFfaa61a),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Update Visit',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => setState(() => update = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFfaa61a),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Convert VCP',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (update) ...[
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CustomText(
                                text: 'Please enter your remark',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              IconButton(
                                onPressed: () => setState(() => update = false),
                                icon: const ImageIcon(
                                  AssetImage('assets/icons/close.png'),
                                  size: 20,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                               borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: remarkController,
                              decoration: InputDecoration(
                                hintText: 'Enter remark...',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF116bb6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                elevation: 3,
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          CustomText(
            text: value,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
*/

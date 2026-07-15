

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import '../../widgets/customes_textformfield.dart';

class PanAadhaarDetails extends StatefulWidget {
  const PanAadhaarDetails({super.key});

  @override
  State<PanAadhaarDetails> createState() => _PanAadhaarDetailsState();
}

class _PanAadhaarDetailsState extends State<PanAadhaarDetails> {
  String? selectedCategory;
  TextEditingController otherController = TextEditingController();

  String? _dobAadhaar;
  String? _dobPan;

// Function to show date picker
  Future<void> _selectDate(BuildContext context, bool isAadhar) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isAadhar) {
          setState(() {
            String aadhaar = DateFormat('dd-MM-yyyy').format(pickedDate);
            _dobAadhaar = aadhaar;
          });
        } else {
          setState(() {
            String pan = DateFormat('dd-MM-yyyy').format(pickedDate);
            _dobPan = pan;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF145a95), Color(0xFF145a95)],
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Image.asset(
                            'assets/images/v_logo.png',
                            height: 25,
                            width: 25,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const CustomText(
                          text: 'Pan & Aadhaar Details',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            text: 'Enter your details',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              height: 55,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: _dobAadhaar != null
                                  ? Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            color: Colors.blueGrey),
                                        const SizedBox(width: 10),
                                        CustomText(
                                            text: _dobAadhaar!,
                                            color: Colors.black87),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            color: Colors.blueGrey),
                                        const SizedBox(width: 10),
                                        CustomText(
                                            text: 'DOB as per Aadhaar',
                                            color: Colors.grey.shade700),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              height: 55,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: _dobPan != null
                                  ? Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            color: Colors.blueGrey),
                                        const SizedBox(width: 10),
                                        CustomText(
                                            text: _dobPan!,
                                            color: Colors.black87),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            color: Colors.blueGrey),
                                        const SizedBox(width: 10),
                                        CustomText(
                                            text: 'DOB as per Pan',
                                            color: Colors.grey.shade700),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          const BuildTextField(
                              hint: 'Name as per Pan',
                              label: 'Name as per Pan',
                              icon: Icons.person,
                              isMultiline: false),
                          const BuildTextField(
                              hint: 'Name as per Aadhaar',
                              label: 'Name as per Aadhaar',
                              icon: Icons.person,
                              isMultiline: false),
                          // _buildDropdown(),
                          const BuildTextField(
                            hint: 'No.of years in Business',
                            label: 'No.of years in Business',
                            icon: Icons.work_history,
                            isMultiline: false,
                            inputType: TextInputType.number,
                          ),
                        const BuildTextField(
                              hint: 'Address as per Aadhaar ',
                              label: 'Address as per Aadhaar ',
                              icon: Icons.home,
                              isMultiline: true,
                              padding: 50),

                          const SizedBox(height: 20),
                          Center(
                            child: CustomButton(
                              text: 'Save',
                              onPressed: () {
                                // Get.to(() => const BusinessApplication());
                              },
                              backgroundColor: const Color(0xFFfaa61a),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 250),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.8, size.width, size.height * 0.6);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawPath(path, paint);

    Path path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
        size.width * 0.5, size.height * 0.9, size.width, size.height * 0.7);
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

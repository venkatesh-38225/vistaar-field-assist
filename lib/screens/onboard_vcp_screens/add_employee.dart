import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/customes_textformfield.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  String? employeeAnswer;
  bool annex4 = false;
  List<Map<String, dynamic>> relatedEmployeeList = [];
  List<Map<String, dynamic>> savedEmployee = [];
  bool saveRelatedEmployee = false;
  List<String> contractorsProvide = [
    "Yes",
    "No",
  ];


  void removeEmployee(int index) {
    setState(() {
      relatedEmployeeList.removeAt(index);
      savedEmployee.clear();
    });
  }

  void saveEmployeeList() {
    for (var item in relatedEmployeeList) {
      setState(() {
        savedEmployee.add({
          'id': item['id'],
          'Name of employee': item['Name of employee'].text,
          'RelationShip': item['RelationShip'].text,
        });
      });
    }
  }

  void addEmployee() {
    savedEmployee.clear();
    setState(() {
      saveRelatedEmployee = false;
      relatedEmployeeList.add({
        'id': relatedEmployeeList.length + 1, // Auto-increment number
        'Name of employee': TextEditingController(),
        'RelationShip': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// sub - contractors
            const CustomText(
              text:
              '3. Are you (Proprietor / any Partner (s) /Director (s)) is / are related to any employee of Vistaar Finance?',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: employeeAnswer,
                  decoration:
                  const InputDecoration(border: InputBorder.none),
                  hint: Row(
                    children: [
                      const Icon(
                        Icons.arrow_drop_down_circle_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Yes / No',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  icon: Icon(
                    Icons.arrow_right,
                    color: Colors.grey[200],
                    size: 5,
                  ),
                  items: contractorsProvide.map((String partner) {
                    return DropdownMenuItem<String>(
                      value: partner,
                      child: Text(
                        partner,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black),
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      employeeAnswer = newValue;
                    });
                  },
                ),
              ),
            ),

            /// bank partners add list
            Visibility(
              visible:  employeeAnswer == 'Yes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: annex4 ? 350 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: relatedEmployeeList.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  color: Colors.grey[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Employee ${relatedEmployeeList[index]['id']}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold)),
                                        TextFormField(
                                          controller:
                                          relatedEmployeeList[index]
                                          ['Name of employee'],
                                          decoration:
                                          const InputDecoration(
                                            labelText: 'Name of employee',
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          controller:
                                          relatedEmployeeList[index]
                                          ['RelationShip'],
                                          decoration:
                                          const InputDecoration(
                                            labelText:
                                            'RelationShip',
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 5),
                                        Align(
                                          alignment:
                                          Alignment.centerRight,
                                          child: IconButton(
                                              icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                removeEmployee(index);
                                                if (relatedEmployeeList
                                                    .isEmpty) {
                                                  setState(() {
                                                    annex4 = false;
                                                  });
                                                }
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          saveRelatedEmployee
                              ? SizedBox(
                            width: 170,
                            height: 40,
                            child: CustomButton(
                              onPressed: () {},
                              text: 'Saved',
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          )
                              : SizedBox(
                            width: 170,
                            height: 40,
                            child: CustomButton(
                              onPressed: () {
                                saveRelatedEmployee = true;
                                saveEmployeeList();
                              /*  var form = _businessFormKey.currentState;
                                if (form!.validate()) {
                                  saveEmployeeList();
                                }*/
                              },
                              text: 'Save employees',
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const CustomText(
                    text: 'Please add your bank partners',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        annex4 = true;
                      });
                      addEmployee();
                    },
                    child: Container(
                      height: 57,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8.0),
                      child: Row(
                        children: [
                          const ImageIcon(
                            AssetImage('assets/icons/plus.png'),
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 10),
                          relatedEmployeeList.isEmpty
                              ? Text(
                            "Add employees",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16),
                          )
                              : Text(
                            "Add more employees",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

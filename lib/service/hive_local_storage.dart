import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDataBase extends GetxController {
  final Box storedBox = Hive.box('hiveStorage');
  final Box userDetailsBox = Hive.box('userDetails');

  final String _userDetailsKey = 'userDetails';


  Future<void> setEmployeeId(String? employeeId) async {
    await userDetailsBox.put(_userDetailsKey, employeeId);
  }

  String? getEmployeeId() {
    return userDetailsBox.get(_userDetailsKey);
  }

  void deleteUserSession() {
    userDetailsBox.delete(_userDetailsKey);
  }
  void removeUser() {
    deleteUserSession();
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:file_picker/file_picker.dart';


class CustomsHelper {
  ImagePicker imagePicker = ImagePicker();

  /// Show session expired alert dialog
  static cameraPermissionAlert(VoidCallback? cameraButton, VoidCallback? galleryButton) {
    return Get.defaultDialog(
      radius: 10,
      title: 'Upload Document',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF116bb6),
      ),
      content: const CustomText(
        text: 'Select file from',
      ),
      confirm: galleryButton != null && cameraButton != null ?

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
         GestureDetector(
            onTap: galleryButton,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Icon(
                    Icons.photo,
                    color: Color(0xFF116bb6),
                  ),
                  SizedBox(height: 05),
                  CustomText(
                    text: 'Gallery',
                  )
                ],
              ),
            ),
          ) ,
         GestureDetector(
            onTap: cameraButton,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF116bb6),
                  ),
                  SizedBox(height: 05),
                  CustomText(
                    text: 'Camera',
                  )
                ],
              ),
            ),
          ),
        ],
      ) : galleryButton != null ?
      GestureDetector(
        onTap: galleryButton,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(
                Icons.photo,
                color: Color(0xFF116bb6),
              ),
              SizedBox(height: 05),
              CustomText(
                text: 'Gallery',
              )
            ],
          ),
        ),
      ) :
      GestureDetector(
        onTap: cameraButton,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(
                Icons.photo,
                color: Color(0xFF116bb6),
              ),
              SizedBox(height: 05),
              CustomText(
                text: 'Camera',
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Get from camera
  getCamera() async {
    try {
      XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return pickedFile.path;
      } else {
        return '';
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
      return '';
    }
  }

  /// Get from gallery
  getGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      // maxWidth: 1800,
      // maxHeight: 1800,
      maxWidth: 1920,        // Reduce width
      maxHeight: 1080,       // Reduce height
      imageQuality: 80,
    );
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return '';
    }
  }


/*
  /// image compress
  Future<File> compressFile({required File pickedFile}) async {
    var path = FlutterNativeImage.compressImage(pickedFile.absolute.path, quality: 100, percentage: 30);
    log('path - ${path.toString()}');
    return path;
  }*/

  /// File to base64
  // Future<String> fileToBase64(String doc) async {
  //   File imageFile = File(doc);
  //   List<int> imageBytes = await imageFile.readAsBytes(); // Read file as bytes
  //   String base64String = base64Encode(imageBytes); // Convert to Base64
  //   print("Base 64 length: ${base64String.length}");
  //   print("Base 64 String: ${base64String}");
  //   return base64String;
  // }

  Future<String> fileToBase64(String doc) async {
    File imageFile = File(doc);
    List<int> imageBytes = await imageFile.readAsBytes(); // Read file as bytes
    String base64String = base64Encode(imageBytes); // Convert to Base64

    return base64String;
  }

  Future<String> getGalleryFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path!;
      } else {
        return '';
      }
    } catch (e) {
      debugPrint("File picking error: $e");
      return '';
    }
  }


}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:mid_term/helpers/color.dart';
import 'package:mid_term/helpers/extensions.dart';

import '../data/firebase_service/firestor.dart';
import '../data/firebase_service/storage.dart';

class AddPostTextScreen extends StatefulWidget {
  final File file;
  const AddPostTextScreen(this.file, {super.key});

  @override
  State<AddPostTextScreen> createState() => _AddPostTextScreenState();
}

class _AddPostTextScreenState extends State<AddPostTextScreen> {
  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  bool isLoading = false;

  Future<void> _sharePost() async {
    if (captionController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phải có caption nhé bạn!')),
      );
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        String postUrl =
            await StorageMethod().uploadImageToStorage('post', widget.file);

        await Firebase_Firestor().CreatePost(
          postImage: postUrl,
          caption: captionController.text,
          location: locationController.text,
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String?> sendImageAndGetCaption(File file) async {
    try {
      final String apiUrl = 'http://192.168.1.77:8000/predict/';
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);

        final caption = json['caption'];
        return caption[0];
      } else {
        debugPrint('Error: "caption" not found in response.');
        return null;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorData.backGroundColorTextField,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: GestureDetector(
              onTap: isLoading ? null : (_sharePost),
              child: Center(
                child: Text(
                  'Share',
                  style: TextStyle(
                    color: isLoading ? Colors.grey : Colors.blue,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostInputSection(
                    file: widget.file,
                    captionController: captionController,
                  ),
                  const Divider(),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Add location',
                      fillColor: ColorData.greyTextColor,
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: ColorData.greyTextColor,
                        size: 30,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                try {
                  String? caption = await sendImageAndGetCaption(widget.file);
                  captionController.text = caption!;
                  Navigator.pop(context);
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text(
                'Bạn có muốn AI generate caption cho bạn không?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostInputSection extends StatelessWidget {
  final File file;
  final TextEditingController captionController;

  const _PostInputSection({
    required this.file,
    required this.captionController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: context.mediaQueryWidth * 0.8,
            height: context.mediaQueryHeight * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: FileImage(file),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          controller: captionController,
          decoration: InputDecoration(
            hintText: 'Write a caption...',
            fillColor: ColorData.greyTextColor,
            prefixIcon: Icon(
              Icons.edit_note_outlined,
              color: ColorData.greyTextColor,
              size: 30,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            border: InputBorder.none,
          ),
          maxLines: null, // Cho phép nhập nhiều dòng
          keyboardType: TextInputType.multiline, // Sử dụng bàn phím đa dòng
        )
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mid_term/service/database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductState();
}

class _AddProductState extends State<AddProductPage> {
  TextEditingController nameProductController = TextEditingController();
  TextEditingController categoryProductController = TextEditingController();
  TextEditingController priceProductController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      await Permission.photos.request();
    }

    if (await Permission.photos.isGranted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          Fluttertoast.showToast(
              msg: "Không có hình ảnh nào được chọn.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: "Quyền truy cập ảnh chưa được cấp.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Thêm",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              " Sản Phẩm",
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tên sản phẩm:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                margin: EdgeInsets.only(top: 10, right: 10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: nameProductController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập tên sản phẩm',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Tên danh mục:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                margin: EdgeInsets.only(top: 10, right: 10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: categoryProductController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập tên danh mục',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Giá sản phẩm:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                margin: EdgeInsets.only(top: 10, right: 10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: priceProductController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true), // Chỉ cho phép nhập số
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập giá sản phẩm',
                  ),
                ),

              ),
              SizedBox(height: 20),
              Text(
                "Hình ảnh:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _image == null
                  ? Text("Không có ảnh nào được chọn.")
                  : Image.file(
                _image!,
                height: 150,
                width: 150,
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Chọn hình ảnh"),
              ),
              SizedBox(height: 150),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24)
                    .copyWith(bottom: 20),
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Quay Lại",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                          ),
                        )),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () async {
                          String Id = randomAlphaNumeric(10);

                          // Kiểm tra các trường đầu vào
                          if (nameProductController.text.isEmpty ||
                              categoryProductController.text.isEmpty ||
                              priceProductController.text.isEmpty ||
                              double.tryParse(priceProductController.text) == null||
                              _image == null) {

                            String errorMessage = "";

                            if (nameProductController.text.isEmpty) {
                              errorMessage += "Tên sản phẩm không được để trống.\n";
                            }

                            if (categoryProductController.text.isEmpty) {
                              errorMessage += "Danh mục sản phẩm không được để trống.\n";
                            }

                            if (priceProductController.text.isEmpty || double.tryParse(priceProductController.text) == null) {
                              errorMessage += "Giá sản phẩm không được để trống và phải là số hợp lệ.";
                            }

                            if (_image == null) {
                              errorMessage += "Hình ảnh không được để trống.";
                            }

                            Fluttertoast.showToast(
                              msg: errorMessage.trim(),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.blueGrey,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );

                            return; // Thoát hàm nếu có lỗi
                          }


                          // // Upload hình ảnh và lấy URL
                          String imageUrl = await DatabaseMethods().uploadImageToFirebase(_image!, Id);

                          if (imageUrl.isNotEmpty) {
                            Map<String, dynamic> productInfoMap = {
                              "Id": Id,
                              "NameProduct": nameProductController.text,
                              "CategoryProduct": categoryProductController.text,
                              "PriceProduct": priceProductController.text,
                              "ProductImage": imageUrl, // Lưu URL hình ảnh
                            };

                            await DatabaseMethods()
                                .addProductDetails(productInfoMap, Id)
                                .then((onValue) {
                              Fluttertoast.showToast(
                                  msg: "Thêm sản phẩm thành công!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });
                          }
                          else {
                            Fluttertoast.showToast(
                              msg: "Lỗi upload hình ảnh.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8875FF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        child: Text(
                          "Thêm Vào",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

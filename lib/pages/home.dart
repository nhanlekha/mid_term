import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mid_term/pages/add_product.dart';
import 'package:mid_term/service/database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';

import '../user_auth/presentation/login_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? productStream;

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


  getOnTheLoad() async {
    productStream = await DatabaseMethods().getProductDetails();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getOnTheLoad();
    super.initState();
  }

  Widget allProductDetails() {
    return StreamBuilder(
        stream: productStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hình ảnh sản phẩm
                              if (ds["ProductImage"] != null && ds["ProductImage"]!.isNotEmpty)
                                Image.network(
                                  ds["ProductImage"]!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    // Hiển thị hình ảnh mặc định khi không tải được
                                    return Image.asset(
                                      'assets/images/image.jpg', // Đường dẫn đến hình ảnh mặc định
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              else
                                Image.asset(
                                  'assets/images/image.jpg', // Hiển thị hình ảnh mặc định nếu không có URL
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              SizedBox(width: 10), // Khoảng cách giữa hình ảnh và cột thông tin
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "" + ds["NameProduct"],
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                nameProductController.text = ds["NameProduct"];
                                                categoryProductController.text = ds["CategoryProduct"];
                                                priceProductController.text = ds["PriceProduct"].toString();
                                                editProductDetails(ds["Id"],ds["ProductImage"]);
                                              },
                                              child: Icon(
                                                FontAwesomeIcons.edit,
                                                color: Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () async {
                                                await DatabaseMethods()
                                                    .deleteProductDetails(ds["Id"])
                                                    .then((onValue) {
                                                  Fluttertoast.showToast(
                                                    msg: "Xóa sản phẩm thành công !",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.white,
                                                    textColor: Colors.black,
                                                    fontSize: 16.0,
                                                  );
                                                });
                                              },
                                              child: Icon(FontAwesomeIcons.x, color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5), // Khoảng cách giữa các hàng
                                    Text(
                                      "" + ds["CategoryProduct"],
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "${ds["PriceProduct"]}đ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddProductPage()));
          }),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Mid",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              " Term",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              " Project",
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                // Xử lý đăng xuất tại đây
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage()),
                        (route) => false);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Đăng xuất'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          children: [
            Expanded(child: allProductDetails()),
          ],
        ),
      ),
    );
  }

  Future editProductDetails(String id, String urlImg) => showDialog(

    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.cancel,color: Colors.red),
          ),
          SizedBox(width: 10), // Adjusted width for better spacing
          Text(
            "Chỉnh Sửa",
            style: TextStyle(
                color: Colors.blue,
                fontSize: 22.0,
                fontWeight: FontWeight.bold),
          ),
          Text(
            " Chi Tiết",
            style: TextStyle(
                color: Colors.amber,
                fontSize: 22.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      titlePadding: EdgeInsets.all(10),
      contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10,bottom: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      content: Builder(
        builder: (context) {
          var width = MediaQuery.of(context).size.width;
          return SingleChildScrollView(
            child: Container(
              width: width * 0.9, // Set width to 90% of the screen width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
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
                      decoration: InputDecoration(border: InputBorder.none),
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
                      decoration: InputDecoration(border: InputBorder.none),
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
                      keyboardType: TextInputType.number, // Ensure only numbers are input
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    "Ảnh sản phẩm:",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Chọn hình ảnh"),
                  ),
            
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24)
                        .copyWith(bottom: 20, top: 20),
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
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            // Validate inputs
                            if (nameProductController.text.isEmpty ||
                                categoryProductController.text.isEmpty ||
                                priceProductController.text.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Vui lòng điền đầy đủ thông tin.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return; // Stop further processing
                            }
            
                            // Validate price as a number
                            double? price = double.tryParse(priceProductController.text);
                            if (price == null || price < 0) {
                              Fluttertoast.showToast(
                                msg: "Giá sản phẩm không hợp lệ.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return; // Stop further processing
                            }

                            if (_image != null) {
                              urlImg =  await DatabaseMethods().uploadImageToFirebase(_image!, id);;
                            }


                            Map<String, dynamic> productInfoMap = {
                              "Id": id,
                              "NameProduct": nameProductController.text,
                              "CategoryProduct": categoryProductController.text,
                              "PriceProduct": priceProductController.text,
                              "ProductImage": urlImg,
                            };
            
                            await DatabaseMethods()
                                .updateProductDetails(id, productInfoMap)
                                .then((onValue) {
                              Fluttertoast.showToast(
                                  msg: "Cập nhật sản phẩm thành công!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blueGrey,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8875FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                          child: Text(
                            "Cập Nhật",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'addpost_text.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final List<Widget> _mediaList = [];
  final List<File> path = [];
  File? _file;
  int currentPage = 0;
  int? lastPage;

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  Future<void> _fetchNewMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> album =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      List<AssetEntity> media =
          await album[0].getAssetListPaged(page: currentPage, size: 60);

      List<Widget> temp = [];
      for (var asset in media) {
        final file = await asset.file;
        if (file != null) {
          path.add(File(file.path));
          _file ??= path[0];

          temp.add(
            FutureBuilder(
              future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
                return Container(color: Colors.grey); // Placeholder
              },
            ),
          );
        }
      }

      // Kiểm tra mounted trước khi gọi setState
      if (mounted) {
        setState(() {
          _mediaList.addAll(temp);
          currentPage++;
        });
      }
    } else {
      print('Permission denied');
    }
  }

  int indexx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () {
                  if (_file != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddPostTextScreen(_file!),
                    ));
                  } else {
                    print('No file selected');
                  }
                },
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 15.sp, color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 375.h,
              color: Colors.black12,
              child: _file != null
                  ? Image.file(
                      _file!,
                      fit: BoxFit.cover,
                    )
                  : const Center(child: Text('No image selected')),
            ),

            Container(
              width: double.infinity,
              height: 40.h,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent',
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Media Grid
            Expanded(
              child: GridView.builder(
                itemCount: _mediaList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        indexx = index;
                        _file = path[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: index == indexx
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: _mediaList[index],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mid_term/data/firebase_service/chat_message.dart';
import 'package:mid_term/data/firebase_service/user_list.dart';
import 'package:mid_term/data/model/message.dart';
import 'package:mid_term/data/model/usermodel.dart';
import 'package:mid_term/helpers/date_until.dart';
import 'package:mid_term/helpers/image_helper.dart';
import 'package:mid_term/screen/chats/components/app_bar_container.dart';
import 'package:mid_term/screen/chats/user_chat.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  UserModel? userModel;
  bool isDataLoaded = false;
  List<UserModel> onUserModelList = [];
  List<UserModel> allUserModelList = [];
  List<UserModel> searchList = [];
  bool isSearching = false;
  FocusNode focusNode = FocusNode();

  final textSearchController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    UserModel? userModel = await UserService().getUserModel();
    String username = userModel!.username!;
  }

  @override
  Widget build(BuildContext context) {
    return AppBarContainer(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: StreamBuilder(
          stream: UserService().userModelStream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Text('No user data available');
                }
                final userModel = snapshot.data!;
                return Text(
                  userModel.username ?? 'Unknown',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                );
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageHelper.loadFromAsset("assets/images/video_add.png",
                width: 30),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageHelper.loadFromAsset("assets/images/message_add.png",
                width: 30),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.black12.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  focusNode: focusNode,
                  onTap: () {
                    setState(() {
                      if (focusNode.hasFocus) {
                        focusNode.unfocus();
                        isSearching = false;
                        textSearchController.text = '';
                      } else {
                        isSearching = true;
                        focusNode.requestFocus();
                      }
                    });
                  },
                  onChanged: (value) {
                    searchList.clear();
                    for (var item in allUserModelList) {
                      if (item.username!
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          item.email!
                              .toLowerCase()
                              .contains(value.toLowerCase())) {
                        searchList.add(item);
                      }
                      setState(() {
                        searchList;
                      });
                    }
                  },
                  controller: textSearchController,
                  cursorColor: Colors.black38,
                  decoration: const InputDecoration(
                      hintText: "Tìm kiếm",
                      hintStyle: TextStyle(fontSize: 18),
                      prefixIconColor: Colors.black38,
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search)),
                )),
            // Online User List
            if (!isSearching) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Online Users',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: StreamBuilder(
                  stream: UserService().getOnlineUsersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      final data = snapshot.data?.docs;
                      onUserModelList = data!
                          .map((e) => UserModel.fromJson(e.data()))
                          .toList();
                      return ListView.builder(
                        itemCount: onUserModelList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return buildItemUser(onUserModelList[index]);
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tin nhắn",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Tin nhắn đang chờ...",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            StreamBuilder(
              stream: UserService().getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      final data = snapshot.data!.docs;
                      allUserModelList = data
                          .map((e) => UserModel.fromJson(e.data()))
                          .toList();
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: isSearching
                          ? searchList.length
                          : allUserModelList.length,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserChatPage(
                                    userChat: allUserModelList[index]),
                              ),
                            );
                          },
                          child: buildChatItemUser(isSearching
                              ? searchList[index]
                              : allUserModelList[index]),
                        );
                      },
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemUser(UserModel user) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.topLeft,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                image: DecorationImage(image: NetworkImage(user.profile!))),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 108, 233, 187),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 5),
        Container(
          width: 100,
          alignment: Alignment.center,
          child: Text(
            user.username!,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  Widget buildChatItemUser(UserModel userModel) {
    Message messager = Message(
        toId: '',
        msg: '',
        read: '',
        type: Type.text,
        fromId: '',
        sent: '',
        isDelete: false);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.center,
      child: StreamBuilder(
        stream: ChatMessageService.getLastMessage(userModel),
        builder: (context, snapshot) {
          List<Message> list = [];
          if (snapshot.hasData) {
            final data = snapshot.data!.docs;
            list = data.map((e) => Message.fromJson(e.data())).toList() ?? [];
          }
          if (list.isNotEmpty) {
            messager = list[0];
          }

          return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Stack(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  image:
                      DecorationImage(image: NetworkImage(userModel.profile!)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    color: userModel.isOnline!
                        ? const Color.fromARGB(255, 108, 233, 187)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ]),
            const SizedBox(width: 15),
            SizedBox(
              width: 200,
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userModel.username!,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 200,
                    child: messager.isDelete == true
                        ? const Text("The message is deleted!")
                        : Text(
                            messager.msg.isNotEmpty
                                ? messager.type == Type.image
                                    ? "Sent an image"
                                    : messager.msg
                                : userModel.bio!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: messager.read == '' &&
                                      messager.msg.isNotEmpty &&
                                      messager.fromId == userModel.id
                                  ? Colors.black
                                  : Colors.black54,
                              fontWeight: messager.read == '' &&
                                      messager.msg.isNotEmpty &&
                                      messager.fromId == userModel.id
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  messager.sent != ''
                      ? MyDateUtil.getLastMessageTime(
                          context: context, time: messager.sent)
                      : '',
                  style: TextStyle(
                    fontWeight:
                        messager.read == '' && messager.fromId == userModel.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

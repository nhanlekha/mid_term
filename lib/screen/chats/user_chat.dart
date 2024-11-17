import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mid_term/data/firebase_service/chat_message.dart';
import 'package:mid_term/data/model/message.dart';
import 'package:mid_term/data/model/usermodel.dart';
import 'package:mid_term/helpers/date_until.dart';
import 'package:mid_term/helpers/image_helper.dart';
import 'package:mid_term/screen/chats/components/app_bar_container.dart';

class UserChatPage extends StatefulWidget {
  const UserChatPage({super.key, required this.userChat});
  final UserModel userChat;

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  List<Message> listMessage = [];
  FocusNode focusNode = FocusNode();
  bool isChat = false;
  bool showIcon = false;
  bool isUploading = false;
  bool isUpdate = false;
  TextEditingController textController = TextEditingController();
  TextEditingController textUpdateController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final String _image = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBarContainer(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => ViewProfile(userModel: widget.userChat),
            //     ));
          },
          child: Container(
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      image: DecorationImage(
                          image: NetworkImage(widget.userChat.profile!))),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userChat.username!,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      widget.userChat.isOnline == true
                          ? "Đang hoạt động"
                          : "Hoạt động ${MyDateUtil.getActivityDate(widget.userChat.lastActive!)}",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.4), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          ImageHelper.loadFromAsset("assets/images/options.png", width: 35)
        ],
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      child: Column(children: [
        Expanded(
            child: Container(
                child: StreamBuilder(
          stream: ChatMessageService.getAllMessages(widget.userChat),
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.docs;
              listMessage =
                  data.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (listMessage.isEmpty) {
                return const Center(
                  child: Text(
                    'Say hi ✋!',
                    style: TextStyle(fontSize: 30),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: listMessage.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (listMessage[index].fromId == widget.userChat.id) {
                      return buildMessageUserRecive(listMessage[index]);
                    } else {
                      return buildMessageSend(listMessage[index]);
                    }
                  },
                );
              }
            } else {
              return ListView.builder(
                itemCount: listMessage.length,
                itemBuilder: (context, index) {
                  if (listMessage[index].fromId == widget.userChat.id) {
                    return buildMessageUserRecive(listMessage[index]);
                  } else {
                    return buildMessageSend(listMessage[index]);
                  }
                },
              );
            }
          },
        ))),
        if (isUploading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: Align(
              alignment: Alignment.centerRight,
              child: CircularProgressIndicator(),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40)),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20)),
              child: GestureDetector(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (focusNode.hasFocus) {
                        focusNode.unfocus();
                      }

                      showIcon = !showIcon;
                    });
                  },
                  child: const Icon(
                    Icons.emoji_emotions,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
                width: 240,
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        isChat = false;
                      });
                    }
                    if (value.isNotEmpty) {
                      setState(() {
                        isChat = true;
                      });
                    }
                  },
                  onTap: () {
                    if (focusNode.hasFocus) {
                      focusNode.unfocus();
                    }
                    setState(() {
                      showIcon = false;
                    });
                  },
                  focusNode: focusNode,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "Nhắn tin..."),
                )),
            isChat == true
                ? Expanded(
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          ChatMessageService.sendMessage(
                              widget.userChat, textController.text, Type.text);
                          setState(() {
                            textController.text = '';
                            isChat = false;
                          });
                        },
                        child: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            enableDrag: true,
                            elevation: 10,
                            // shape: ,
                            backgroundColor: Colors.transparent,

                            context: context,
                            builder: (context) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20))),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                        "Choose Image",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final XFile? image =
                                                await picker.pickImage(
                                                    source: ImageSource.camera);
                                            if (image != null) {
                                              ChatMessageService.sendImageChat(
                                                  widget.userChat,
                                                  File(image.path));
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: ImageHelper.loadFromAsset(
                                              "assets/images/camera.png"),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            List<XFile?> images =
                                                await picker.pickMultiImage();
                                            if (images.isNotEmpty) {
                                              for (XFile? image in images) {
                                                ChatMessageService
                                                    .sendImageChat(
                                                        widget.userChat,
                                                        File(image!.path));
                                              }
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: ImageHelper.loadFromAsset(
                                              "assets/images/picture.png"),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.image,
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.mic,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
          ]),
        ),
        if (showIcon)
          SizedBox(
            height: 300,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                if (emoji.emoji.isNotEmpty) {
                  setState(() {
                    isChat = true;
                  });
                }
              },
              textEditingController: textController,
              config: const Config(
                  emojiViewConfig:
                      EmojiViewConfig(columns: 7, emojiSizeMax: 30)),
            ),
          )
      ]),
    );
  }

  Widget buildMessageUserRecive(Message message) {
    if (message.read.isEmpty) {
      ChatMessageService.updateMessageRead(message);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: 5,
            ),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(widget.userChat.profile!))),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  border: Border.all(color: Colors.black38)),
              child: message.type == Type.image
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: CircularProgressIndicator(strokeWidth: 1)),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70),
                      ),
                    )
                  : Text(
                      message.msg,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      maxLines: null,
                    ),
            ),
          ),
          Text(
            MyDateUtil.getMessageTime(context: context, time: message.sent),
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  Widget buildMessageSend(Message message) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            textUpdateController.text = message.msg;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //
                  GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: message.msg));
                        Navigator.pop(context);
                      },
                      child: buildItemOption("Copy", Icons.copy)),
                  //
                  GestureDetector(
                      onTap: () {
                        // print("object");
                        Navigator.of(context).pop();
                        ChatMessageService.deleteTextMessage(message);
                      },
                      child: buildItemOption(
                          "Delete", Icons.delete_outline_rounded)),
                  //
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Updating"),
                              content: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextField(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none),
                                  controller: textUpdateController,
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("No",
                                        style:
                                            TextStyle(color: Colors.black38))),
                                TextButton(
                                    onPressed: () {
                                      if (textUpdateController.text != '') {
                                        Navigator.of(context).pop();
                                        ChatMessageService.updateTextMessage(
                                            textUpdateController.text, message);
                                      }
                                    },
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(color: Colors.redAccent),
                                    ))
                              ],
                            );
                          },
                        );
                      },
                      child: buildItemOption(
                          "Update", Icons.mode_edit_outline_outlined)),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (message.read.isNotEmpty)
              ImageHelper.loadFromAsset("assets/images/double_check.png",
                  width: 15),
            const SizedBox(
              width: 5,
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                  context: context, time: message.sent),
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                    border: Border.all(color: Colors.black38)),
                child: message.isDelete == true
                    ? const Text(
                        "Đã xóa tin nhắn này",
                        style: TextStyle(
                          color: Colors.black12,
                          fontSize: 15,
                        ),
                      )
                    : message.type == Type.image
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              width: 200,
                              imageUrl: message.msg,
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image, size: 70),
                            ),
                          )
                        : Text(
                            message.msg,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            maxLines: null,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemOption(String category, IconData icon) {
    return Container(
      child: Column(children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue[400],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          category,
          style: TextStyle(color: Colors.blue[400]),
        )
      ]),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  ChatUser user;
  String crop = "Rice";

  List<ChatMessage> messages = List<ChatMessage>();
  var m = List<ChatMessage>();

  var i = 0;

  @override
  void initState() {
    user = ChatUser(
      name: Provider.of<UserModel>(context, listen: false).phoneNumber,
      uid: Provider.of<UserModel>(context, listen: false).uid.toString(),
      avatar: "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
    );
    super.initState();
  }

  void showCropGrid(BuildContext context) async {
    List<String> crops = await getCrops(context);
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          message: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: GridView.count(
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 3,
              // Generate 100 widgets that display their index in the List.
              children: List.generate(crops.length, (index) {
                return GestureDetector(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(24, 165, 123, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: AutoSizeText(
                        crops[index],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      crop = crops[index];
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ),
          ),
          // cancelButton: CupertinoActionSheetAction(
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   child: Icon(
          //     Icons.close,
          //     size: 40,
          //     color: Color.fromRGBO(24, 165, 123, 1),
          //   ),
          // ),
          title: Text("Choose Crop"),
        );
      },
    );
  }

  void systemMessage() {
    Timer(Duration(milliseconds: 300), () {
      if (i < 6) {
        setState(() {
          messages = [...messages, m[i]];
        });
        i++;
      }
      Timer(Duration(milliseconds: 300), () {
        _chatViewKey.currentState.scrollController
          ..animateTo(
            _chatViewKey.currentState.scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
      });
    });
  }

  void onSend(ChatMessage message) async {
    print(message.toJson());
    var documentReference = Firestore.instance
        .collection('users')
        .document(Provider.of<UserModel>(context, listen: false).uid)
        .collection("messages")
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    Map<String, dynamic> map = message.toJson();
    map["type"] = crop;
    await Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        map,
      );
    });
    /* setState(() {
      messages = [...messages, message];
      print(messages.length);
    });

    if (i == 0) {
      systemMessage();
      Timer(Duration(milliseconds: 600), () {
        systemMessage();
      });
    } else {
      systemMessage();
    } */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(24, 165, 123, 1),
      body: SafeArea(
        child: Column(
          children: [
            ClipRRect(
              child: Container(
                color: Colors.white,
                child: Stack(children: [
                  SizedBox(
                    height: 0,
                  ),
                  Container(
                    decoration:
                        BoxDecoration(color: Color.fromRGBO(196, 243, 220, 1)),
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 15, bottom: 15),
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Container(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    crop,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Color.fromRGBO(24, 165, 123, 1),
                                      fontSize:
                                          MediaQuery.of(context).size.height >
                                                  600
                                              ? 25
                                              : 20,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Color.fromRGBO(24, 165, 123, 1),
                                    size: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            showCropGrid(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .document(
                        Provider.of<UserModel>(context, listen: false).uid)
                    .collection("messages")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  } else {
                    List<DocumentSnapshot> items = snapshot.data.documents;
                    List<ChatMessage> messages = new List<ChatMessage>();

                    for (DocumentSnapshot i in items) {
                      if (i.data["type"] == crop) {
                        messages.add(ChatMessage.fromJson(i.data));
                      }
                    }
                    return DashChat(
                      key: _chatViewKey,
                      inverted: false,
                      onSend: onSend,
                      sendOnEnter: true,
                      textInputAction: TextInputAction.send,
                      user: user,
                      inputToolbarMargin: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 15,
                      ),
                      inputDecoration: InputDecoration.collapsed(
                        hintText: "Add message here...",
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(24, 165, 123, 1),
                        ),
                      ),
                      dateFormat: DateFormat('yyyy-MMM-dd'),
                      timeFormat: DateFormat('HH:mm'),
                      messages: messages,
                      showUserAvatar: false,
                      showAvatarForEveryMessage: false,
                      scrollToBottom: true,
                      onPressAvatar: (ChatUser user) {
                        print("OnPressAvatar: ${user.name}");
                      },
                      onLongPressAvatar: (ChatUser user) {
                        print("OnLongPressAvatar: ${user.name}");
                      },
                      inputMaxLines: 5,
                      messageContainerPadding:
                          EdgeInsets.only(left: 5.0, right: 5.0),
                      alwaysShowSend: true,
                      inputTextStyle: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(24, 165, 123, 1),
                      ),
                      inputContainerStyle: BoxDecoration(
                        border: Border.all(width: 0.0),
                        borderRadius: BorderRadius.circular(200),
                        //color: Color.fromRGBO(24, 165, 123, 1),
                        color: Colors.white,
                      ),
                      onQuickReply: (Reply reply) {
                        setState(() {
                          messages.add(ChatMessage(
                              text: reply.value,
                              createdAt: DateTime.now(),
                              user: user));

                          messages = [...messages];
                        });

                        Timer(Duration(milliseconds: 300), () {
                          _chatViewKey.currentState.scrollController
                            ..animateTo(
                              _chatViewKey.currentState.scrollController
                                  .position.maxScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 300),
                            );

                          if (i == 0) {
                            systemMessage();
                            Timer(Duration(milliseconds: 600), () {
                              systemMessage();
                            });
                          } else {
                            systemMessage();
                          }
                        });
                      },
                      onLoadEarlier: () {
                        print("loading...");
                      },
                      shouldShowLoadEarlier: false,
                      showTraillingBeforeSend: true,
                      trailing: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.photo,
                            color: Color.fromRGBO(24, 165, 123, 1),
                          ),
                          onPressed: () async {
                            File result = await ImagePicker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 400,
                              maxWidth: 400,
                            );

                            if (result != null) {
                              final StorageReference storageRef =
                                  FirebaseStorage.instance
                                      .ref()
                                      .child(Provider.of<UserModel>(context,
                                              listen: false)
                                          .uid)
                                      .child("img" +
                                          DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString());

                              StorageUploadTask uploadTask = storageRef.putFile(
                                result,
                                StorageMetadata(
                                  contentType: 'image/jpg',
                                ),
                              );
                              StorageTaskSnapshot download =
                                  await uploadTask.onComplete;

                              String url = await download.ref.getDownloadURL();

                              ChatMessage message =
                                  ChatMessage(text: "", user: user, image: url);

                              var documentReference = Firestore.instance
                                  .collection('users')
                                  .document(Provider.of<UserModel>(context,
                                          listen: false)
                                      .uid)
                                  .collection("messages")
                                  .document(DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString());
                              Map<String, dynamic> map = message.toJson();
                              map["type"] = crop;
                              Firestore.instance
                                  .runTransaction((transaction) async {
                                await transaction.set(
                                  documentReference,
                                  map,
                                );
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Color.fromRGBO(24, 165, 123, 1),
                          ),
                          onPressed: () async {
                            File result = await ImagePicker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 400,
                              maxWidth: 400,
                            );

                            if (result != null) {
                              final StorageReference storageRef =
                                  FirebaseStorage.instance
                                      .ref()
                                      .child(Provider.of<UserModel>(context,
                                              listen: false)
                                          .uid)
                                      .child("img" +
                                          DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString());

                              StorageUploadTask uploadTask = storageRef.putFile(
                                result,
                                StorageMetadata(
                                  contentType: 'image/jpg',
                                ),
                              );
                              StorageTaskSnapshot download =
                                  await uploadTask.onComplete;

                              String url = await download.ref.getDownloadURL();

                              ChatMessage message =
                                  ChatMessage(text: "", user: user, image: url);

                              var documentReference = Firestore.instance
                                  .collection('users')
                                  .document(Provider.of<UserModel>(context,
                                          listen: false)
                                      .uid)
                                  .collection("messages")
                                  .document(DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString());
                              Map<String, dynamic> map = message.toJson();
                              map["type"] = crop;
                              Firestore.instance
                                  .runTransaction((transaction) async {
                                await transaction.set(
                                  documentReference,
                                  map,
                                );
                              });
                            }
                          },
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

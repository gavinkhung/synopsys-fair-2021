import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  ChatUser user;

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

    await Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        message.toJson(),
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
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(Provider.of<UserModel>(context, listen: false).uid)
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
            var messages =
                items.map((i) => ChatMessage.fromJson(i.data)).toList();
            return DashChat(
              key: _chatViewKey,
              inverted: false,
              onSend: onSend,
              sendOnEnter: true,
              textInputAction: TextInputAction.send,
              user: user,
              inputDecoration: InputDecoration.collapsed(
                hintText: "Add message here...",
                hintStyle: TextStyle(
                  color: Colors.white,
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
              messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
              alwaysShowSend: true,
              inputTextStyle: TextStyle(fontSize: 16.0),
              inputContainerStyle: BoxDecoration(
                border: Border.all(width: 0.0),
                color: Color.fromRGBO(24, 165, 123, 1),
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
                      _chatViewKey.currentState.scrollController.position
                          .maxScrollExtent,
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
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    File result = await ImagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxHeight: 400,
                      maxWidth: 400,
                    );

                    if (result != null) {
                      final StorageReference storageRef = FirebaseStorage
                          .instance
                          .ref()
                          .child(Provider.of<UserModel>(context, listen: false)
                              .uid)
                          .child("img" +
                              DateTime.now().millisecondsSinceEpoch.toString());

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
                          .document(
                              Provider.of<UserModel>(context, listen: false)
                                  .uid)
                          .collection("messages")
                          .document(
                              DateTime.now().millisecondsSinceEpoch.toString());

                      Firestore.instance.runTransaction((transaction) async {
                        await transaction.set(
                          documentReference,
                          message.toJson(),
                        );
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    File result = await ImagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                      maxHeight: 400,
                      maxWidth: 400,
                    );

                    if (result != null) {
                      final StorageReference storageRef = FirebaseStorage
                          .instance
                          .ref()
                          .child(Provider.of<UserModel>(context, listen: false)
                              .uid)
                          .child("img" +
                              DateTime.now().millisecondsSinceEpoch.toString());

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
                          .document(
                              Provider.of<UserModel>(context, listen: false)
                                  .uid)
                          .collection("messages")
                          .document(
                              DateTime.now().millisecondsSinceEpoch.toString());

                      Firestore.instance.runTransaction((transaction) async {
                        await transaction.set(
                          documentReference,
                          message.toJson(),
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
    );
  }
}

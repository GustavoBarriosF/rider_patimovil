import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessage(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('Chats')
        .orderBy('time', descending: false)
        .snapshots();
  }

  addConversationMessage(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('Chats')
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }
}

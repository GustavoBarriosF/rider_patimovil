// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:patimovil_rider/helpers/database_methods.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/utils/notification_messaging.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String idNewTrip;
  final String idUser;

  ChatPage({this.chatRoomId, this.idNewTrip, this.idUser});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  Stream chatMessageStream;

  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? SingleChildScrollView(
                reverse: true,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return MessageTile(
                          snapshot.data.documents[index].data()['message'],
                          snapshot.data.documents[index].data()['sendBy'] ==
                              userSnapshot.uid);
                    }),
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'message': messageController.text,
        'sendBy': userSnapshot.uid,
        'time': DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addConversationMessage(widget.chatRoomId, messageMap);
      messageController.text = '';
      if (widget.idNewTrip != null) {
        NotificationMessaging.sendNotificationChat(
            widget.idUser, widget.idNewTrip,
            statusMessaging: 'chat');
      }
    }
  }

  _animateToLast() {
    debugPrint('scroll down');
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void initState() {
    databaseMethods.getConversationMessage(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    controlNotification = false;
    // assetsAudioPlayer.open(Audio('sounds/perros.mp3'));
    // assetsAudioPlayer.play();
    audioPlayer
        .play('https://www.patimovil.net/sonidos/correcaminos-bip-bip-.mp3');
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controlNotification = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 10,
        backgroundColor: BrandColors.patiSecundary,
        title: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Text(
            'Inbox',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ChatMessageList(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: messageController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Mensaje',
                  labelStyle: TextStyle(
                    fontSize: 14,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Alerta',
                style: new TextStyle(color: Colors.black, fontSize: 20.0)),
            content: new Text('La accion que esta haciendo no es permitida.'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () =>
                    Navigator.pop(context), // this line dismisses the dialog
                child: new Text('Ok', style: new TextStyle(fontSize: 18.0)),
              )
            ],
          ),
        ) ??
        false;
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMy;

  MessageTile(this.message, this.isSendByMy);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMy ? 0 : 24, right: isSendByMy ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMy ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMy
                ? [BrandColors.patiSecundary, BrandColors.patiSecundary]
                : [BrandColors.patiPrimary, BrandColors.patiPrimary],
          ),
          borderRadius: isSendByMy
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23),
                ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

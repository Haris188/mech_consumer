
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../backend/chat_backend.dart';

class ChatScreen extends StatefulWidget {
  final String _mechId;
  final String _requestId;
  final String _screenType;

  ChatScreen(this._mechId,this._requestId,this._screenType);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _senderController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildChatScreen(),
    );
  }

  Widget _buildChatScreen(){
    return Container(
      child: Column(
        children: <Widget>[
          _createChatViewer(),
          _createMessageSender()
        ],
      ),
    );
  }

  Widget _createChatViewer(){
    return Expanded(
          child: FutureBuilder(
        future: _getChatStream(),
        builder: (BuildContext context, AsyncSnapshot streamSnap){
          return _createChatStream(streamSnap.data);
        },
      ),
    );
  }

  Widget _createChatStream(Stream<QuerySnapshot> stream){
    return StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> chatSnap){
        if(chatSnap.data != null){
          print('ran: if');
          return _createChatListViewFrom(chatSnap);
        }
        else{
          print('ran: else');
          return Container();
        }
      },
    );
  }

  Future<Stream<QuerySnapshot>> _getChatStream() async{
    return await ChatBackend(widget._mechId, widget._requestId).getChatStream();
  }

  Widget _createChatListViewFrom(AsyncSnapshot<QuerySnapshot> chatSnap){
    return ListView(
      reverse: true,
      children: _getChatMessages(chatSnap),
    );
  }

  List<ListTile> _getChatMessages(AsyncSnapshot<QuerySnapshot> chatSnap){
    return chatSnap.data.documents.map((doc){
      return _getListTileFor(doc.data);
    }).toList().reversed.toList();
  }

  ListTile _getListTileFor(Map<String,dynamic> docData){
    return ListTile(
      leading: CircleAvatar(
        child: Text(docData['name'][0]),
      ),
      title: Text(docData['text']),
    );
  }

  Widget _createMessageSender(){
    if(widget._screenType == 'active'){
      return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
          children: <Widget>[
            _getTextField(),
            _getSendBtn()
          ],
        ),
    );
    }
    else{
      return Container(
        color: Colors.grey.shade300,
        height: 45.0,
        child: Center(
          child: Text('Sending Message is not availabe for Archived quotes'),
        ),
      );
    }
  }

  Widget _getTextField(){
    return Expanded(
          child: TextField(
        controller: _senderController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Type your Message'
        ),
      ),
    );
  }

  Widget _getSendBtn(){
    return IconButton(
      icon: Icon(Icons.send),
      onPressed: (){_sendMsg();},
    );
  }

  Future<void> _sendMsg() async{
    String msg = _senderController.text;
    bool sendResult;
    if(msg.length > 0){
      sendResult = await ChatBackend(widget._mechId, widget._requestId).uploadMsg(msg);
      _senderController.clear();
    }
  }
}
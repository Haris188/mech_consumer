
import 'package:flutter/material.dart';

class RequestListingScreen extends StatefulWidget {

  final String _screenType;
  List<Map<String,dynamic>> _requests;

  RequestListingScreen(this._screenType);

  @override
  _RequestListingScreenState createState() => _RequestListingScreenState();
}

class _RequestListingScreenState extends State<RequestListingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildRequestListingScreen(),
    );
  }

  Widget _buildRequestListingScreen(){
    return FutureBuilder(
      future: _getRequestsFromDb(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String,dynamic>>> requests){
        widget._requests = requests.data;
        return _createRequestList();
      },
    );
  }

  Widget _createRequestList(){
    ListView.builder(
      itemBuilder: (BuildContext context, int index){
        return _createListItemTile(index);
      },
    );
  }

  Widget _createListItemTile(int index){
    return Container(
      child: ListTile(
        title: _getListTileTitle(widget._requests[index]['title']),
        onTap: (){
          _whenListItemPressed(index);
        },
      ),
    );
  }

  Widget _getListTileTitle(String text){
    return Text(
      text
    );
  }

  void _whenListItemPressed(int index){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context){
          return QuoteListScreen(widget._requests[index]['request_id']);
        }
      )
    );
  }

  Future<List<Map<String,dynamic>>> _getRequestsFromDb()async{
    return await RequestListingBackend().getRequestsFromDb(widget._screenType);
  }
}
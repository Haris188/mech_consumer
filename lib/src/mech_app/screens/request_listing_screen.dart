
import 'package:flutter/material.dart';
import '../backend/request_listing_backend.dart';
import 'quote_list_screen.dart';

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
        if(requests.data.length < 1){
          return _noRequestWidget();
        }
        if(requests.data[0]['result'] == 'timeout'){
          return _getTimeoutText();
        }
        else if(requests.data[0]['result'] == false){
          return _getLoadingWidget();
        }
        else{
          widget._requests = requests.data;
          return _createRequestList();
        }
      },
      initialData: [{'result': false}],
    );
  }

  Widget _noRequestWidget(){
    if(widget._screenType == 'active'){
      return _noRequestText('active');
    }
    else if(widget._screenType == 'archived'){
      return _noRequestText('archived');
    }
  }

  Widget _noRequestText(String text){
    return Center(
      child: Text(
        'No $text requests'
      ),
    );
  }

  Widget _getTimeoutText(){
    return Container(
      child: Center(
        child: Text("Cant load requests. Please check your internet"),
      ),
    );
  }

  Widget _getLoadingWidget(){
    return Container(
      child: Center(
        child: Text("Loading..."),
      ),
    );
  }

  Widget _createRequestList(){
    return ListView.builder(
      itemBuilder: (BuildContext context, int index){
        return _createListItemTile(index);
      },
      itemCount: widget._requests.length,
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
          return QuoteListingScreen(widget._screenType, widget._requests[index]['request_id']);
        }
      )
    );
  }

  Future<List<Map<String,dynamic>>> _getRequestsFromDb()async{
    return await RequestListingBackend().getRequestsFromDbFor(widget._screenType);
  }
}
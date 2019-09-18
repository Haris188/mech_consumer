
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../backend/quote_detail_backend.dart';

class QuoteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> _quoteInfo;
  final String _screenType;
  static Map<String, dynamic> _mechInfo;
  static BuildContext _context;
  final String _reqId;
  
  QuoteDetailScreen(this._screenType, this._quoteInfo, this._reqId);

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: _buildQuoteDetailScreen(),
    );
  }

  Widget _buildQuoteDetailScreen(){
    return FutureBuilder(
      initialData: false,
      future: _getMechInfo(),
      builder: (BuildContext context, AsyncSnapshot resultSnap){
        if(resultSnap.data){
          return _createQuoteScreenListView();
        }
        else{
          return _getLoadingWidget();
        }
      },
    );
  }

  Future<bool> _getMechInfo() async{
    Map<String, dynamic> mechInfo = await QuoteDetailBackend(_reqId).getMechInfo(_quoteInfo['mech_id']);
    if(mechInfo == null){
      return false;
    }
    else{
      _mechInfo = mechInfo;
      return true;
    }
  }

  Widget _createQuoteScreenListView(){
    return Container(
      child: ListView(
        children: _getListViewTiles(),
      ),
    );
  }

  List<Widget> _getListViewTiles(){
    print(_mechInfo);
    print(_quoteInfo);
    return <Widget>[
      _createListTileWith('Business Name', _mechInfo['business_name']),
      _createListTileWith('Phone',_mechInfo['phone']),
      _createListTileWith('Address',_mechInfo['address']),
      _createListTileWith('Quote Amount', '\$${_quoteInfo['quote_amount']}'),
      _createListTileWith('Schedual',_quoteInfo['schedual']),
      _createListTileWith('Description',_quoteInfo['description']),
      _createQuoteScreenBtn()
    ];
  }

  Widget _createListTileWith(String title, String subtitle){
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _createQuoteScreenBtn(){
    if(_screenType == 'active'){
      return Column(
        children: <Widget>[
          _createChatBtn(),
          _createAcceptRequestBtn()
        ],
      );
    }
    else{
      return _sparePadding(8.0);
    }
  }

  Widget _createChatBtn(){
    return RaisedButton(
      child: Text('Send Text'),
      onPressed: (){_whenChatPressed();},
    );
  }

  void _whenChatPressed(){
    // Fill it
  }

  Widget _createAcceptRequestBtn(){
    return RaisedButton(
      child: Text('Accept Quote'),
      onPressed: (){_whenAcceptQuotePressed();},
    );
  }

  Future<void> _whenAcceptQuotePressed() async{
    bool result = await QuoteDetailBackend(_reqId).acceptQuote();

    if(result){
      Navigator.pop(_context);
    }
  }

  Widget _sparePadding(double val){
    return Padding(
      padding: EdgeInsets.all(val),
    );
  }

   Widget _getLoadingWidget(){
    return Container(
      child: Center(
        child: Text("Loading..."),
      ),
    );
  }
}
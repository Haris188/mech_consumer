
import 'package:flutter/material.dart';
import 'package:tryst/src/mech_app/screens/quote_detail_screen.dart';
import '../backend/quote_list_backend.dart';

class QuoteListingScreen extends StatefulWidget {
  final String _screenType;
  final String _requestId;

  QuoteListingScreen(this._screenType, this._requestId);
  @override
  _QuoteListingScreenState createState() => _QuoteListingScreenState();
}

class _QuoteListingScreenState extends State<QuoteListingScreen> {
  static List<dynamic> _quoteList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildQuoteListScreen(),
    );
  }

  Widget _buildQuoteListScreen(){
    return _createQuoteFutureBuilder();
  }

  Widget _createQuoteFutureBuilder(){
    return Container(
      child: FutureBuilder(
        initialData: [{'result': false}],
        future: _getQuotesFromDb(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String,dynamic>>> quoteSnap){
          if(quoteSnap.data[0]['result'] == false){
            return _getLoadingWidget();
          }
          else{
            _quoteList = quoteSnap.data;
            return _createQuoteList();
          }
        },
      ),
    );
  }

  Future<List<Map<String,dynamic>>> _getQuotesFromDb()async{
    return await QuoteListBackend(widget._requestId).getQuoteListFromDb();
  }

  Widget _getLoadingWidget(){
    return Container(
      child: Center(
        child: Text("No Quotes Yet"),
      ),
    );
  }

  Widget _createQuoteList(){
    return ListView.builder(
      itemCount: _quoteList.length,
      itemBuilder: (BuildContext context, int index){
        return _getQuoteTileAt(index);
      },
    );
  }

  Widget _getQuoteTileAt(int index){
    return ListTile(
      title: Text('\$${_quoteList[index]['quote_amount'].toString()}',),
      subtitle: Text(_quoteList[index]['schedual']),
      onTap: (){_whenQuoteTilePressed(index);},
    );
  }

  void _whenQuoteTilePressed(int index){
    MaterialPageRoute route = _getQuoteDescriptionRoute(index);
    Navigator.of(context).push(route);
  }

  MaterialPageRoute _getQuoteDescriptionRoute(int index){
    return MaterialPageRoute(
      builder: (BuildContext context){
        return QuoteDetailScreen(widget._screenType, _quoteList[index], widget._requestId);
      }
    );
  }
}
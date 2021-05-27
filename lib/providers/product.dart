import 'package:flutter/foundation.dart'; //We import this so that we can use @required
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool
      isFavorite; //We wanted to notify our listeners whenever favourite button is clicked so we use ChangeNotifier here

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  /*void toggleFavoriteStatus() {
    isFavorite = !isFavorite;//Basically on Clicking we are toggling the state.The new value of isFavourite toggles whenever user clicks a button
    notifyListeners();
  }*/

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token,String userId) async {
    final oldStatus = isFavorite; //So that if something fails we can rollback and set it up again
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://flutterstuff-e097b-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
        //Here we are storing favourites for a particular user.SO i added /userFavourites to create a folder and /userId and /idto save it for a particular user
        //Basically we creating a folder structure
        //If we don't do this then favourites for whole thing would be toggled
    try {
      final response = await http.put(//For keeping a seperate tab for each user
        url,
        body: json.encode(
           isFavorite,
        ),
      );
      if (response.statusCode >= 400) {//>=400 shows a error
      //patch and delete don't throw an error like post so we have to use response code here for handling stuff
        _setFavValue(oldStatus);//We are rolling back to the favourite which we set up earlier
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}

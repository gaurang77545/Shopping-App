import 'package:flutter/material.dart';

import 'product.dart';

import 'dart:convert';

import '../models/http_exception.dart';

import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  //with keyword is used for mix in ie we don't inherit the whole class just a part of it
  //With provider I wanna manage all my list of Product classes and not a single class of Product so we create a seperate class for Product
  //ChangeNotifier is kinda like the inherited widget which Provider Package uses behind the scenes
  //Inherited widgets help in establishing comunication tunnels behind the scenes with the help of context object
  //Provider is used at the highest level usually .In our case ie main.dart other fiiles can also be used with Provider class

  List<Product> _items = [
    //We added some dummy products on our own
    // Product(//Commented it out coz we are now loading stuff from the Server
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;//FLAW =This should be a local filter and not an App wide filter
  // So if we had one more screen for example then this filter would be applied there as well which we don't want
  // We wanna declare a filter locally only
  //
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);
  List<Product> get items {
    //getter which returns list of items
    //Since _items is a private property we can't return it outside the class so we use a getter for extracting it outside a class
    // if (_showFavoritesOnly) {//We wanna return favourites list to our grid if showFavouritesOnly=true
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }

    return [..._items];
  }

  List<Product> get favoriteItems {
    //Returning List of Favourite item
    return _items
        .where((prodItem) => prodItem.isFavorite)
        .toList(); //isFavourite is a property of Product class
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {//This is local state stuff so we comment it outt
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> fetchAndSetProducts([bool filterByUser=false]) async {
    //By using [] we make the argument ie filterByuser as optional
    //We don't want the overall Products_overview_screen to get filtered .However we do want user_products_screen to get filtered by userid
    //Call it in ProductsOverview Screen
    //final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    //final url = Uri.parse(
     //  'https://flutterstuff-e097b-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString'); //Note that we gotta add /products.json after the link we got from firebase site
    //auth=$authToken is something which we add to authenticate our request
    //By adding & we add a filtering so that server only returms us the products which we want
    //We check creator Id and only if it is equal to user Id then only we show it
   //Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var _params;
    if (filterByUser) {
      _params = <String, String>{
        'auth': authToken,
        'orderBy': json.encode("creatorId"),
        'equalTo': json.encode(userId),
      };
    }
    if (filterByUser == false) {
      _params = <String, String>{
        'auth': authToken,
      };
    }
    var url = Uri.https('flutterstuff-e097b-default-rtdb.firebaseio.com',
        '/products.json', _params);
 
   
    try {
      final response = await http.get(url); //We are fetchng data
      final extractedData = json.decode(response.body)
          as Map<String, dynamic>; //You can also use <String,Object if u want>
       final url1=Uri.parse('https://flutterstuff-e097b-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
     //Note in url1 we extract it for a specific user by using /$userId
      //By doing this we are extracting favourite status for that particular user based on his needs and not the whole thing
      final favoriteResponse = await http.get(url1);
      final favoriteData = json.decode(favoriteResponse.body);//Extracting favourite items for a user
      final List<Product> loadedProducts = [];
      if (extractedData == null) {

        return;
      }
      extractedData.forEach((prodId, prodData) {
        //the key in the returned reponse is the proid and the value is the prodData hence we name the variables like that
        loadedProducts.add(Product(
          //add is a list function we haven't created it as such
          id: prodId, //We can directly use the key value
          title: prodData['title'], //Here we gotta extract
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
          //?? if favouriteData[prodid] is null then the part after ?? is stored
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts; //We are filling up the empty items list
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    //By using async u r converting your code to return a future value
    //Future<void> means Future is returned but it doesen't contain any value as such
    //By doin this we can return a value using which we can display a loading wcreen while the value is extracted from the web
    final url = Uri.parse(
        'https://flutterstuff-e097b-default-rtdb.firebaseio.com/products.json?auth=$authToken'); //Note that we gotta add /products.json after the link we got from firebase site

    //We got the url by copying it from the firebase site
    //Here products.json is the the name of the collection where we want it to be stored
    /*THE OLD METHOD IS COMMENTED OUT AND IS AT LINE NO. 114*/
    //Better than old one coz try catch is more readable
    try {
      //We don't need to return anything coz dart automatically returns future when async is used
      final response = await http.post(
        //The coming lines wait till this gets executed
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId':userId//We are also storing userId so that filtering can happen according to the users
          //creatorId tells who is the creator of the product ie who added it
          // 'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        //Coz await was used this acts as the part like then
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex =
        _items.indexWhere((prod) => prod.id == id); //Func runs on every element
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutterstuff-e097b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'); //We are accessing the id using this
      await http.patch(url, //patch is used to update
          body: json.encode({
            //We don't update the isFavourite coz we don't need to
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      //We found the product if index>=0
      _items[prodIndex] =
          newProduct; //We are finding the index at which the id is located and storing the product there
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    //_items.removeWhere((prod) => prod.id == id);
    final url = Uri.parse(
        'https://flutterstuff-e097b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[
        existingProductIndex]; //Using this we are doing optimmized updating
    //If due to some error we couldn't remove our item with the http.delete request to server we still have saved it in this variable so we can put it again to the list
    _items.removeAt(existingProductIndex);
    notifyListeners();
    //delete doesen't return an error.So to check the error we use something called status code which is a number which tells type of error
    //So we don't use try catch block here coz we are using status code for handlinh of errors
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex,
          existingProduct); //If some error occured we are re inserting back our product
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}

/*INSERT AT LINE NO. 93 AFTER FINAL URL
return http.post(//We are sending a request to the url
    //We are returning http.post coz it returns a future value
      url,
      body: json.encode({//We can't directly send object to the collection so we convert it into json which is readable by the machine
        'title': product.title,//We are passing a map 
        'description': product.description,//We are sending this data to our server
        'imageUrl': product.imageUrl,
        'price': product.price,
        'isFavorite': product.isFavorite,
      }),
    ).then((response) {//This would be executed only when post execution is finished
      
      final newProduct = Product(
      title: product.title, //accessing title of passed product
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      id: json.decode(response.body)['name']//Basically using thismwe can extract the id which firebase is generating for us and that
      //is better than using DateTime as the id.json.decode convert json into string
      //DateTime.now().toString(),
    );
    _items.add(newProduct);
    
    notifyListeners(); //Notifies Listeners that some changes was made
    //This class will soon be used by providers package which uses inherited widgets behind the scenes and there we establish a communication tunnel
    }).catchError((error) {//We should add catch Error after then so the error thrown both by post and then would be caught here
      print(error);
      throw error;//We throw this error from here so that it can be caught in EditProduct Screen and handled there
    });
    
  }
  */

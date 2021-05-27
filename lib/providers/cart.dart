import 'package:flutter/foundation.dart';

class CartItem {
  //You can define this in a seperate file as well if u want
//It doesen't have with ChangeNotifier so we can't use provider here howver we could had done that
  final String id;
  final String title;
  final int quantity;
  final double price; //Price per item
//Product Id and id is different
//Product id will be generated whenever a new type of product will be generated
//Item id will be generated whenever a new product is added same or diff doesen't matter
  CartItem({
    //CartItem will have a different id than the product it belongs to coz we have quatity here as well
    @required this.id, //This is the Item Id
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items =
      {}; //String here is the id which isused as a key in the map
  //Product id here is the key
  //Why product id is the key and not item id so that dupication is prevented
  //If same product is added again and again then the count in productId keyed element is increased
  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items == null
        ? 0
        : _items
            .length; //returns the no. of diff type of product we have .Doesen't count one item many times coz of quantity
  }

  double get totalAmount {
    //Calculate total amt by multiplying qty*price of 1 item
    var total = 0.0;
    _items.forEach((key, cartItem) {
      //We use forEach in case of map to go over all the entries .We pass the key ie key variable
      //and value ie cartitem variable in parenthesis
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(
    String productId,
    double price,
    String
        title, //We don't take qty as i/p coz quantity is always 1 here we can only add 1 item at a time
  ) {
    if (_items.containsKey(productId)) {
      //If _items already contains the item we just need to increase the quantity by one
      // change quantity...
      _items.update(
        productId, //The first argument here is the key ie productId
        (existingCartItem) => CartItem(
          //xistingCardItem is the item it found out for productId in the list
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity +
              1, //Adding one to the existing quantity
        ),
      );
    } else {
      //if item is not in _items we have to add a brand new item
      _items.putIfAbsent(
        //We put item if key ie productId is missing
        productId,
        () => CartItem(
          id: DateTime.now().toString(), //Id here is unique due to DateTime.now
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    //We take i/p of id which is also our key in the map
    _items.remove(productId); //We needed to put value of key here which is also our productID
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    //We are just deleting the given productId item 
    if (!_items.containsKey(productId)) {
      //If my list doesen't contain that product item I just return coz there isn't any point in removing something
      //which isn't there already
      return;
    }
    if (_items[productId].quantity > 1) {
      //If I have more than 1 items i just remove my last instance of it.SO the product is still there only the quantity is decreased by 1
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {//If there is only 1 quantity of item i remove it entirely
      _items.remove(productId);
    }
    notifyListeners();
  }
  void clear() {
    //To clear Cart
    _items = {};
    notifyListeners();
  }
}

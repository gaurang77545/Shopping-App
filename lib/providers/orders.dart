import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount; //Total Amount
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = []; //List of orders
  final String authToken;
  final String userId;
  Orders(this.authToken,this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders]; //Doing it so that outside Class we can't edit Orders
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutterstuff-e097b-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    //Fetched orders for a specific user using /$userId
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = []; //Initially our orderList is empty
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) { 
      //You can't call forEach on null so u gotta check if u don't have any orders
      _orders = loadedOrders;       // loadedOrders is initialized as an empty array
      notifyListeners ();
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData[
              'dateTime']), //We can convert String back to date Time coz we used toStringIso8601
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders =
        loadedOrders.reversed.toList(); //So that newest order is shown first
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    //Called from Cart SCreen
    final url = Uri.parse(
        'https://flutterstuff-e097b-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    //In firebase u will have one more table created by the name of orders
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp
            .toIso8601String(), //Special String convention for Date which we can convert back to DateTime when needed
        'products': cartProducts //An order consists of a list of cartItems
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0, //index where we wanna insert
      //This way we are inserting at the beginning so more recent items are at the beginning
      //By default new orders are inserted at the end of the list
      OrderItem(
        id: json.decode(response.body)[
            'name'], //We are using the id which Firebase generates for us
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}

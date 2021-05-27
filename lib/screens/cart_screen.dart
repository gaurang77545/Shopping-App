import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';

import '../providers/cart.dart' show Cart; //We have CartItem in both cart_item and Cart.dart as well however we aren't using both here.
//So using show I can just import one part of the file which I want and hence clash is avoided
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart'; //To come here we are using Named Route

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context); //I wanna listen when something changes coz the whole cart SCreen will be changing
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, //Adds Space bw text and total
                children: <Widget>[
                  Text(
                    'Total', //For displaying total amount
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(), //Basically pushes both the items around it to the opoosite ends
                  Chip(
                    //Like Badge ie element with rounded corners to display info
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',//Only 2 decimal places
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                   OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(height: 10), //Space b/w items and total
          Expanded(
            //List View inside of a column doesen't work right so we gotta use Expanded here
            //Expanded makes sure that it takes as much space as is left then how much space ie it can take
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                //We have to use .values.toList here coz we are getting returned a map where the key is the id and the values is where we have stored other things
                //
                cart.items.values.toList()[i].id, //Item Id
                cart.items.keys.toList()[
                    i], //coz remember we stored the id as keys there in Cart.dart
                //This is the product Id
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}
class OrderButton extends StatefulWidget {
  //We could create a seperate file for it if we want
  //We made this a seperate so that the whole thing doesen't get rebuild
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      //We show a indicator instead of the button when we are sending the data
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null//If we have null then the button would be disabeled 
          : () async {
              setState(() {
                _isLoading = true;//Loading thing instead of the button when items are being sent
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                //We are using values in our cart which is of type map
                //basically on pressing ORDER NOW all the items will be converted to a list of CartItems and function is executed
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
              //After placing orders we clear our list of orders from cart screen
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}


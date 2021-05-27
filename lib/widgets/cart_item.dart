import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      //Gives a nice animation of dismmising an item
      key: ValueKey(id), 
      background: Container(
        color: Theme.of(context).errorColor, //Color which comes in the background when we swipe left or right to remove an item
        child: Icon(
          //Comes in the background when we are about to remove an item
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      confirmDismiss: (direction) {//Showing something when we delete the item
      //Here we are asking the user for a confirmation
      //We are returning a future in confirm Dismiss.However showDialog also returns a future
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(//We use this dialog for alerting and stuff
                title: Text('Are you sure?'),
                content: Text(
                  'Do you want to remove the item from the cart?',
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);//We return false so we are not confirming the dismissal
                    },
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);//We confirm the dismissal
                    },
                  ),
                ],
              ),
        );
      },
      direction: DismissDirection .endToStart, //Direction in which we wanna delete it.The other direction it doesen't work
      //Only from Right To left
      onDismissed: (direction) {//Takes direction argument .So if u wanna do something different when u r swapping in different directions
      //You can use it
        Provider.of<Cart>(context, listen: false).removeItem(productId);//nstead of creating a seperate variable we directly call function here
        //Note that here we are removing the whole product altogether quantity doesen't matter here
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  //To ensure text fits into the circle
                  child: Text('\$$price'), //Price of 1 item
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'), //Total Price
            trailing: Text('$quantity x'), //Quantity of items
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;//In case of name clash ie OrderItem was at 2 places ie orders.dart and our file as well where we
//aare using OrderItem.We need both things so what we do is use 'as' here to point out which one we are using

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;//We defined our package as ord earlier

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;//Tells whether to show details or not on clicking of button in order screen

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded?min(widget.order.products.length * 20.0 + 10, 110):200,
          child: Card(
        margin: EdgeInsets.all(10),
        child: Column(//We used Column inside Card because we wanted Card to be expandable ie things opens up on clicking something
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(//To expand our order
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),//Display different icons according to the state of toggle button
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;//On clicking this button we toggle value basically
                  });
                },
              ),
            ),
           // if (_expanded)//Removed it coz we gotta use Animated Container here
              AnimatedContainer(
                //We gotta animate these items as well
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                //If it is not expanded we gotta use height =0 coz no items will be displayed
                height: _expanded?min(widget.order.products.length * 20.0 + 10, 110):0,//Basicaaly we give the container 2 values and depending on whichever is lower
                //It will use that value . widget.order.products.length would give u basically no. of orders that are in there and we assume
                //that each product takes 20 of space and then we add 10 for some spacing and stuff
                //We use widget.products to capture the products which are in a different class
                child: ListView(
                  children: widget.order.products//We can also use ListView.builder here if we want
                      .map(
                        (prod) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[//We are defining what a single item here is
                                Text(
                                  prod.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${prod.quantity}x \$${prod.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                      )
                      .toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}

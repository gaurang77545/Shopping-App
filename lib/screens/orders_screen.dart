import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/app_drawer.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  //When we click on order Now in my cart screen my orders are displayed here on this screen
  //ie when i place my order I can see it here
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {//We used a different approach than didChangeDependencies
      setState(() {//Even thou it is instantly resolved coz of Duration.zero we still extecute then after it
       //You can't use async in initState however u can use it in delayed im the anonymous function
        _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //You can also use FutureBuilder here if u don't want your widget to be build again and again
    //Using Future Builder u can convert this into a stateless Widget
    //Checkout Sending HTTP Requests-> finished folder -> Orders screen for this
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          :ListView.builder(
        itemCount: orderData.orders.length,
        itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
      ),
      drawer: AppDrawer(), //I want my app drawer to be shown here
    );
  }
}

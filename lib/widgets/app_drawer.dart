import 'package:flutter/material.dart';
import 'package:shop/screens/user_products_screen.dart';

import '../screens/orders_screen.dart';
import 'package:provider/provider.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';
//import '../helpers/custom_route.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      //The thing which comes on the left side of app when i clickon 3 lines in AppBar
      //Basically whichever window u want ur app Drawer to be seen u write drawer:AppDrawer() inside  sccafold there
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend!'),
            automaticallyImplyLeading:
                false, //It will never add a back button to the appBar
          ),
          Divider(), //Nice little horizontal line
          ListTile(
            leading: Icon(Icons
                .shop), //We will go to our shop overview page if we click on this List Tile
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(OrdersScreen
                  .routeName); //I wanna goto my Orders screen on clicking this
              //If you want the Fade animation which we created in the custom_route.dart file u can use this method and fade in will happen for this specific screen transition and not for all
              // Navigator.of(context).pushReplacement(
              //   CustomRoute(
              //     builder: (ctx) => OrdersScreen(),
              //   ),
              // );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(UserProductsScreen
                  .routeName); //I wanna goto my Orders screen on clicking this
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop(); //To close the app drawer as well

            
              Navigator.of(context).pushReplacementNamed('/');
              //We goto the auth screen using '/'
              Provider.of<Auth>(context, listen: false).logout();
            },
          )
        ],
      ),
    );
  }
}

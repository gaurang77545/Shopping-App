import 'package:flutter/material.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/screens/edit_product_screens.dart';
import 'package:shop/screens/orders_screen.dart';
import 'package:shop/screens/user_products_screen.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //We use MultiProvider in case we are having Multiple Providers
      providers: [
        ChangeNotifierProvider(
          //We don't use .value here in main.dart
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          //Proxy Provider is used to send value from one provider to another using tokens
          //We use this for creating a dependency
          //By doing this we are depending on the value ie tokenw provided by Auth.If we are dependent on something write that statement below which you are dependent to
          //token is used for authenticating requests
          update: (ctx, auth, previousProducts) => Products(
            auth.token, //We can access token of auth since we are depending on it now
            auth.userId,
            previousProducts == null
                ? []
                : previousProducts.items, //Basically we don't want our existing items to get lost
            //previousProducts represents our existing list
          ),
          create: null,
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          //Dependency is AUth and provider is Orders
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
          create: null,
        )
      ],
      //Provider needs to be provided at the highest level of all the widgets which will be interested in this
      //Provider provides an instance of Product Class to all its listeners
      //Whenever we change something in Products then  notifyListener is called
      //only the CHILD widgets which are listening wil be rebuilt
      //Provider<String>(builder: (ctx) => 'Hi, I am a text!', child: ...);You can even provide strings like this using Provider
      //value: Products(),//We don't use it in main coz its bad habit to use it where we re initializing stuff
      child: Consumer<Auth>(
        //Changing only this part
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android:
                    CustomPageTransitionBuilder(), //We are setting the default page transition for android and ios using this
                //We call our builder function in custom_route.dart file
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen() //Whenever auth changes this thing is rebuild.So we run getter isAuth again and that time we do have a token with us coz of autoLogin and hence we will show the productsoverviewScreen
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  //We use a future builder which depends on the future value of autoLogin ie true or fals
                  builder: (ctx, authResultSnapshot) => authResultSnapshot
                              .connectionState ==
                          ConnectionState.waiting
                      ? SplashScreen() //Show waiting spinner if it is waiting
                      : AuthScreen(),
                ), //If user is logged in I show the product Overview Screen
          routes: {
            CartScreen.routeName: (ctx) => CartScreen(),
            ProductDetailScreen.routeName: (ctx) =>
                ProductDetailScreen(), //Because of this Product detail screen is also a part of provider class
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen()
          },
        ),
      ),
    );
  }
}

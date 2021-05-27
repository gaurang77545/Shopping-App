import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);//Getting it from products_overview Screen
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(
        context); //Sets up a direct communication Channel behind the Scenes
    //only this widget changes nothing else.So whenever the screen rebuilds only this thing builds up again
    //Even though we are calling it from ProductOverview that doesen't rebuild only this thng rebuilds again
    //<Products> tell that we wanna listen to the instance of type Products
    final products =showFavs?productsData.favoriteItems: productsData.items; //items is a getter in Products
    //Is showFavs is true I extract a diffrent list from Providers class

    return GridView.builder(
      //GridView.builder works good in case of longer items when we don't know no. of items
      padding: const EdgeInsets.all(10.0), //const should be added wherever u can improves performance in general
      itemCount: products.length,

      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        //You should use ChangeNotifier.Provider.value if u r using something that's part of list or grid
        //Issue is flutter recycles widgets and the data ataached to it changes.Using .value we make sure provider works even if data changes for widget
        //We don't use it in main thou there we only use ChangeNotifierProvider

        value: products[i], //We have added a provider for products[i] which is of type Prooduct not Products
        // create: (c) => products[i],//Will return a single object multiple times for all the products I have
        //
        child: ProductItem(
            //Earlier we were passing values thorugh constructor but due to provider class we don't need to do em anymore
            // products[i].id,/We are forwarding 3 items to product item class
            // products[i].title,
            // products[i].imageUrl,
            ),
      ),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //Using this we can fix the no. of columns we are gonna use
        crossAxisCount: 2, //2 columns
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}

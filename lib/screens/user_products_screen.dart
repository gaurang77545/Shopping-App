import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/edit_product_screens.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  //Wanna show list of products of users
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context,listen: false).fetchAndSetProducts(true);//Only when fetch and Set products is done then only future is returned
  }//We don't wanna listen to updates just wanna set the list
  //We want filtering to happen in this screen hence we pass true

  @override
  Widget build(BuildContext context) {
   // final productsData = Provider.of<Products>(context); There would be an infinite loop coz there is also a future Builder inside and everytime the screen is changed it would be rebuilt
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            //+ button which allows us to take to new screen when we click on it
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
              future: _refreshProducts(context),//It waits for this to get executed ie once the product is refreshed then only the product is loaded on the screen
              builder:(ctx,snapshot)=> snapshot.connectionState==ConnectionState.waiting?Center(child: CircularProgressIndicator(),): RefreshIndicator(//Helps us to do things like refresh when we pull down the screen
          onRefresh: () => _refreshProducts(context) ,//The return type of onRefresh is Future
                child: Consumer<Products>(
                  builder: (ctx,productsData,_)=>
               Padding(
            padding: EdgeInsets.all(8),
            child: ListView.builder(
              itemCount: productsData.items.length,
              itemBuilder: (_, i) => Column(
                  children: [
                    UserProductItem(
                      productsData.items[i].id,
                      productsData.items[i].title,
                      productsData.items[i].imageUrl,
                    ),
                    Divider(), //To have some space b/w 2 items
                  ],
              ),
            ),
          ),
                ),
        ),
      ),
    );
  }
}

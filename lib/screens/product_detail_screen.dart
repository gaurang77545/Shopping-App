import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/app_drawer.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  //Opens up when we click a screen
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =ModalRoute.of(context).settings.arguments as String; // is the id!
    //final loadedProduct = Provider.of<Products>(context).items.firstWhere((prod) => prod.id=productId)
    //We moved the calculating part into the provider class Products so that the computation can be done in provider class only
    //NOTICE WE CAPTURED THE PRODUCT ID USING MODAL ROUTE AND THEN USED THAT ID IN PROVIDER TO LISTEN TO THE PRODUCTS AND CAPTURE THE RIGHT PRODUCT
    final loadedProduct = Provider.of<Products>(context,listen:false, 
      //Meaning of listen=false=>When Products is changed this is not rebuilt again.Default value=true
      //We only need data one time and don't wanna update
      //In products grid we do wanna update for sure coz the new product comes there and we wanna display it there
    ).findById(productId); //findViewbyid is the function we created in the provider class
    // ...
    return Scaffold( //Since this Screen captures thw whole screen we use Sccafold here
      //appBar: AppBar(//We remove AppBar coz we are using CustomScrollView here so we gotta define it inside that
        //title: Text(loadedProduct.title),
      //),
     // body: SingleChildScrollView(
       body: CustomScrollView(//We replace SingleChildScrollView with a CustomScrollView
        slivers: <Widget>[//Slivers just tell the Scrollable part of the screen
          SliverAppBar(
            expandedHeight: 300,//height which will be of the image when it is shown
            pinned: true,//ie AppBar is shown when we Scroll down instead of the image iw AppBar is pinned
            flexibleSpace: FlexibleSpaceBar(//What will be shown when we scroll down.We write the Appbar stuff here therefore
              title: Text(loadedProduct.title),//Appbar title
              background: Hero(//When we are in the top of the page the Hero widget will be shown with the image
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        //we are now using Silver List instead of Column
      //  child: Column(//Used Column with SingleChildScrollView coz we have different items here and not a ListView
        /*  children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: Hero(
                tag: loadedProduct.id,//For transitioning from product_item screen the value of tag must remain same
                              child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),*/
            SliverList(
            delegate: SliverChildListDelegate(//Used to define the list of items which will be behaving normally in a scroll view
              [
            SizedBox(height: 10),
            Text(
              '\$${loadedProduct.price}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,//Wraps into container if no more space
              ),
                ),
                SizedBox(height: 800,),//So that we can scroll else the content was so less we couldn't scroll
              ],
            ),
          ),
        ],
      ),
    );
  }
}

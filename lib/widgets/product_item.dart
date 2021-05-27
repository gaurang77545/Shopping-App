import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  //final String title;
  //final String imageUrl;

  //ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context,
        listen:
            false); //Note that this time it is Provider of Product and not Products
    final cart = Provider.of<Cart>(context,
        listen:
            false); //listen here is false coz i just wanna tell that i have added an item to the cart don't wanna hear updates
     final authData = Provider.of<Auth>(context, listen: false);
     //Auth is sending token from main.dart i am using it here
    return ClipRRect(
      //Adds rounded corners around the Grid Tile.RRect=Rounded Rectangle
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        //Works anywhere but is great for use in grids
        child: GestureDetector(
          //We wrap a gesture detector on the image so whenever we click it something opens up
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
         /* child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover, //Take all the available space it can get
          ),*/
          child:Hero(//We use it for Transition b/w two pages
            tag: product.id,//need to provide this tag value at 2 places ie the 2 pages b/w which we are transitioning
          child: FadeInImage(//For the Animation
            placeholder: AssetImage('assets/images/product-placeholder.png'),
            //Placeholder image which we are gonna show
            image: NetworkImage(product.imageUrl),//Image which is gonna show in place of the placeholder
            fit: BoxFit.cover,
          ),
        ),
        ),
        footer: GridTileBar(
          //Used to display text on the image in 1 tile
          backgroundColor: Colors.black87, //background color of text
          leading: Consumer<Product>(
            //Only runs a part of the widget when it is reloaded
            //<Product>=what type of data we wanna consume
            //Only sub part of widget tree runs when the data changes
            //Notice that the listen is false here so it isn't listening as such to changes but by addidng Consumer only this part of consumer
            //Actually changes or reloads on hearing changes.The rest part of the widget remains the same
            builder: (ctx, product, child) => IconButton(
              //Placing items on the start of the footer
              //ctx=context,product=Our nearest type of instance which it can find of our datatype written in <>
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(authData.token,authData.userId);
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            //Placing items on the end of the footer
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(
                  product.id,
                  product.price,
                  product
                      .title); //Add item to the cart by calling function which we built earlier
              Scaffold.of(context).hideCurrentSnackBar();//We us this to hide the previous SnackBar which is showing so that their timings don't overlap
              Scaffold.of(context).showSnackBar(
                //Shows kind of like a toast message when we use it
                //Sccafold.of finds the nearest Sccafold to it and use that
                SnackBar(
                  content: Text(
                    'Added item to cart!', //Message that is displayed
                    textAlign:
                        TextAlign.center, //Aligns Toast message to center
                  ),
                  duration: Duration(seconds: 2), //duration of message
                  action: SnackBarAction(
                    //We can define something which is displayed like a button the snackbar message
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(
                          product.id); //Calling function in cart.dart
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

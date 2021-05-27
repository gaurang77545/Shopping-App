import 'package:flutter/material.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/products_grid.dart';
import '../widgets/badge.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
} //Enums can't be declared inside Classes

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
   var _isLoading = false;

    void didChangeDependencies() /*async*/ {//You shouldn't use async coz these methods are pre defined and u can't change what they return
    //Since we don't use async we use then instead of that
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {//Gotta load stuff first
        setState(() {
          _isLoading = false;//Coz if i have fetched and set the products then I am done
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //final productsContainer=Provider.of<Products>(context,listen:false)
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            //adds 3 dots thingy on AppBar
            onSelected: (FilterOptions selectedValue) {
              //FilterOptions is the type of selected value
              //onSelected:(int selected value){} The selected value would be the value ie 1 or 2 we choose from itemBuilder
              //The int in paranthesis tells it type
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  //productsContainer.showFavouritesOnly()//Accessing method of Products Class
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                  //productsContainer.showAll()
                }
              });
            },
            icon: Icon(
              Icons.more_vert, //3 dots
            ),
            itemBuilder: (_) => [
              //itemBuilder is giving me  a context but I am not using it
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions
                    .Favorites, //We used a enum here instead of integer
                //value:0
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
                //value:1
              ),
            ],
          ),
          Consumer<Cart>(
            //We used Consumer here coz we want only this part to be rebuilt
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount
                  .toString(), //I am getting cart from the argument in the builder
            ),
            child: IconButton(
              //child doesen't get rebuilt .We don't want icon button to be rebuilt so we pass it into child
              //This child automatically becomes ch and is passed into builder as argument
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),//I want my AppDrawer to be shown here that's why
      body:_isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          :
       ProductsGrid(_showOnlyFavorites),
    );
  }
}

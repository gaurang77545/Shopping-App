import 'package:flutter/material.dart';
import 'package:shop/screens/edit_product_screens.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  //Single item on the user_product_screen
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id,this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
        final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        //Image will be displayed in a avatar
        backgroundImage: NetworkImage(
            imageUrl), //backgroundImage uses a Image provider ie NetworkImage.
        //Not the old Image.asset which we were using
      ),
      trailing: Container(
        width:
            100, //Row takes as much space as it can get so we arerestricting it kinda
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit), //I wanna edit my item
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete), //I wanna delete my item
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id); //We are setting listen to false coz we don't wanna listen to change only execute delete function when required
                } catch (error) {
                  scaffold.showSnackBar(//You can't call Sccafold.of(context) from inside a future function so we gotta define sccafold outside as a variable and use it here
                    SnackBar(
                      content: Text('Deleting failed!', textAlign: TextAlign.center,),
                    ),
                  );
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}

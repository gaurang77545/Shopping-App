import 'package:flutter/material.dart';
import 'package:shop/providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  //Screen which opens up when we click on userproducts_screen in the edit button
  //We use stateful Widget here coz we wanna manage user i/p as a local state here
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode =
      FocusNode(); //Used for movinf cursor to the next entry on clicking the next button

  final _descriptionFocusNode = FocusNode();

  final _imageUrlController =
      TextEditingController(); //We use a controller in case of image coz we wanna show preview of image on screen using url entered in text box
  //We need the url before form is submitted so we gotta use controller here

  final _imageUrlFocusNode =
      FocusNode(); //We use this focus node not for bringing things into focus
  //However we use it when things go out of focus to handle stuff

  final _form = GlobalKey<FormState>();
//We use this key to access state of widgets inside Form

  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true; //So that we execute didChangeDependencies only once
  var _isLoading =
      false; //To show isLoading when the data is being extracted from the internet
  @override
  void didChangeDependencies() {
    if (_isInit) {
      //So that we execute it only one time
      final productId = ModalRoute.of(context).settings.arguments
          as String; //This wasn't gonna work in initState so we use it here.
      //Also didChangeDependecies also works before build like initState however it runs many times
      //So to only make it run one time we use a condn check
      //We capture the id we got from user Product Screen
      if (productId != null) {
        // We are getting here from 2 ways.
        //One is the user Product screen where we are passing no arguments and the second is user_product_item where we do pass an argument
        //Hence if we get no argument i/p to productId then there might be error so we gotta check
        _editedProduct = Provider.of<Products>(context, listen: false).findById(
            productId); //We set the initial value of our new product as the old product
        _initValues = {
          //We will fill our text fields with the initial values in this
          'title': _editedProduct
              .title, //We are setting the values of our initValues
          'description': _editedProduct.description,
          'price': _editedProduct.price
              .toString(), //Wanna give i/p as Strings.Textfields only work with Strings
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct
            .imageUrl; //Setting the initial value in textController
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void dispose() {
    //You need to clear state of focus node once their work is done
    //If we keep them still then it will lead to memory leak
    _imageUrlFocusNode.removeListener(
        _updateImageUrl); //Remove listener pointed by this function ie _updateImageUrl
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    //async waits only where we have written async before our line of code
    //Remember that there are 2 jobs here of adding a product and editing a product
    final isValid = _form.currentState
        .validate(); //Returns true if every validator in form returns true
    if (!isValid) {
      return;
    }
    _form.currentState
        .save(); //We are executig the onSave method of all the entries within form
    //This way our editedProduct gets saved
    //We are getting 2 typeof cases here .When we click save button and when we click edit Button
    //Notice initial value of edited Product id is null and that is used when we create a new product
    //In case of existing product we get an id using ModalRoute
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      //We are editing an existing product
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      //We are adding a new product
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          //Show Dialog returns a future so we gotta await before moving to finally
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      //.catchError((error) {//We are catching the error thrown in prroducts.dart

      //  }) .then((_) {//then will be executed on catch Error coz catch Error also returns a future object
      //    finally {//Always Executed
      //     setState(() {
      //       _isLoading =
      //           false; //We set isLoading to false coz the product is loaded from the intrenet and we don't want loader to be shown anymore
      //     });
      //     Navigator.of(context).pop(); //Our addProduct is returning a future so we use then here for that so we close it
      //   }
      // }
      // Navigator.of(context).pop();
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    _imageUrlFocusNode
        .addListener(_updateImageUrl); //We add a listener to the focus node
    //Now when the image goes out of focus then only we are gonna load the image up
    //_updateImageurl is the function which will be executed whenever the focus changes
    //Note that we didn't use () in func call here coz we don't wat it to get executed here
    //Instead we just want it executed whenever the thung goes out of focus
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      //Watch video no. 229
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            //Adds a button to submit stuff
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(), //Show the loading thingy
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                //We use form widget so that we don't have to validate stuff and all
                //Form is an invisible widget
                //autovalidate: true ,We can use this for validation as well if we want
                key: _form, //Assigned key

                child: ListView(
                  //For long forms use SingleChildScrollView+Column
                  //For short forms ListView works fine

                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),

                      textInputAction: TextInputAction
                          .next, //What we wanna show on the keyboard in place of enter key
                      //Using this we will show the next button on the keyboard to go to the next field for entering
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(
                            _priceFocusNode); //On Clicking next button we are taken to
                        //The entry with focussed node ie _priceFocusNode
                      },
                      validator: (value) {
                        //value is the i/p we wrote
                        if (value.isEmpty) {
                          //If i/p text field is empty we return the error text
                          return 'Please provide a value.'; //Error message
                        }
                        return null; //Means everything is fine
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            //Basically we are uisng all the old values only and overwriting one value ie user i/p for this TextFormField
                            title: value, //value here is the user i/p
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct
                                .isFavorite); //If we don't initialize isFavourite then its status will be lost
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      initialValue: _initValues['price'],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value) == null) {
                          //try parse returns null if it is false.It will do that if it can't parse string into double
                          //ex. he may enter the number in words ie hundred so parsing won't be possible
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: double.parse(
                              value), //value is a string and we expect a number
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: _initValues['description'],
                      maxLines:
                          3, //Description is usually long so by using this we define how many lines of description we gotta define
                      keyboardType: TextInputType
                          .multiline, //Use keyboard suitable for multiline i/p.Gives enter key for next line
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description.';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          //For showing image preview
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController
                                  .text.isEmpty //Show the preview here
                              ? Text('Enter a URL')
                              : FittedBox(
                                  //Loads the image up
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          //For entering URL
                          child: TextFormField(
                            //textFormField takes as much space as it can get and row also does the same so we gotta wrap it in Expamded
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType
                                .url, //Gives keyboard only for urls
                            textInputAction: TextInputAction.done,
                            controller:
                                _imageUrlController, //If u have controller u can't set initialField attribute here
                            //Instead of that u can give an initial value to the controller
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              //On click on the submit button here we re saving the form basically by executing the function
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }
                              if (!value.endsWith(
                                      '.png') && //We covered some basic formats of pics only but i works for us
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

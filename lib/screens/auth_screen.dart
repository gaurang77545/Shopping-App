import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';

import '../providers/auth.dart';

enum AuthMode { Signup, Login }
//We'll use it show which type of forms we are showing

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // Matrix 4 provides transformation of container.It's a class.pi is like 3.14 it comes with math:dart
    // We are rotating about the z axis ie from your eye into the phone
    // transformConfig.translate(-10.0);//translate is used to add some offset
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],//The no.of stops must be same as the no.of colors
                //The values in the stops list must be in ascending order.
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      //Due to this the whole logo is rotated
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [//Used to cast a Shadow
                          BoxShadow(
                            blurRadius: 8,//This property takes in a double value as the object. It controls the haziness on the edges of the shadow.
                            color: Colors.black26,//
                            offset: Offset(0, 2),//Offset class is the object given to this property which controls the extent to which the shadow will be visible.
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  //Hold a stateful widget which is used for authentication
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller; //To start and stop animation
  Animation<Size>
      _heightAnimation; //Size tells the type of Animation we want and on which attribute
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:
          this, //Tells Flutter that we animate only once it is visible to the user
      duration: Duration(
        milliseconds:
            300, //You can tell both forward and backward duration for the animation however here we only tell one duration
      ),
    );
    _slideAnimation = Tween<Offset>(//Offset is used to store 2d coordinates
      //Use this for sliding in
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _heightAnimation = Tween<Size>(
            //Tween knows how to animate b/w two values
            begin: Size(double.infinity, 260),
            end: Size(double.infinity, 320))
        //Size consists of width,height.So width we don't change however we do change the height
        .animate(
      CurvedAnimation(
        parent: _controller, //controller which controls the animation
        curve: Curves
            .fastOutSlowIn, //How u want the animation to come in.This one starts slow and ends fast
      ),
    );
    _heightAnimation.addListener(() => setState(
        () {})); //We didn't pass anything in setState coz we don't want that we just want to redraw the thing
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
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

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(
          _authData['email'],
          _authData['password'],
        )
            .catchError((error) {
          // throw error;
          var errorMessage = 'Authentication failed';
          if (error.toString().contains('EMAIL_EXISTS')) {
            errorMessage = 'This email address is already in use.';
          } else if (error.toString().contains('INVALID_EMAIL')) {
            errorMessage = 'This is not a valid email address';
          } else if (error.toString().contains('WEAK_PASSWORD')) {
            errorMessage = 'This password is too weak.';
          } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
            errorMessage = 'Could not find a user with that email.';
          } else if (error.toString().contains('INVALID_PASSWORD')) {
            errorMessage = 'Invalid password.';
          }
          _showErrorDialog(errorMessage);
        });
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signup(
          _authData['email'],
          _authData['password'],
        )
            .catchError((error) {
          //throw error
          var errorMessage = 'Authentication failed';
          if (error.toString().contains('EMAIL_EXISTS')) {
            errorMessage = 'This email address is already in use.';
          } else if (error.toString().contains('INVALID_EMAIL')) {
            errorMessage = 'This is not a valid email address';
          } else if (error.toString().contains('WEAK_PASSWORD')) {
            errorMessage = 'This password is too weak.';
          } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
            errorMessage = 'Could not find a user with that email.';
          } else if (error.toString().contains('INVALID_PASSWORD')) {
            errorMessage = 'Invalid password.';
          }
          _showErrorDialog(errorMessage);
        });
      }
    } on HttpException catch (error) {
      //Here on is used for specific errors ie of type HTTP Exception only
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      //Here we are catching the general errors only
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    //Used for switching from auth mode to sign up mode and vice versa
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward(); //starts the animation
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller
          .reverse(); //You wanna reverse the annimation when u are going from signup to login
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      //child:AnimatedBuilder(//Builds something once something is done
      //We don't need to use listeners like before if we use this
      // animation: _heightAnimation,
      //builder:(ctx,ch) => Container(
      //Builder builds only the part which is inside builder function
      //Animation builder also has a child argument which doesen't get rebuild everytime
      child: AnimatedContainer(
        //If we use Animated Container then unlike Animated Builder we don't need any kind of controller
        //Even the height it automatically detetcts that it is changing so it smoothly changes stuff
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup
            ? 320
            : 260, //height depends whether we are in signup or authentication mode
        // height: _heightAnimation.value.height,//the height is now gonna change overtime unlike before
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        //child: ch//Child of builder
        //),

        child: Form(
          //This child doesen't get rebuilt.This is the child of the Animated Builder
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  //We are animating Confirm password here once it comes on changing from login to signup
                  constraints: BoxConstraints(//So that Confirm password doesen't go out of the screen
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(//We have added 2 transitions here ie Fade+slide in
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText:
                            true, //Means that it writes in form of * on screen and not text
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize
                      .shrinkWrap, //Shrink the amount of space u can hit with your finger on the button
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

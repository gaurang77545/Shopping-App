import 'dart:convert';
import 'dart:async'; //For timer
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Auth with ChangeNotifier {
  //For Sending request to the server
  String
      _token; //token is attached to requests which need authentication to validate request to server
  DateTime _expiryDate; //of token
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;//If token is not null return True
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    //In the url only one thing is changing so we represent that using urlSegment
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA8sRGIIT2j-HQfh9oLQt-JbZWiPW2uv1g');
    //We goto firebase Auth Rest API and copy the url.In place of [API_key] you gotta paste the value in
    //Goto firebase->Project Overview->Project Settings->Web API key .Copy paste the value
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      //debugPrint(response.body);//So that output is formatted
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        return Future.error(HttpException(responseData['error']['message']));
        //Our reponse is basically a map of values if we access ['message'] we get to know type of error
      }
      _token = responseData[
          'idToken']; //If there is no error thrown we extract the value from responseData
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        //To gte the date we add the current time to the expiry time in seconds
        Duration(
          seconds: int.parse(
            //Converts string to integer coz string is returned in ['expiesIn']
            responseData[
                'expiresIn'], //This tells us how many seconds is left for it to expire
          ),
        ),
      );
      _autoLogout();//Start the timer once we login
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();//We use Shared pereferences here so that we can store stuff in our secondary memory for longer time compared to our main meory which gets lost instantly
      //We store our login info for auto logging in
      //Working with shared Preferences involve working with Futures so u gotta use async here
      //returns a future which we can use for storing
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);//We can store Strings for storing stuff
      //We use json.encode to convert to string and we then store that.Storing is done in form of key-value pair
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password,
        'signUp'); //We gotta return the future value else this thing ain't gonna work
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

    Future<bool> tryAutoLogin() async {
      //<bool> tells us whether we were succesful or not in our auto login
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {//We extract data based on the key
      return false;//coz Future<bool>
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    //Converted string to map
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();//We set the timer for autoLogout
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();//I wanna cancel the timer since i have logged out
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');//To clear a specific key
    prefs.clear();//To clear everything
    //If we don't clear everything autoLogin will happen again when app rebuilds
  }

  void _autoLogout() {
    //To auto logout once the token expires
    if (_authTimer != null) {
      _authTimer
          .cancel(); //If i have an existing timer running i wanna cancek it before i start a new one
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    //We calculate the no. of seconds we have left ie b/w now and the epiry Date
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    //Enables a timer which takes its duration and function to be invoked once the timer expires
  }
}

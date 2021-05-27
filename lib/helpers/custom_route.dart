import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  //basically whenever we change our screen the new screen comes from the bottom instead of that we can define our own transition as well if we want
  CustomRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
          //We are passing our builder and settinngs variables to the parent class
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double>
        animation, //This is the animation which flutter handles.It gives u a double which changes overtime
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == '/') {
      //Basically if we are on the first screen we don't wanna animate and instead of that keep the default stuff hence we return child
      return child;
    }
    return FadeTransition(//We are doing Fade Transition in other cases
      opacity: animation,//animation variables is returning a double and opacity also requires a double hence we pass that to it
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  //we use builder so that we can set this transition as the default transition in main.dart file coz it requires a Builder for Transitions
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') {
     
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

import 'package:flutter/widgets.dart';

/* One RouteObserver shared by the whole app. A screen that must reload when
it becomes visible again (the dashboard, which now sits underneath the other
screens) subscribes to it as a RouteAware. Registered in
MaterialApp.navigatorObservers (main.dart). */
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
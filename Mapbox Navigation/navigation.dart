import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:muftar/view/home/home.dart';

class TurnByTurn extends StatefulWidget {
  const TurnByTurn({Key? key}) : super(key: key);

  @override
  State<TurnByTurn> createState() => _TurnByTurnState();
}

class _TurnByTurnState extends State<TurnByTurn> {
  @override
  void initState() {
    super.initState();
    initializeNavigation();
  }

  @override
  Widget build(BuildContext context) {
    // The page You wanna show when the Navigation Screen Close
    return const HomePage();
  }

  // Config variables for Mapbox Navigation
  late MapBoxNavigation _directions;
  late MapBoxOptions _options;
  dynamic distanceRemaining, durationRemaining;
  MapBoxNavigationViewController? _controller;
  final bool isMultipleStop = false;
  String instruction = "";
  bool arrived = false;
  bool routeBuilt = false;
  bool isNavigating = false;
  late WayPoint sourceWaypoint, destinationWaypoint;
  List<WayPoint> wayPoints = <WayPoint>[];

  Future<void> initializeNavigation() async {
    // Setup directions and options
    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);

    // define Option for your Navigation Screen
    _options = MapBoxOptions(
        enableFreeDriveMode: true,
        // voiceInstructions
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.metric,
        // make sure to marked the simulated route as false
        simulateRoute: false,
        //screen language
        language: "en");

    // Configure waypoints
    sourceWaypoint = WayPoint(
        name: "Source",
        latitude: 24.91307271343316,
        longitude: 67.1029355662984);

    destinationWaypoint = WayPoint(
        name: "Destination",
        latitude: 24.915024253867443,
        longitude: 67.09297922739427);

    wayPoints.add(sourceWaypoint);
    wayPoints.add(destinationWaypoint);

    // Start the trip
    await _directions.startNavigation(wayPoints: wayPoints, options: _options);
  }

  Future<void> _onRouteEvent(e) async {
    distanceRemaining = await _directions.distanceRemaining;
    durationRemaining = await _directions.durationRemaining;
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        arrived = progressEvent.arrived!;
        if (progressEvent.currentStepInstruction != null) {
          instruction = progressEvent.currentStepInstruction!;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        arrived = true;
        // ridecomplete(arrived);

        if (!isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller?.finishNavigation();
          // Get.offAll(() => const CurrentLoad());
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        routeBuilt = false;
        isNavigating = false;

        break;
      default:
        break;
    }
    //refresh UI

    if (mounted) setState(() {});
  }
}

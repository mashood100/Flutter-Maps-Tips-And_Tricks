import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
//you must be wondering why I am importing the location package with named
//as locationpackage?.
//I am doing this because I don't want to mistakenly USE another package class
//or functions that is named the same as the one location package is using :).
import 'package:location/location.dart' as locationpackage;

class LiveTrackingService extends GetxService {
  @override
  void onInit() {
    super.onInit();

    // setting up settings for location updates
    location.changeSettings(
        // time interval between location updates
        interval: 5000,
        accuracy: locationpackage.LocationAccuracy.high);
    //enable background mode true
    //so our app will continue running even if the user is not using the app
    location.enableBackgroundMode(enable: true);
  }

  // create the instance of the location service
  final locationpackage.Location location = locationpackage.Location();
  // create a stream controller to handle the location updates
  // as we know when we want continuous updates we use stream controller
  StreamSubscription<locationpackage.LocationData>? _locationSubscription;

  /// let make the  asynchronous function
  /// to be called and handel changes when the location is changed

  Future<void> sentLiveLocation() async {
    // handle some unexpected errors :)
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      // log the error to the terminal
      inspect(onError);
      // cancel the subscription if unfortunately an error occured :(
      _locationSubscription?.cancel();
      _locationSubscription = null;
    })
        // if everything goes rigth we continue the our every listening about chanage
        //in coordinates
        .listen((locationpackage.LocationData currentlocation) async {
      //another inspect to see the current location changes time interval
      inspect('location changed ${DateTime.now()}');
      //now finally we can update the location coordinates in our
      //firestroe database ;)
      await FirebaseFirestore.instance
          // provide the collction name and the document name
          //as you discribe this in your firestore database
          .collection('users')
          .doc('location')
          // let .set() method help you to update
          //the location coordinates smoothly
          .set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
      }, SetOptions(merge: true));
    });
  }

// as we know the location service is running in background
// and it a pretty intensive task to run in background
//so it's  a good idea to stop it when we no longer need it
  stopLiveLocation() {
    inspect("location service stopped");
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}

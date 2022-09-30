
Future<void> main() async {
// make sure to place widgetflutterBindings fun
// on the top of the main function
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initServices();
  runApp(const MyApp());
}

//use this to make sure that the tracking service
// will be running till the app is not closed
Future<void> initServices() async {
  await Get.putAsync<LiveTrackingService>(() async => LiveTrackingService());
}

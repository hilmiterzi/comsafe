import 'package:google_api_availability/google_api_availability.dart';

class GooglePlayServicesChecker {
  Future<bool> checkGooglePlayServices() async {
    GooglePlayServicesAvailability availability;
    try {
      availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
      
      switch (availability) {
        case GooglePlayServicesAvailability.success:
          return true;
        case GooglePlayServicesAvailability.serviceMissing:
        case GooglePlayServicesAvailability.serviceUpdating:
        case GooglePlayServicesAvailability.serviceVersionUpdateRequired:
        case GooglePlayServicesAvailability.serviceDisabled:
        case GooglePlayServicesAvailability.serviceMissing:
          await GoogleApiAvailability.instance.makeGooglePlayServicesAvailable();
          return false;
        default:
          return false;
      }
    } catch (error) {
      print('Error checking Google Play Services: $error');
      return false;
    }
  }
} 
import 'package:gtd/core/repositories/local/local_state_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository.dart';

class LocalRepository extends Repository {

  LocalRepository._privateConstructor();

  static final LocalRepository _instance =
      LocalRepository._privateConstructor();

  static LocalRepository get instance => _instance;

  Future<void> setGTDLevel(GTDLevel level) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gtdLevel', level.toString());
  }

    Future<String> getGTDLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('gtdLevel');
  }

  Future<void> setNotificationsAllowed(bool areAllowed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reviewNotifications', areAllowed);    
  }

  Future<bool> getNotificationsAllowed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reviewNotifications');   
  }

  Future<void> completeOnboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingCompleted', true);
  }

  Future<bool> isOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;
    return isOnboardingCompleted;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isOnboardingCompleted');
    await prefs.remove('gtdLevel');
    await prefs.remove('reviewNotifications');
    await prefs.clear();
  }
}

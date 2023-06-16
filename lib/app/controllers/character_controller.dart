import 'package:flutter/cupertino.dart';
import '../services/api_service.dart';
import '../models/deshbord_model.dart';

// class DashBoardProvider extends ChangeNotifier {
//   bool isLoading = false;
//   List<DashboardApiModel> characters = [];
//   DashBoardProvider() {
//     getDashUserListApi;
//   }

//   Future<void> getDashUserListApi() async {
//     isLoading = true;
//     notifyListeners();
//     characters = await BaseApi.getDashUserListApi();
//     isLoading = false;
//     notifyListeners();
//   }
// }

class CharacterController extends ChangeNotifier {
  bool isLoading = false;
  List<DashboardApiModel> characters = [];
  CharacterController() {
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    isLoading = true;
    notifyListeners();
    characters = await RemoteServices.fetchCharacters();
    isLoading = false;
    notifyListeners();
  }
}

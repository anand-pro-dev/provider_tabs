import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart ' as http;
import '../models/deshbord_model.dart';

class RemoteServices {
  static Future<List<DashboardApiModel>> fetchCharacters() async {
    List<DashboardApiModel> userList = [];
    final respone =
        //  await http.get(Uri.parse("http://139.59.34.177:3010/api/callers/64226d567e1ea2ae46619d9c/studentTasks?filter={"where":{"stageId":"642fc399de00262d31503dee"},"include":["students","tasks"]}"));
        await http.get(Uri.parse(
            'http://139.59.34.177:3010/api/callers/64226d567e1ea2ae46619d9c/studentTasks?filter={"where":{"status":"assigned"},"include":["students","tasks"]}'));
    var data = jsonDecode(respone.body);
    log(data.toString());
    if (respone.statusCode == 200) {
      for (Map<String, dynamic> i in data) {
        // print(respone.body);

        log(i.toString());
        // print(data['name']);
        userList.add(DashboardApiModel.fromJson(i));
      }
      return userList;
    } else {
      log("Oops Unable to load dash");
      return userList;
    }
  }
}

// class RemoteServices {
//   static var dio = Dio();

//   static Future<List<DashboardApiModel>> fetchCharacters() async {
//     log('ok c');
//     var response = await dio.get(baseUrl);
//     if (response.statusCode == 200) {
//       final List<dynamic> data = response.data;
//       // log(data.toString());
//       return data.map((item) => DashboardApiModel.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load characters');
//     }
//   }
// }


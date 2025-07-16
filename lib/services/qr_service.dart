import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/recipe.dart';

final _baseUrl = dotenv.env['API_URL'];

class QrService {
  final _secureStorage = const FlutterSecureStorage();
  final _prefs = SharedPreferences.getInstance();

  /*Future<Recipe> getRecipeByQrCode(String? qrCode) async{

    Recipe recipe = Recipe;
    return recipe;
  }*/

}


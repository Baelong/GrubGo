import 'dart:convert';
import 'package:http/http.dart' as http;

class HereApiService {
  static const String _apiKey = 'H72d7X1NdgRM1IekF4IDtrD3FTZqmhzgY8f5cckVvmA';

  static Future<List<dynamic>> searchPlaces(String query) async {
    final url =
        'https://autocomplete.search.hereapi.com/v1/autocomplete?q=$query&apiKey=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  static Future<String> getPlaceDetails(String placeId) async {
    final url =
        'https://lookup.search.hereapi.com/v1/lookup?id=$placeId&apiKey=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['title'];
    } else {
      throw Exception('Failed to load place details');
    }
  }
}

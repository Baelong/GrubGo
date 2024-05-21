import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class AddressSearch extends SearchDelegate<Prediction?> {
  final GoogleMapsPlaces places;

  AddressSearch(this.places);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Prediction>>(
      future: _getPredictions(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found'));
        }
        final predictions = snapshot.data!;
        return ListView.builder(
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return ListTile(
              title: Text(prediction.description ?? ''),
              onTap: () => close(context, prediction),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  Future<List<Prediction>> _getPredictions(String input) async {
    if (input.isEmpty) return [];

    try {
      final response = await places.autocomplete(
        input,
        language: "en",
        components: [Component(Component.country, "us"), Component(Component.country, "ca")],
      );

      print('Response status: ${response.status}');
      print('Response error message: ${response.errorMessage}');
      print('Response predictions: ${response.predictions}');

      if (response.isOkay) {
        return response.predictions ?? [];
      } else {
        print('Autocomplete failed with status: ${response.status}');
        print('Error message: ${response.errorMessage}');
        return [];
      }
    } catch (e) {
      print('Exception during autocomplete request: $e');
      return [];
    }
  }
}

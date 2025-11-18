import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:http/http.dart' as http;

class CarouselSliderService {
  // Replace with your actual server URL

  // Method to fetch image URLs from the API and return them
  Future<List<String>> fetchImages() async {
    final url = Uri.parse(
        '$serverUrl/admin/categoryAdvertisement/getAll'); // Replace with your API endpoint
    print("carouselPicture ${url}");

    try {
      final response = await http.get(url);
      print("carouselPicture ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("carouselPicture ${response.statusCode}");
        print("carouselPicture body ${response}");
        print("carouselPicture data ${data}");

        // Assuming the API returns an array of objects, each containing 'carouselPicture'
        List<String> imageUrls = [];

        // Loop through the response data to extract 'carouselPicture' from each object
        for (var item in data) {
          if (item.containsKey('mediaUrlOrImage')) {
            imageUrls.add(item['mediaUrlOrImage']);
          }
        }

        return imageUrls;
      } else {
        print("carouselPicture ${response.statusCode}");
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print("Error fetching images: $e");
      return []; // Return an empty list if an error occurs
    }
  }

  Future<List<String>> fetchServiceImages() async {
    final url = Uri.parse(
        '$serverUrl/admin/ServiceAdvertisement/getAll'); // Replace with your API endpoint
    try {
      final response = await http.get(url);
      print("carouselPicture ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("carouselPicture ${response.statusCode}");
        print("carouselPicture body ${response}");
        print("carouselPictures data ${data}");

        // Assuming the API returns an array of objects, each containing 'carouselPicture'
        List<String> imageUrls = [];

        // Loop through the response data to extract 'carouselPicture' from each object
        for (var item in data) {
          if (item.containsKey('mediaUrlOrImage')) {
            imageUrls.add(item['mediaUrlOrImage']);
          }
        }
        print("imageUrlsimageUrls lengrt ${imageUrls.length}");
        return imageUrls;
      } else {
        print("carouselPicture ${response.statusCode}");
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print("Error fetching images: $e");
      return []; // Return an empty list if an error occurs
    }
  }
}

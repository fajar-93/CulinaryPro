import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Fetch recipes by search query. If query is empty, fetches some default recipes.
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final endpoint = query.isEmpty 
          ? '$_baseUrl/search.php?s=' // Empty string returns a default list
          : '$_baseUrl/search.php?s=$query';
          
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];

        if (meals == null) {
          return []; // No recipes found
        }

        return meals.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recipes. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  /// Fetch a single recipe by its ID
  Future<Recipe> getRecipeDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];

        if (meals == null || meals.isEmpty) {
          throw Exception('Recipe not found');
        }

        return Recipe.fromJson(meals.first);
      } else {
        throw Exception('Failed to load recipe details');
      }
    } catch (e) {
      throw Exception('Error fetching recipe details: $e');
    }
  }
}

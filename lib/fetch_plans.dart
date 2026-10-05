import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://dev.gobuddyindia.com/api/get_plans');
  final response = await http.get(url);
  print(response.body);
}

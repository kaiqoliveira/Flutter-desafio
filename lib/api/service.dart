import 'package:http/http.dart' as http;
import 'dart:convert';

class GithubService {
  //Retorna lista de usuários encontrados
  Future<List<Map<String, dynamic>>> searchUsers(String username) async {
    String query = 'https://api.github.com/search/users?q=$username+in:login';

    final response = await http.get(Uri.parse(query));

    //Verifica se a requisição foi bem-sucedida (código de status HTTP 200).
    //Caso contrário, lança uma exceção informando que falhou ao carregar os usuários.
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //Se a requisição foi bem-sucedida converte a lista de usuários encontrados em
      //uma lista de mapas dinâmicos
      return List<Map<String, dynamic>>.from(data['items']).take(5).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}

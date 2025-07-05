import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bible_verse.dart';

class BibliaService {
  Future<List<BibleVerse>?> buscarCapitulo({
    required String nomeLivro,
    required int capitulo,
  }) async {
    final String referencia = '$nomeLivro $capitulo';
    final String url = 'https://bible-api.com/${Uri.encodeComponent(referencia)}?translation=almeida';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Verificar se há versículos na resposta
      if (data['verses'] != null && data['verses'] is List) {
        return (data['verses'] as List).map((verse) => BibleVerse(
          reference: '${data['reference']}:${verse['verse']}',
          text: verse['text'],
          translation: data['translation_name'],
        )).toList();
      }
      
      return null;
    } else {
      print('Erro ao buscar capítulo: ${response.statusCode}');
      return null;
    }
  }
}

// ================== BÍBLIA ================== //

class LivroBiblico {
  String? id;
  String? nome;
  String? testamento;
  int? capitulos;

  LivroBiblico({this.id, this.nome, this.testamento, this.capitulos});
}

class BibleVerse {
  String? referencia;
  String? texto;
  String? traducao;

  BibleVerse({this.referencia, this.texto, this.traducao});

  factory BibleVerse.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> verse,
  ) {
    return BibleVerse(
      referencia: '${json['reference']}:${verse['verse']}',
      texto: verse['text'],
      traducao: json['translation_name'],
    );
  }
}

// ================== ORAÇÕES ================== //

class PedidoOracao {
  String? texto;
  bool? respondido;
  DateTime? criadoEm;

  PedidoOracao({this.texto, this.respondido, this.criadoEm});
}

// ================== DEVOCIONAIS ================== //

class Devocional {
  String? titulo;
  String? conteudo;
  DateTime? criadoEm;

  Devocional({this.titulo, this.conteudo, this.criadoEm});
}

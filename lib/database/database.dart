import '../models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================== ORAÇÕES ================== //

class DatabaseOracao {
  FirebaseFirestore db = FirebaseFirestore.instance;

  inicializar() {
    db = FirebaseFirestore.instance;
  }

  incluir(PedidoOracao p) {
    final pedido = <String, dynamic>{
      'texto': p.texto,
      'respondido': p.respondido ?? false,
      'criadoEm': Timestamp.fromDate(DateTime.now()),
    };
    db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('pedidosDeOracao')
        .add(pedido);
  }

  Future<void> editar(String id, PedidoOracao p) async {
    final pedido = <String, dynamic>{
      'texto': p.texto,
      'respondido': p.respondido,
    };
    await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('pedidosDeOracao')
        .doc(id)
        .update(pedido);
  }

  Future<void> excluir(String id) async {
    await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('pedidosDeOracao')
        .doc(id)
        .delete();
  }

  Future<List> listar() async {
    // querySnapshot é o resultado da consulta ao Firestore
    QuerySnapshot querySnapshot;
    List docs = [];

    querySnapshot = await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('pedidosDeOracao')
        .orderBy('criadoEm', descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          'id': doc.id,
          'texto': doc['texto'],
          'respondido': doc['respondido'],
          'criadoEm': doc['criadoEm'],
        };
        docs.add(a);
      }
    }
    return docs;
  }

  Future<void> marcarRespondido(String id, bool respondido) async {
    await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('pedidosDeOracao')
        .doc(id)
        .update({'respondido': respondido});
  }
}

// ================== DEVOCIONAIS ================== //

class DatabaseDevocional {
  FirebaseFirestore db = FirebaseFirestore.instance;

  inicializar() {
    db = FirebaseFirestore.instance;
  }

  incluir(Devocional d) {
    final devocional = <String, dynamic>{
      'titulo': d.titulo,
      'conteudo': d.conteudo,
      'criadoEm': Timestamp.fromDate(DateTime.now()),
    };
    db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('devocionais')
        .add(devocional);
  }

  Future<void> editar(String id, Devocional d) async {
    final devocional = <String, dynamic>{
      'titulo': d.titulo,
      'conteudo': d.conteudo,
    };
    await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('devocionais')
        .doc(id)
        .update(devocional);
  }

  Future<void> excluir(String id) async {
    await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('devocionais')
        .doc(id)
        .delete();
  }

  Future<List> listar() async {
    QuerySnapshot querySnapshot;
    List docs = [];

    querySnapshot = await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('devocionais')
        .orderBy('criadoEm', descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          'id': doc.id,
          'titulo': doc['titulo'],
          'conteudo': doc['conteudo'],
          'criadoEm': doc['criadoEm'],
        };
        docs.add(a);
      }
    }
    return docs;
  }
}

// ================== PROGRESSO DE LEITURA ================== //

class DatabaseProgresso {
  FirebaseFirestore db = FirebaseFirestore.instance;

  inicializar() {
    db = FirebaseFirestore.instance;
  }

  incluir(Map<String, dynamic> progresso) {
    final progressoData = <String, dynamic>{
      'identificador': progresso['identificador'],
      'livroId': progresso['livroId'],
      'capitulo': progresso['capitulo'],
      'lido': progresso['lido'],
      'dataLeitura': FieldValue.serverTimestamp(),
    };
    db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('progressoLeitura')
        .doc(progresso['identificador'])
        .set(progressoData);
  }

  Future<void> editar(String id, Map<String, dynamic> progresso) async {
    await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('progressoLeitura')
        .doc(id)
        .update(progresso);
  }

  Future<void> excluir(String id) async {
    await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('progressoLeitura')
        .doc(id)
        .delete();
  }

  Future<List> listar() async {
    QuerySnapshot querySnapshot;
    List docs = [];

    querySnapshot = await db
        .collection('dadosDoUsuario')
        .doc('meusDados')
        .collection('progressoLeitura')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          'id': doc.id,
          'identificador': doc['identificador'],
          'livroId': doc['livroId'],
          'capitulo': doc['capitulo'],
          'lido': doc['lido'],
          'dataLeitura': doc['dataLeitura'],
        };
        docs.add(a);
      }
    }
    return docs;
  }
}

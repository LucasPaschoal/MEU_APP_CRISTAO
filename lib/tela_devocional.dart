import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'models/models.dart';
import 'database/database.dart';

class DevocionaisTela extends StatefulWidget {
  const DevocionaisTela({super.key});

  @override
  State<DevocionaisTela> createState() => _DevocionaisTelaState();
}

class _DevocionaisTelaState extends State<DevocionaisTela> {
  late DatabaseDevocional db;
  List docs = [];
  bool _isLoading = true;

  atualizarLista() {
    db = DatabaseDevocional();
    db.inicializar();
    db.listar().then(
      (value) => {
        setState(() {
          docs = value;
          _isLoading = false;
        }),
      },
    );
  }

  @override
  void initState() {
    super.initState();
    atualizarLista();
  }

  Future<void> _adicionarOuAtualizarDevocional([
    Map? devocionaisSelecionado,
  ]) async {
    TextEditingController tituloCtrl = TextEditingController(
      text: devocionaisSelecionado != null
          ? devocionaisSelecionado['titulo'] ?? ''
          : '',
    );
    TextEditingController conteudoCtrl = TextEditingController(
      text: devocionaisSelecionado != null
          ? devocionaisSelecionado['conteudo'] ?? ''
          : '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            devocionaisSelecionado == null
                ? 'Novo Devocional'
                : 'Editar Devocional',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Título do Devocional',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: conteudoCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Seu devocional aqui...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  maxLines: 5,
                  minLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tituloCtrl.text.trim().isNotEmpty &&
                    conteudoCtrl.text.trim().isNotEmpty) {
                  if (devocionaisSelecionado == null) {
                    Devocional d = Devocional(
                      titulo: tituloCtrl.text.trim(),
                      conteudo: conteudoCtrl.text.trim(),
                    );
                    db.incluir(d);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Devocional adicionado com sucesso!'),
                        duration: Duration(milliseconds: 300),
                      ),
                    );
                  } else {
                    Devocional d = Devocional(
                      titulo: tituloCtrl.text.trim(),
                      conteudo: conteudoCtrl.text.trim(),
                    );
                    db.editar(devocionaisSelecionado['id'], d);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Devocional atualizado com sucesso!'),
                        duration: Duration(milliseconds: 300),
                      ),
                    );
                  }
                  Navigator.pop(context);
                  // Pequeno delay para permitir que o servidor processe o timestamp
                  await Future.delayed(const Duration(milliseconds: 100));
                  atualizarLista();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Título e conteúdo não podem ser vazios.'),
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarExclusao(String docId) async {
    bool confirmar =
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text(
                'Tem certeza que deseja excluir este devocional?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Excluir',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmar) {
      db.excluir(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devocional excluído com sucesso!'),
          duration: Duration(milliseconds: 100),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      atualizarLista();
    }
  }

  Future<void> _excluirTodos() async {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há devocionais para excluir.')),
      );
      return;
    }

    bool confirmar =
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Excluir Todos'),
              content: Text(
                docs.length == 1
                    ? 'Tem certeza que deseja excluir o devocional?'
                    : 'Tem certeza que deseja excluir todos os ${docs.length} devocionais?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Excluir Todos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmar) {
      // Excluir todos os devocionais
      for (var doc in docs) {
        db.excluir(doc['id']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            docs.length == 1
                ? 'O devocional foi excluído!'
                : 'Todos os devocionais foram excluídos!',
          ),
          duration: const Duration(milliseconds: 500),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      atualizarLista();
    }
  }

  Future<void> _mostrarConteudoCompleto(String titulo, String conteudo) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                conteudo,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Chama a função de editar
                Map<String, dynamic> devocional = {
                  "id": docs.firstWhere(
                    (doc) =>
                        doc['titulo'] == titulo && doc['conteudo'] == conteudo,
                  )['id'],
                  "titulo": titulo,
                  "conteudo": conteudo,
                  "criadoEm": docs.firstWhere(
                    (doc) =>
                        doc['titulo'] == titulo && doc['conteudo'] == conteudo,
                  )['criadoEm'],
                };
                _adicionarOuAtualizarDevocional(devocional);
              },
              child: const Text('Editar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devocionais'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'excluir_todos') {
                _excluirTodos();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'excluir_todos',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir Todos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: docs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum devocional ainda. Clique no botão "+" para adicionar um novo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                String titulo = docs[index]['titulo'] ?? 'Sem Título';
                String conteudo = docs[index]['conteudo'] ?? 'Sem conteúdo';

                return Card(
                  child: ListTile(
                    title: Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          conteudo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Indicador para conteúdos longos
                        if (conteudo.length > 150)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              'Toque para ver completo',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.indigo.shade200,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'Criado em: ${docs[index]['criadoEm'] != null ? DateFormat('dd/MM/yyyy').format((docs[index]['criadoEm'] as Timestamp).toDate()) : 'N/A'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.indigo.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Map<String, dynamic> devocional = {
                          "id": docs[index]['id'],
                          "titulo": docs[index]['titulo'],
                          "conteudo": docs[index]['conteudo'],
                          "criadoEm": docs[index]['criadoEm'],
                        };
                        _adicionarOuAtualizarDevocional(devocional);
                      },
                    ),
                    onTap: () {
                      // só mostra o conteúdo completo se for texto longo
                      if (conteudo.length > 150) {
                        _mostrarConteudoCompleto(titulo, conteudo);
                      } else {
                        // se for texto curto, vai direto para edição
                        Map<String, dynamic> devocional = {
                          "id": docs[index]['id'],
                          "titulo": docs[index]['titulo'],
                          "conteudo": docs[index]['conteudo'],
                          "criadoEm": docs[index]['criadoEm'],
                        };
                        _adicionarOuAtualizarDevocional(devocional);
                      }
                    },
                    onLongPress: () => _confirmarExclusao(docs[index]['id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarOuAtualizarDevocional(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

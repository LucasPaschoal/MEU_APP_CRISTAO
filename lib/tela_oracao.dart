import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'models/pedido_oracao.dart';
import 'database.dart';

class PedidosOracaoTela extends StatefulWidget {
  const PedidosOracaoTela({super.key});

  @override
  State<PedidosOracaoTela> createState() => _PedidosOracaoTelaState();
}

class _PedidosOracaoTelaState extends State<PedidosOracaoTela> {
  late DatabaseOracao db;
  List docs = [];
  bool _isLoading = true;

  atualizarLista() {
    db = DatabaseOracao();
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

  Future<void> _adicionarOuAtualizarPedido([Map? pedidoSelecionado]) async {
    TextEditingController controller = TextEditingController(
      text: pedidoSelecionado != null ? pedidoSelecionado['texto'] ?? '' : '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            pedidoSelecionado == null
                ? 'Novo Pedido de Oração'
                : 'Editar Pedido de Oração',
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Digite seu pedido aqui...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            maxLines: 3,
            minLines: 1,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  if (pedidoSelecionado == null) {
                    PedidoOracao p = PedidoOracao(
                      texto: controller.text.trim(),
                      respondido: false,
                    );
                    db.incluir(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedido adicionado com sucesso!'),
                        duration: Duration(milliseconds: 300),
                      ),
                    );
                  } else {
                    PedidoOracao p = PedidoOracao(
                      texto: controller.text.trim(),
                      respondido: pedidoSelecionado['respondido'],
                    );
                    db.editar(pedidoSelecionado['id'], p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedido atualizado com sucesso!'),
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
                      content: Text('O pedido não pode ser vazio.'),
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
                'Tem certeza que deseja excluir este pedido de oração?',
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
          content: Text('Pedido excluído com sucesso!'),
          duration: Duration(milliseconds: 300),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      atualizarLista();
    }
  }

  void _marcarRespondido(String docId, bool respondido) async {
    db.marcarRespondido(docId, respondido);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pedido marcado como ${respondido ? 'respondido' : 'não respondido'}.',
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));
    atualizarLista();
  }

  Future<void> _excluirTodos() async {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há pedidos para excluir.'),
        ),
      );
      return;
    }

    bool confirmar = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Excluir Todos'),
              content: Text(
                docs.length == 1
                    ? 'Tem certeza que deseja excluir o pedido de oração?'
                    : 'Tem certeza que deseja excluir todos os ${docs.length} pedidos de oração?',
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
      // Excluir todos os pedidos
      for (var doc in docs) {
        db.excluir(doc['id']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            docs.length == 1
                ? 'O pedido foi excluído!'
                : 'Todos os pedidos foram excluídos!',
          ),
          duration: const Duration(milliseconds: 500),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 200));
      atualizarLista();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos de Oração'),
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
                  'Nenhum pedido de oração ainda. Clique no botão "+" para adicionar um novo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                bool respondido = docs[index]['respondido'] ?? false;

                return Card(
                  child: ListTile(
                    title: Text(
                      docs[index]['texto'] ?? 'Sem texto',
                      style: TextStyle(
                        decoration: respondido
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: respondido ? Colors.grey : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
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
                    trailing: Checkbox(
                      value: respondido,
                      onChanged: (bool? novoValor) {
                        _marcarRespondido(docs[index]['id'], novoValor!);
                      },
                    ),
                    onTap: () {
                      Map<String, dynamic> pedido() => {
                        "id": docs[index]['id'],
                        "texto": docs[index]['texto'],
                        "respondido": docs[index]['respondido'],
                        "criadoEm": docs[index]['criadoEm'],
                      };
                      _adicionarOuAtualizarPedido(pedido());
                    },
                    onLongPress: () => _confirmarExclusao(docs[index]['id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarOuAtualizarPedido(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

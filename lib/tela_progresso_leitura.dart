import 'package:flutter/material.dart';
import 'models/models.dart';
import 'services/biblia_service.dart';
import 'models/livros_biblia.dart';
import 'database/database.dart';

// é um Stateful porque o estado do progresso e filtros mudam.
class LeituraBiblicaTela extends StatefulWidget {
  const LeituraBiblicaTela({super.key});

  @override
  State<LeituraBiblicaTela> createState() => _LeituraBiblicaTelaState();
}

  class _LeituraBiblicaTelaState extends State<LeituraBiblicaTela>
      with TickerProviderStateMixin {
    late DatabaseProgresso db;
    late TabController _tabCtrl;
    Map<String, bool> _progressoLocal = {};
    bool _isLoading = true;
    String _filtroTexto = '';
    final TextEditingController _searchCtrl = TextEditingController();
    final BibliaService _bibliaService = BibliaService();

    @override
    void initState() {
      super.initState();
      _tabCtrl = TabController(length: 2, vsync: this);
      _carregarProgresso();
    }

    @override
    void dispose() {
      _tabCtrl.dispose();
      _searchCtrl.dispose();
      super.dispose();
    }

  _carregarProgresso() {
    db = DatabaseProgresso();
    db.inicializar();
    db.listar().then(
      (value) => {
        setState(() {
          _progressoLocal = {};
          for (var doc in value) {
            _progressoLocal[doc['identificador']] = doc['lido'] ?? false;
          }
          _isLoading = false;
        }),
      },
    );
  }

  Future<void> _atualizarProgresso(
    String livroId,
    int capitulo,
    bool lido,
  ) async {
    final identificador = '${livroId}_$capitulo';

    try {
      if (lido) {
        final progressoData = {
          'identificador': identificador,
          'livroId': livroId,
          'capitulo': capitulo,
          'lido': true,
        };
        db.incluir(progressoData);
      } else {
        db.excluir(identificador);
      }

      setState(() {
        _progressoLocal[identificador] = lido;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lido ? 'Capítulo marcado como lido!' : 'Capítulo desmarcado.',
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar progresso: $e')),
        );
      }
    }
  }

  Future<void> _marcarLivroCompleto(LivroBiblico livro, bool lido) async {
    try {
      for (int i = 1; i <= livro.capitulos!; i++) {
        final identificador = '${livro.id}_$i';

        if (lido) {
          final progressoData = {
            'identificador': identificador,
            'livroId': livro.id,
            'capitulo': i,
            'lido': true,
          };
          db.incluir(progressoData);
        } else {
          db.excluir(identificador);
        }
      }

      // atualiza o estado local
      setState(() {
        for (int i = 1; i <= livro.capitulos!; i++) {
          final identificador = '${livro.id}_$i';
          _progressoLocal[identificador] = lido;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lido
                  ? '${livro.nome} marcado como lido!'
                  : '${livro.nome} desmarcado.',
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar livro: $e')));
      }
    }
  }

  // cálculo de estatísticas e progresso
  Map<String, dynamic> _calcularEstatisticas(List<LivroBiblico> livros) {
    int totalCapitulos = livros.fold(0, (sum, livro) => sum + livro.capitulos!);
    int capitulosLidos = 0;

    for (var livro in livros) {
      for (int i = 1; i <= livro.capitulos!; i++) {
        if (_progressoLocal['${livro.id}_$i'] == true) {
          capitulosLidos++;
        }
      }
    }

    return {
      'total': totalCapitulos,
      'lidos': capitulosLidos,
      'porcentagem': totalCapitulos > 0 ? capitulosLidos / totalCapitulos : 0.0,
    };
  }

  // filtro de livro por nome
  List<LivroBiblico> _filtrarLivros(List<LivroBiblico> livros) {
    if (_filtroTexto.isEmpty) return livros;

    return livros
        .where(
          (livro) =>
              livro.nome!.toLowerCase().contains(_filtroTexto.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando progresso...'),
            ],
          ),
        ),
      );
    }

    final livrosAt = _filtrarLivros(
      BibliaDados.livrosBiblicos
          .where((l) => l.testamento == 'Antigo')
          .toList(),
    );
    final livrosNt = _filtrarLivros(
      BibliaDados.livrosBiblicos.where((l) => l.testamento == 'Novo').toList(),
    );

    final estatisticasGeral = _calcularEstatisticas(BibliaDados.livrosBiblicos);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitura Bíblica'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Antigo testamento'),
            Tab(icon: Icon(Icons.auto_stories), text: 'Novo testamento'),
          ],
        ),
      ),
      body: Column(
        children: [
          // cabeçalho com progresso geral e busca
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // campo de busca
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar livro...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filtroTexto.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filtroTexto = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _filtroTexto = value),
                ),

                const SizedBox(height: 16),

                // estatísticas gerais
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.indigo),
                          const SizedBox(width: 8),
                          const Text(
                            'Progresso Geral',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(estatisticasGeral['porcentagem'] * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: estatisticasGeral['porcentagem'],
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.indigo,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${estatisticasGeral['lidos']} capítulos lidos',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.book_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${estatisticasGeral['total']} total',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildListaLivros(livrosAt, 'Antigo testamento'),
                _buildListaLivros(livrosNt, 'Novo testamento'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaLivros(List<LivroBiblico> livros, String testamento) {
    if (livros.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum livro encontrado',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // calcula estatísticas do testamento
    final estatisticas = _calcularEstatisticas(livros);

    return Column(
      children: [
        // cabeçalho do testamento
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Icon(
                testamento == 'Antigo testamento'
                    ? Icons.book
                    : Icons.auto_stories,
                color: Colors.indigo,
              ),
              const SizedBox(width: 8),
              Text(
                testamento,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '${(estatisticas['porcentagem'] * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        ),

        // lista de livros
        Expanded(
          child: ListView.builder(
            itemCount: livros.length,
            itemBuilder: (context, index) {
              final livro = livros[index];
              final capitulosLidos =
                  List.generate(livro.capitulos!, (i) => i + 1)
                      .where(
                        (cap) => _progressoLocal['${livro.id}_$cap'] == true,
                      )
                      .length;
              final progressoLivro = livro.capitulos! > 0
                  ? capitulosLidos / livro.capitulos!
                  : 0.0;
              final livroCompleto = progressoLivro == 1.0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: 2,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: livroCompleto
                        ? Colors.green
                        : Colors.indigo,
                    child: livroCompleto
                        ? const Icon(Icons.check, color: Colors.white)
                        : Text(
                            '${(progressoLivro * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  title: Text(
                    livro.nome!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: livroCompleto
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progressoLivro,
                        backgroundColor: Colors.grey.shade300,
                        color: livroCompleto ? Colors.green : Colors.indigo,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('$capitulosLidos/${livro.capitulos} capítulos'),
                          const Spacer(),
                          if (livroCompleto)
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'marcar_tudo') {
                        _marcarLivroCompleto(livro, true);
                      } else if (value == 'desmarcar_tudo') {
                        _marcarLivroCompleto(livro, false);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'marcar_tudo',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Marcar livro completo'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'desmarcar_tudo',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Desmarcar livro'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capítulos (${livro.capitulos} total)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Toque para ver versículos • Mantenha pressionado para marcar/desmarcar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            // list.generate se aplica para criar os botões de capítulos
                            children: List.generate(livro.capitulos!, (index) {
                              final capitulo = index + 1;
                              final lido =
                                  _progressoLocal['${livro.id}_$capitulo'] ??
                                  false;

                              // gesture detector para marcar/desmarcar capítulo ou exibir versículo
                              return GestureDetector(
                                onTap: () async {
                                  // sempre exibe os versículos do capítulo no clique simples
                                  _exibirVersiculoCapitulo(livro, capitulo);
                                },
                                onLongPress: () {
                                  // long press para marcar/desmarcar capítulo como lido
                                  _atualizarProgresso(
                                    livro.id!,
                                    capitulo,
                                    !lido,
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: lido
                                        ? Colors.green
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: lido
                                          ? Colors.green.shade700
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                    boxShadow: lido
                                        ? [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: lido
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : Text(
                                            '$capitulo',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _exibirVersiculoCapitulo(
    LivroBiblico livro,
    int capitulo,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final versiculos = await _bibliaService.buscarCapitulo(
        nomeLivro: livro.nome!,
        capitulo: capitulo,
      );

      if (mounted) {
        Navigator.of(context).pop(); // remove o loading dialog

        if (versiculos != null && versiculos.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.auto_stories, color: Colors.indigo, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${livro.nome} - Capítulo $capitulo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // cabeçalho com informações
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.indigo.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.translate,
                              size: 16,
                              color: Colors.indigo.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Tradução: ${versiculos[0].traducao!}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${versiculos.length} versículos",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // lista de versículos
                      ...versiculos.map((versiculo) {
                        // extrair o número do versículo da referência
                        final versiculoNumero = versiculo.referencia!
                            .split(':')
                            .last;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Número do versículo
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    versiculoNumero,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Texto do versículo
                              Expanded(
                                child: Text(
                                  versiculo.texto!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao carregar versículos. Tente novamente.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // remove o loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar versículos: $e')),
        );
      }
    }
  }
}

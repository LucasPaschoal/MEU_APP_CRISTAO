import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database/firebase_options.dart';
import 'tela_oracao.dart';
import 'tela_devocional.dart';
import 'tela_progresso_leitura.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // garante que o flutter esteja pronto para usar plugins
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MeuAppCristao());
}

// é um Stateless porque seu estado não muda após a criação.
class MeuAppCristao extends StatelessWidget {
  const MeuAppCristao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeuAppCristao',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // cor primária para o tema do aplicativo
        primarySwatch: Colors.indigo,
        // cor de fundo padrão para os Scaffolds
        scaffoldBackgroundColor: Colors.indigo.shade50,
        appBarTheme: const AppBarTheme(
          // cor de fundo das AppBars
          backgroundColor: Colors.indigo,
          // cor do texto e ícones nas AppBars
          foregroundColor: Colors.white,
          // para centralizar o título da AppBar
          centerTitle: true,
          // elevation é para definir a sombra da AppBar
          elevation: 2,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          // cor de fundo do FloatingActionButton
          backgroundColor: Colors.indigo.shade700,
          // cor do ícone do FloatingActionButton
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ), // margem padrão dos Cards
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.indigo; // cor do checkbox quando selecionado
            }
            return Colors.grey; // cor do checkbox quando não selecionado
          }),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.indigo.shade600),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.indigo.shade700,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const PaginaPrincipal(),
    );
  }
}

/*
  navegações inferiores (oração, devocionais, leitura Bíblica).
  é um Stateful porque seu estado (o índice da aba selecionada) muda.
*/
class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  // variável de estado que armazena o índice da aba selecionada
  int _indiceAtual = 0;

  // telas que serão exibidas em cada aba da BottomNavigationBar
  final List<Widget> _telas = const [
    PedidosOracaoTela(), // oração
    DevocionaisTela(), // devocional
    LeituraBiblicaTela(), // leitura
  ];

  // setState é responsável por atualizar o estado do widget quando um item da BottomNavigationBar é tocado
  void _aoTocarItem(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_indiceAtual], // Exibe a tela correspondente ao índice atual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: _aoTocarItem,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,

        // garante que todos os itens sejam sempre visíveis
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined), // ícone quando inativo
            activeIcon: Icon(Icons.handshake), // ícone quando ativo
            label: 'Oração',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined), // ícone quando inativo
            activeIcon: Icon(Icons.auto_stories), // ícone quando ativo
            label: 'Devocionais',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined), // ícone quando inativo
            activeIcon: Icon(Icons.book), // ícone quando ativo
            label: 'Leitura',
          ),
        ],
      ),
    );
  }
}

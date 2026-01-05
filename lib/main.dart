import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adaptive_layout/adaptive_layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'GitHub Repo Viewer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromRGBO(203, 166, 247, 1.0),
          ),
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>{};

  void toggleFavorite(WordPair? pair) {
    if (pair == null) return;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  bool isFavorite(WordPair? pair) {
    return favorites.contains(pair);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page = switch (selectedIndex) {
      0 => GeneratorPage(),
      1 => FavoritesPage(),
      _ => throw UnimplementedError('no widget for $selectedIndex'),
    };

    return AdaptiveLayout(
      smallLayout: Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ),
        bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) {
            setState(() {
              selectedIndex = idx;
            });
          },
          destinations: const [
            NavigationDestination(
              label: 'Home',
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
            ),
            NavigationDestination(
              label: 'Favorites',
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
            ),
          ],
        ),
      ),

      largeLayout: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    labelType: NavigationRailLabelType.selected,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (idx) {
                      setState(() {
                        selectedIndex = idx;
                      });
                    },
                    destinations: const [
                      NavigationRailDestination(
                        label: Text('Home'),
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                      ),
                      NavigationRailDestination(
                        label: Text('Favorites'),
                        icon: Icon(Icons.favorite_border),
                        selectedIcon: Icon(Icons.favorite),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  WordPair? selectedItem;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    return Center(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: 250,
              height: 400,
              margin: EdgeInsets.only(left: 70),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (var m in appState.favorites)
                      ListTile(
                        selected: selectedItem == m,
                        title: Center(child: Text(m.asLowerCase)),
                        onTap: () {
                          setState(() {
                            selectedItem = m;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: switch (selectedItem) {
                  null => [Text('Select a favorite to view details')],
                  WordPair pair => [
                    BigCard(pair: pair),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => appState.toggleFavorite(selectedItem),
                      icon: appState.isFavorite(selectedItem)
                          ? Icon(Icons.favorite)
                          : Icon(Icons.favorite_border),
                      label: Text('Like'),
                    ),
                  ],
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: appState.current),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => appState.toggleFavorite(appState.current),
                icon: appState.isFavorite(appState.current)
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                label: Text('Like'),
              ),

              SizedBox(width: 10),

              ElevatedButton.icon(
                onPressed: () => appState.getNext(),
                icon: Icon(Icons.arrow_forward),
                label: Text('Harass Cashier Lady'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

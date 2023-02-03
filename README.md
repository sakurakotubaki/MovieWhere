# where_query

## Firebaseのwhereを使って条件にマッチした情報を取得する
string_id_arrayの中の文字にヒットした候補を表示する
```dart
List searchResult = []; // 空のリストを作る.
  // .whereでstring_id_arrayを検索して、候補を表示する
  void searchFromFirebase(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('search')
        .where('string_id_array', arrayContains: query)
        .get();
    // リストに、検索して取得したデータを保存する.
    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }
```

## number_id_arrayの中の文字にヒットした候補を表示する
```dart
List searchResult = []; // 空のリストを作る.
  // .whereでstring_id_arrayを検索して、候補を表示する
  void searchFromFirebase(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('search')
        .where('number_id_array', arrayContains: query)
        .get();
    // リストに、検索して取得したデータを保存する.
    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }
```

-----

# 映画のデータを取得する方法
Firestoreのデータ構造

```json
{"title": "天気の子", "genre": "恋愛", "title_array": ["深海誠作品", "映像作品", "名作"]}
```

```dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirebaseSearchScreen(),
    );
  }
}

class FirebaseSearchScreen extends StatefulWidget {
  const FirebaseSearchScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseSearchScreen> createState() => _FirebaseSearchScreenState();
}

class _FirebaseSearchScreenState extends State<FirebaseSearchScreen> {
  List searchResult = []; // 空のリストを作る.
  // .whereでstring_id_arrayを検索して、候補を表示する
  void searchFromFirebase(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('search')
        .where('title_array', arrayContains: query)
        .get();
    // リストに、検索して取得したデータを保存する.
    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search Here",
              ),
              onChanged: (query) {
                searchFromFirebase(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResult.length, // リストの数をlengthで数える.
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(searchResult[index]['title']),
                  subtitle: Text(searchResult[index]['genre']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

```

-------

# Riverpodでリファクタリングしたコード
検索機能を使用するメソッドが定義されたStateNotifier

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 空のリストを作る.
// dynamic型にしないと、メソッドの中のresultを代入できなかった!
final searchResultProvider = StateProvider<List<dynamic>>((ref) => []);
// Firestoreを使うProvider.
final firebaseProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
// SearchStateNotifireを呼び出すProvider.
final searchStateNotifireProvider =
    StateNotifierProvider<SearchStateNotifire, dynamic>((ref) {
  return SearchStateNotifire(ref);
});

// キーワードで映画を検索するメソッドが使えるStateNotifier.
class SearchStateNotifire extends StateNotifier<dynamic> {
  Ref _ref;
  SearchStateNotifire(this._ref) : super([]);

  // .whereでstring_id_arrayを検索して、候補を表示する
  Future<void> searchWhere(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('search')
        .where('title_array', arrayContains: query)
        .get();
    // リストに、検索して取得したデータを保存する.
    _ref.watch(searchResultProvider.notifier).state =
        result.docs.map((e) => e.data()).toList();
  }
}
```

StateNotifierの検索機能を使って画面に描画するファイル

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:where_query/search_state.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirestoreSearch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirebaseSearchScreen(),
    );
  }
}

class FirebaseSearchScreen extends ConsumerWidget {
  const FirebaseSearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ListView.builderのitemCountで使用するListのProviderを呼び出す.
    final result = ref.watch(searchResultProvider);
    // Firestoreの映画情報を検索するProviderを呼び出す.
    final searchState = ref.read(searchStateNotifireProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("FirestoreSearch"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search Here",
              ),
              onChanged: (query) {
                searchState
                    .searchWhere(query); // onChangedを使用して、メソッドの引数にFormの値を保存する.
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: result.length, // リストの数をlengthで数える.
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(result[index]['title']), // 映画のタイトルを表示する.
                  subtitle: Text(result[index]['genre']), // 映画のジャンルを表示する.
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

```

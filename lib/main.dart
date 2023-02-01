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

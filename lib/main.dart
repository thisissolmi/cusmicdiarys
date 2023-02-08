import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String title = "오늘의 제육볶음";
  final FieldValue createdTime = FieldValue.serverTimestamp();
  final String imageUrl =
      "https://play.google.com/store/apps/details?id=nunioz.app.pub_dev&hl=ko&gl=US";
  final String content =
      "In the eighteenth century the German philosopher Immanuel Kant developed a theory of knowledge in which knowledge about space can be both a priori and synthetic. According to Kant, knowledge about space is synthetic, in that statements about space are not simply true by virtue of the meaning of the words in the statement. In his work, Kant rejected the view that space must be either a substance or relation. Instead he came to the conclusion that space and time are not discovered by humans to be objective features of the world, but imposed by us as part of a framework for organizing experience.";
  final List<String> keywords = ["제육볶음", "데이트"];

  final dirayCollectionRef = FirebaseFirestore.instance.collection('diary');

  @override
  Widget build(BuildContext context) {
    final Diary targetDairy = Diary(
        title: title,
        createdTime: createdTime,
        imageUrl: imageUrl,
        content: content,
        keywords: keywords);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                //Image.network(imageUrl),
                Text(
                  content,
                  overflow: TextOverflow.ellipsis,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: keywords.length,
                  itemBuilder: (context, index) {
                    return Text(keywords[index]);
                  },
                ),
              ],
            ),
            OutlinedButton(
                onPressed: () async {
                  await dirayCollectionRef.add(targetDairy.toMap());
                  log("uploaded successfully");
                },
                child: const Text("upload")),
          ],
        ),
      ),
    );
  }
}

class Diary {
  final String title;
  final FieldValue createdTime;
  final String imageUrl;
  final String content;
  final List<String> keywords;
  final String? docId;

  Diary({
    required this.title,
    required this.createdTime,
    required this.imageUrl,
    required this.content,
    required this.keywords,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      titleFieldName: title,
      createdTimeFieldName: createdTime,
      imageUrlFieldName: imageUrl,
      contentFieldName: content,
      keywordsFieldName: keywords
    };
  }

  factory Diary.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final snapshotData = snapshot.data();
    return Diary(
      docId: snapshot.id,
      title: snapshotData[titleFieldName],
      createdTime: snapshotData[createdTimeFieldName],
      imageUrl: snapshotData[imageUrlFieldName],
      content: snapshotData[contentFieldName],
      keywords: snapshotData[keywordsFieldName],
    );
  }

  factory Diary.fromDocSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      log("cannot find snapshot");
      throw Exception();
    }
    final snapshotData = snapshot.data()!;
    return Diary(
      docId: snapshot.id,
      title: snapshotData[titleFieldName],
      createdTime: snapshotData[createdTimeFieldName],
      imageUrl: snapshotData[imageUrlFieldName],
      content: snapshotData[contentFieldName],
      keywords: snapshotData[keywordsFieldName],
    );
  }
}

const String titleFieldName = "title";
const String createdTimeFieldName = "created-date";
const String imageUrlFieldName = "image-url";
const String contentFieldName = "content";
const String keywordsFieldName = "keywords";

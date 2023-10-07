import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/highlights/highlightModel.dart';

class FirestoreServiceAPI extends GetxController{
  static FirestoreServiceAPI get instance => Get.find();

  final CollectionReference highlights = FirebaseFirestore.instance.collection("highlights");

  Stream<QuerySnapshot> fetchHighlights() {
    try {
      final highlightsStream = highlights.orderBy("publishedAt", descending: true).snapshots();
      return highlightsStream;
    } catch (e) {
      print('Error fetching highlights: $e');
      throw e;
    }
  }

  Future<Future<DocumentReference<Object?>>> addHighlights() async {
    try {
      return highlights.add({
        'title': "highlight",
        'timestamp': Timestamp.now()
      });
    } catch (e) {
      print('Error fetching highlights: $e');
      throw e;
    }
  }
}

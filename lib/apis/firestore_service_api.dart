import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/highlights/highlightModel.dart';

class FirestoreServiceAPI extends GetxController{
  static FirestoreServiceAPI get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<HighlightModel>> fetchHighlights() async {
    try {
      final snapshot = await _firestore.collection("highlights").get();
      print('highlights: $snapshot');
      final highlightsData = snapshot.docs.map((e) => HighlightModel.fromSnapShot(e)).toList();
      return highlightsData;
    } catch (e) {
      print('Error fetching highlights: $e');
      throw e;
    }
  }

}

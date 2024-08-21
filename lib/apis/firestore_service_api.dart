import 'package:avvento_media/componets/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';


class FirestoreServiceAPI extends GetxController{
  static FirestoreServiceAPI get instance => Get.find();

  final CollectionReference highlights = FirebaseFirestore.instance.collection(AppConstants.highlightsAPI);
  final CollectionReference liveTv = FirebaseFirestore.instance.collection(AppConstants.liveTvAPI);
  final CollectionReference radio = FirebaseFirestore.instance.collection(AppConstants.radioAPI);
  final CollectionReference apiKeys = FirebaseFirestore.instance.collection(AppConstants.apiKeysAPI);

  Stream<QuerySnapshot> fetchHighlights() {
    try {
      final highlightsStream = highlights.orderBy("publishedAt", descending: true).snapshots();
      return highlightsStream;
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> fetchLiveTv() {
    try {
      final liveTvStream = liveTv.orderBy("publishedAt", descending: true).snapshots();
      return liveTvStream;
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> fetchRadio() {
    try {
      final liveTvStream = radio.orderBy("publishedAt", descending: true).snapshots();
      return liveTvStream;
    } catch (e) {
      rethrow;
    }
  }

}

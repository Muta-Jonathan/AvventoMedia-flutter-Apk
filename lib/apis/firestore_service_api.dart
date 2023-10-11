import 'package:avvento_radio/componets/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class FirestoreServiceAPI extends GetxController{
  static FirestoreServiceAPI get instance => Get.find();

  final CollectionReference highlights = FirebaseFirestore.instance.collection(AppConstants.highlightsAPI);
  final CollectionReference liveTv = FirebaseFirestore.instance.collection(AppConstants.liveTvAPI);
  final CollectionReference radio = FirebaseFirestore.instance.collection(AppConstants.radioAPI);

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

  // Future<Future<DocumentReference<Object?>>> addHighlights() async {
  //   try {
  //     return highlights.add({
  //       'title': "highlight",
  //       'timestamp': Timestamp.now()
  //     });
  //   } catch (e) {
  //     print('Error fetching highlights: $e');
  //     throw e;
  //   }
  // }
}

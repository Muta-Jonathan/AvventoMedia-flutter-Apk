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

  Future<String> fetchApiKey(String apiKeyName) async {
    try {
      // Initialize Firebase (if not initialized elsewhere)
      await Firebase.initializeApp();

      // Fetch API key from Firestore using apiKeys collection reference
      DocumentSnapshot documentSnapshot = await apiKeys.doc(AppConstants.youtube).get();

      // Check if document exists and extract API key
      if (documentSnapshot.exists) {
        // Access document data as Map<String, dynamic>
        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;

        // Check if data is not null and contains the apiKeyName
        if (data != null && data.containsKey(apiKeyName)) {
          // Cast data[apiKeyName] to String and return
          return data[apiKeyName] as String;
        } else {
          throw Exception('API key $apiKeyName not found in Firestore');
        }
      } else {
        throw Exception('Document not found in Firestore');
      }
    } catch (e) {
      throw Exception('Failed to fetch API key');
    }
  }
}

import 'package:avvento_media/componets/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class FirestoreServiceAPI extends GetxController{
  static FirestoreServiceAPI get instance => Get.find();

  final CollectionReference highlights = FirebaseFirestore.instance.collection(AppConstants.highlightsAPI);
  final CollectionReference liveTv = FirebaseFirestore.instance.collection(AppConstants.liveTvAPI);
  final CollectionReference radio = FirebaseFirestore.instance.collection(AppConstants.radioAPI);
  final CollectionReference apiKeys = FirebaseFirestore.instance.collection(AppConstants.apiKeysAPI);
  final CollectionReference ytMainPlaylistIds = FirebaseFirestore.instance.collection(AppConstants.desiredPlaylistId); // Add a reference to your playlists collection

  // Fetch playlist IDs or titles from Firestore
  Future<List<String>> fetchDesiredPlaylistIds() async {
    try {
      final querySnapshot = await ytMainPlaylistIds.get();
      if (querySnapshot.docs.isEmpty) {
        throw Exception('No documents found');
      }

      // Assuming there's only one document in the collection
      final documentSnapshot = querySnapshot.docs.first;
      final data = documentSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> ids = data['ids'] ?? [];
      return List<String>.from(ids);
    } catch (e) {
      rethrow;
    }
  }

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

import 'package:avvento_media/components/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/livetvmodel/livetv_model.dart';
import '../models/radiomodel/radio_model.dart';
import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';


class FirestoreServiceAPI extends GetxController {
  static FirestoreServiceAPI get instance => Get.find();

  final CollectionReference highlights = FirebaseFirestore.instance.collection(
      AppConstants.highlightsAPI);
  final CollectionReference liveTv = FirebaseFirestore.instance.collection(
      AppConstants.liveTvAPI);
  final CollectionReference radio = FirebaseFirestore.instance.collection(
      AppConstants.radioAPI);
  final CollectionReference apiKeys = FirebaseFirestore.instance.collection(
      AppConstants.apiKeysAPI);
  final CollectionReference ytMainPlaylistIds = FirebaseFirestore.instance
      .collection(AppConstants.desiredPlaylistId);
  final CollectionReference ytPlaylists = FirebaseFirestore.instance.collection(
      AppConstants.playlists);

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
      final highlightsStream = highlights.orderBy(
          "publishedAt", descending: true).snapshots();
      return highlightsStream;
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> fetchLiveTv() {
    try {
      final liveTvStream = liveTv
          .orderBy("publishedAt", descending: true)
          .snapshots();
      return liveTvStream;
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> fetchRadio() {
    try {
      final liveTvStream = radio
          .orderBy("publishedAt", descending: true)
          .snapshots();
      return liveTvStream;
    } catch (e) {
      rethrow;
    }
  }

  // ----------------------------------------------
  // 🔥 NEW: Firestore structure for YouTube playlists
  // playlists/{channelName}/playlists/{playlistId}/items/{videoId}
  // ----------------------------------------------

  // // Fetch channel info Path: playlists/{channelName}/info/info
  // Future<Map<String, dynamic>?> fetchChannelInfo(String channelName) async {
  //   final doc = await ytPlaylists
  //       .doc(channelName)
  //       .collection("info")
  //       .doc("info")
  //       .get();
  //   return doc.data();
  // }

  // --- PLAYLISTS ---
  /// Stream of all playlists for a given channel (real-time) Path: playlists/{channelName}/playlists
  Stream<List<YoutubePlaylistModel>> streamPlaylists(String channelName) {
    final playlistsCollection = ytPlaylists.doc(channelName).collection(
        'channel')
        .orderBy('latestPublishedAt', descending: true); // SORT BY NEW UPLOAD

    return playlistsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return YoutubePlaylistModel.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  // Fetch a single playlist by ID Path: playlists/{channelName}/playlists/{playlistId}
  Future<Map<String, dynamic>?> fetchPlaylistById(String channelName,
      String playlistId,) async {
    final doc = await ytPlaylists
        .doc(channelName)
        .collection("channel")
        .doc(playlistId)
        .get();

    return doc.data();
  }

  /// Stream of items for a given playlist (real-time) Path: playlists/{channelName}/playlists/{playlistId}/items
  Stream<List<YouTubePlaylistItemModel>> streamPlaylistItems(String channelName,
      String playlistId) {
    final itemsCollection = ytPlaylists
        .doc(channelName)
        .collection('channel')
        .doc(playlistId)
        .collection('items');
    return itemsCollection
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data();
          return YouTubePlaylistItemModel.fromFirestore(doc.id, data);
        }).toList());
  }

  // Fetch a single video by videoId Path: playlists/{channelName}/playlists/{playlistId}/items/{videoId}
  Future<Map<String, dynamic>?> fetchVideoById(String channelName,
      String playlistId,
      String videoId,) async {
    final doc = await ytPlaylists
        .doc(channelName)
        .collection("channel")
        .doc(playlistId)
        .collection("items")
        .doc(videoId)
        .get();

    return doc.data();
  }

  // Fetch documents ONLY from local Firestore cache
  Future<List<DocumentSnapshot>> _getCachedCollectionDocs(
      CollectionReference ref) async {
    try {
      final snap = await ref.get(const GetOptions(source: Source.cache));
      return snap.docs;
    } catch (_) {
      // Fallback: load from server one time, also stored into cache
      final snap = await ref.get(
          const GetOptions(source: Source.serverAndCache));
      return snap.docs;
    }
  }

  Future<List<LiveTvModel>> loadLiveTvOffline() async {
    final docs = await _getCachedCollectionDocs(liveTv);
    return docs.map((doc) => LiveTvModel.fromSnapShot(doc)).toList();
  }

  Future<List<RadioModel>> loadRadioOffline() async {
    final docs = await _getCachedCollectionDocs(radio);
    return docs.map((doc) => RadioModel.fromSnapShot(doc)).toList();
  }

  Future<List<YoutubePlaylistModel>> loadPlaylistsOffline(
      String channelName) async {
    final ref = ytPlaylists.doc(channelName).collection("channel");
    final docs = await _getCachedCollectionDocs(ref);

    return docs.map((doc) {
      return YoutubePlaylistModel.fromFirestore(
          doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }


  Future<List<YouTubePlaylistItemModel>> loadPlaylistItemsOffline(
      String channelName, String playlistId) async {
    final ref = ytPlaylists
        .doc(channelName)
        .collection("channel")
        .doc(playlistId)
        .collection("items");

    final docs = await _getCachedCollectionDocs(ref);

    return docs.map((doc) {
      return YouTubePlaylistItemModel.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }
}

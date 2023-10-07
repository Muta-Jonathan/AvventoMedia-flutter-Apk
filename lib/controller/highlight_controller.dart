import 'package:avvento_radio/apis/firestore_service_api.dart';
import 'package:avvento_radio/models/highlights/highlightModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HighlightController extends GetxController {
  static HighlightController get instance => Get.find();

  final _firestoreServiceAPI = Get.put(FirestoreServiceAPI());

  Future<Stream<QuerySnapshot<Object?>>> getAllHighlights() async {
    return await _firestoreServiceAPI.fetchHighlights();
  }
}
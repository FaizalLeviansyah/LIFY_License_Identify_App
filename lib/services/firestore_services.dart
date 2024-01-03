import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static CollectionReference results =
      FirebaseFirestore.instance.collection('results');

  static Future<void> createOrUpdateResult(String id,
      {required String textResult}) async {
    await results.doc(id).set({'result': textResult});
  }

  static Future<DocumentSnapshot> getResult(String id) async {
    return await results.doc(id).get();
  }

  
}
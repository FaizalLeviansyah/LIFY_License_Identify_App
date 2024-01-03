import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Result {
  List<String> resultList;
  List<String> imageList;
  Result({required this.resultList, required this.imageList});

  Map<String, dynamic> toJson() => {
        'plate': FieldValue.arrayUnion(resultList),
        'plate_image': FieldValue.arrayUnion(imageList),
      };
  static Result fromJson(Map<String, dynamic> json) {
    List<dynamic> dynamicList = json['plate'];
    List<dynamic> dynamicImageList = json['plate_image'];
    List<String> stringList = List<String>.from(dynamicList);
    List<String> stringImageList = List<String>.from(dynamicImageList);

    return Result(resultList: stringList, imageList: stringImageList);
  }
}

class History {
  List<String> historyList;
  History({required this.historyList});

  Map<String, dynamic> toJson() => {
        'plate_history': FieldValue.arrayUnion(historyList),
      };
  static History fromJson(Map<String, dynamic> json) {
    List<dynamic> dynamicList = json['plate_history'];
    List<String> stringList = List<String>.from(dynamicList);

    return History(historyList: stringList);
  }
}

Future<void> createResult(
    {required String uid,
    required String textResult,
    required String filePath}) async {
  List<String> resultList = [];
  List<String> imageList = [];
  resultList.add(textResult);
  imageList.add(filePath);

  final docResult = FirebaseFirestore.instance.collection('results').doc(uid);
  final result = Result(resultList: resultList, imageList: imageList);
  final json = result.toJson();
  await docResult.set(json, SetOptions(merge: true));
}

Future<Result?> readResult({required String uid}) async {
  try {
    final docResult = FirebaseFirestore.instance.collection('results').doc(uid);
    final snapshot = await docResult.get();
    if (snapshot.exists) {
      return Result.fromJson(snapshot.data()!);
    } else {
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<void> deleteResult(
    {required String uid, required String textResult}) async {
  try {
    final docResult = FirebaseFirestore.instance.collection('results').doc(uid);

    DocumentSnapshot docSnapshot = await docResult.get();
    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
    int? index = data!['plate'].indexOf(textResult);

    await docResult.update(
      {
        'plate': FieldValue.arrayRemove([textResult])
      },
    );
    await docResult.update(
      {
        'plate_image': FieldValue.arrayRemove([data['plate_image'][index]])
      },
    );
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> createHistory(
    {required String uid, required String textResult}) async {
  List<String> historyList = [];
  historyList.add(textResult);

  final docHistory = FirebaseFirestore.instance.collection('history').doc(uid);
  final history = History(historyList: historyList);
  final json = history.toJson();
  await docHistory.set(json, SetOptions(merge: true));
}

Future<bool> resultChecker(
    {required String uid, required String result}) async {
  try {
    final docResult =
        await FirebaseFirestore.instance.collection('results').doc(uid).get();

    if (docResult.exists) {
      final resultObject =
          Result.fromJson(docResult.data() as Map<String, dynamic>);
      final plateList = resultObject.resultList;

      if (plateList.contains(result)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

Future<History?> readHistory({required String uid}) async {
  try {
    final docHistory =
        FirebaseFirestore.instance.collection('history').doc(uid);
    final snapshot = await docHistory.get();
    if (snapshot.exists) {
      return History.fromJson(snapshot.data()!);
    } else {
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<void> clearHistory({required String uid}) async {
  final docHistory = FirebaseFirestore.instance.collection('history').doc(uid);
  final history = History(historyList: []);
  await docHistory.set(history.toJson(), SetOptions(merge: false));
}

class ResultImage {
  List<String> imageList;
  ResultImage({required this.imageList});

  Map<String, dynamic> toJson() => {
        'plate_image': FieldValue.arrayUnion(imageList),
      };
  static ResultImage fromJson(Map<String, dynamic> json) {
    List<dynamic> dynamicList = json['plate_image'];
    List<String> stringList = List<String>.from(dynamicList);

    return ResultImage(imageList: stringList);
  }
}

Future<String?> uploadImage(
    {required String uid, required String result, required File image}) async {
  try {
    UploadTask? uploadTask;
    final path = 'plate_image/$uid/$result.jpg';
    final file = File(image.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    return urlDownload;
  } catch (e) {
    print('Error : $e');
    return null;
  }
}

Future<void> deleteImage({required String uid, required String result}) async {
  try {
    final path = 'plate_image/$uid/$result.jpg';
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.delete();
  } catch (e) {
    print('Error : $e');
  }
}

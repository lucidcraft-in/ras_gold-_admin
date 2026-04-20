import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GoldrateModel {
  final String id;
  final double gram;
  final double pavan;
  final double down;
  final double up;
  final double gram18;
  final String updateDate;
  final String updateTime;

  GoldrateModel({
    required this.id,
    required this.gram,
    required this.pavan,
    required this.down,
    required this.up,
    required this.gram18,
    required this.updateDate,
    required this.updateTime,
  });
  GoldrateModel copyWith({
    String? id,
    double? gram,
    double? pavan,
    double? down,
    double? up,
    double? gram18,
    String? updateDate,
    String? updateTime,
  }) {
    return GoldrateModel(
      id: id ?? this.id,
      gram: gram ?? this.gram,
      pavan: pavan ?? this.pavan,
      down: down ?? this.down,
      up: up ?? this.up,
      gram18: gram18 ?? this.gram18,
      updateDate: updateDate ?? this.updateDate,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  GoldrateModel.fromData(Map<String, dynamic> data)
      : id = data['id'],
        gram = data['gram'],
        pavan = data['pavan'],
        down = data['down'],
        up = data['up'],
        gram18 = data['18gram'],
        updateDate = data['updateDate'],
        updateTime = data['updateTime'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gram': gram,
      'pavan': pavan,
      'down': down,
      'up': up,
      '18gram': gram18,
      'updateDate': updateDate,
      'updateTime': updateTime,
    };
  }
}

class Goldrate with ChangeNotifier {
  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('goldrate');

  late List<GoldrateModel> _goldRate;

  Future<bool?> checkPermission() async {
    bool permission = true;
    String msg = "";
    QuerySnapshot querySnapshot;

    try {
      querySnapshot = await collectionReference.get().catchError((err) {
        if (err.code == "permission-denied") {
          permission = false;
          msg = "permission-denied";
        }
      });
      if (querySnapshot.docs.isNotEmpty) {
        return permission = true;
      }

      return permission;
      // return permission = true;
    } catch (e) {
      if (msg == "permission-denied") {
        return permission = false;
      }

      // if (e.code == "PERMISSION_DENIED") {
      //   print("helo disooooooooooooooo");
      //   return permission = false;
      // }
    }
  }

  Future<void> create(GoldrateModel goldrateModel) async {
    try {
      await collectionReference.add({
        'gram': goldrateModel.gram,
        'pavan': goldrateModel.pavan,
        'down': goldrateModel.down,
        'up': goldrateModel.up,
        '18gram': goldrateModel.gram18,
        'updateDate': goldrateModel.updateDate,
        'updateTime': goldrateModel.updateTime,
      });

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> update(String id, GoldrateModel goldrateModel) async {
    try {
      await collectionReference.doc(id).update({
        'gram': goldrateModel.gram,
        'pavan': goldrateModel.pavan,
        'down': goldrateModel.down,
        'up': goldrateModel.up,
        '18gram': goldrateModel.gram18,
        'updateDate': goldrateModel.updateDate,
        'updateTime': goldrateModel.updateTime,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List?> read() async {
    QuerySnapshot querySnapshot;
    List goldRateList = [];
    try {
      querySnapshot = await collectionReference.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          goldRateList.add({
            "id": doc.id,
            "gram": doc['gram'],
            "pavan": doc["pavan"],
            "down": doc["down"],
            "up": doc["up"],
            "18gram": doc["18gram"],
            "updateDate": doc["updateDate"],
            "updateTime": doc["updateTime"],
          });
        }
        return goldRateList;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}

class FetchDataException implements Exception {
  final _message;
  FetchDataException([this._message]);

  String toString() {
    if (_message == null) return "Exception";
    return "Exception: $_message";
  }
}

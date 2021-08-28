import 'dart:async';

import 'package:firestore_service/firestore_service.dart';
import 'package:creative_park/services/firestore_path.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase({required this.uid});
  final String uid;

  final _service = FirestoreService.instance;

}

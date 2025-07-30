// lib/features/home/repository/home_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inner_circle/core/models/user_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HomeRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // دالة لجلب قائمة المستخدمين كـ Stream (تحديث فوري)
  Stream<List<UserModel>> getUsers() {
    // نراقب أي تغييرات في مجموعة 'users'
    return _firestore.collection('users').snapshots().map((snapshot) {
      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        var user = UserModel.fromMap(doc.data());
        // نضيف المستخدم إلى القائمة فقط إذا لم يكن هو المستخدم الحالي
        if (user.uid != _auth.currentUser!.uid) {
          users.add(user);
        }
      }
      return users;
    });
  }
}

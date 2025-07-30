// lib/core/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePic; // سنستخدمها لاحقاً

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
  });

  // دالة لتحويل بيانات المستخدم إلى خريطة (Map) لحفظها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
    };
  }

  // دالة لإنشاء كائن UserModel من خريطة قادمة من Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }
}

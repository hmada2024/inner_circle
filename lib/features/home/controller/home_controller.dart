// lib/features/home/controller/home_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';
import 'package:inner_circle/features/home/repository/home_repository.dart';

// Provider لتوفير نسخة من HomeRepository
final homeRepositoryProvider = Provider(
  (ref) => HomeRepository(
    firestore: ref.read(firebaseFirestoreProvider),
    auth: ref.read(firebaseAuthProvider),
  ),
);

// Provider للوصول إلى HomeController
final homeControllerProvider = Provider((ref) {
  final homeRepository = ref.watch(homeRepositoryProvider);
  return HomeController(homeRepository: homeRepository);
});

// Provider حيوي جداً: يقوم بتوفير قائمة المستخدمين للواجهة بشكل فوري
final usersProvider = StreamProvider<List<UserModel>>((ref) {
  final homeController = ref.watch(homeControllerProvider);
  return homeController.getUsers();
});

class HomeController {
  final HomeRepository _homeRepository;
  HomeController({required HomeRepository homeRepository})
      : _homeRepository = homeRepository;

  Stream<List<UserModel>> getUsers() {
    return _homeRepository.getUsers();
  }
}

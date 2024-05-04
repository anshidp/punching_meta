import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:punching_machine/model/userModel.dart';

// class UserSingleton {
//   static final UserSingleton _singleton = UserSingleton._internal();

//   factory UserSingleton() {
//     return _singleton;
//   }

//   UserSingleton._internal();

//   Usermodel? _usermodel;

//   Usermodel? get usermodel => _usermodel;

//   void setUserModel(Usermodel usermodel) {
//     _usermodel = usermodel;
//   }
// }

final userProvider = NotifierProvider<UserNotifier, Usermodel>(() {
  return UserNotifier();
});

class UserNotifier extends Notifier<Usermodel> {
  UserNotifier();

  @override
  build() {
    return Usermodel();
  }

  void updateUser(Usermodel updatedUser) {
    state = updatedUser;
  }
}

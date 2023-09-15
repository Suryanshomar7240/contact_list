import 'package:contract_list/actions/auth.dart';
import 'package:contract_list/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStateNotifer extends StateNotifier<User> {
  final Ref ref;
  UserStateNotifer(this.ref) : super(User());
  void updateLoginStatus(bool isLoggedIn) {
    state = state.copyWith(loggedin: isLoggedIn);
  }

  void updateUser(User user) {
    state = user;
  }

  void signOut() {
    AuthService().signout();
    state = User();
  }
}

final userStateProvider = StateNotifierProvider<UserStateNotifer, User>(
    (ref) => UserStateNotifer(ref));

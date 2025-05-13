import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserInitial());

  Future<void> checkUserStatus() async {
    emit(const UserLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedUser = prefs.getString('selectedUser');

      if (savedUser != null) {
        emit(UserAuthenticated(savedUser));
      } else {
        emit(const UserUnauthenticated());
      }
    } catch (e) {
      emit(const UserUnauthenticated());
    }
  }

  Future<void> loginUser(String username) async {
    emit(const UserLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedUser', username);
      emit(UserAuthenticated(username));
    } catch (e) {
      emit(const UserUnauthenticated());
    }
  }

  Future<void> logoutUser() async {
    emit(const UserLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selectedUser');
      emit(const UserUnauthenticated());
    } catch (e) {
      emit(const UserUnauthenticated());
    }
  }
}

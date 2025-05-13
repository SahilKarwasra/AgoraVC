import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserAuthenticated extends UserState {
  final String username;

  const UserAuthenticated(this.username);

  @override
  List<Object?> get props => [username];
}

class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
}

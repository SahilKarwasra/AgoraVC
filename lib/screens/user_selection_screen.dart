import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';
import 'home_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(username: state.username),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select User'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose a user to continue',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),
              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  final bool isLoading = state is UserLoading;
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () => _selectUser(context, 'User A'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Login as User A',
                                  style: TextStyle(fontSize: 18),
                                ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () => _selectUser(context, 'User B'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Login as User B',
                                  style: TextStyle(fontSize: 18),
                                ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectUser(BuildContext context, String user) {
    // Use the UserCubit to login the user
    context.read<UserCubit>().loginUser(user);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';
import '../models/call_model.dart';
import 'user_selection_screen.dart';
import 'video_call_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final String otherUser = CallModel.getOtherUser(username);

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSelectionScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Call App'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                final bool isLoading = state is UserLoading;
                return IconButton(
                  icon:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.logout),
                  onPressed: isLoading ? null : () => _logout(context),
                  tooltip: 'Logout',
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // User Identity
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.account_circle, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'You are logged in as:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          username,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Video Call Button
                SizedBox(
                  width: 240,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () => _startVideoCall(context, otherUser),
                    icon: const Icon(Icons.video_call, size: 32),
                    label: Text(
                      'Call $otherUser',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Phase Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Phase 2: Agora Video Call',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      _FeatureItem(
                        icon: Icons.videocam,
                        text: 'Video view for local and remote users',
                      ),
                      _FeatureItem(
                        icon: Icons.mic_off,
                        text: 'Mute/unmute audio',
                      ),
                      _FeatureItem(
                        icon: Icons.videocam_off,
                        text: 'Toggle camera on/off',
                      ),
                      _FeatureItem(
                        icon: Icons.switch_camera,
                        text: 'Switch between front/back camera',
                      ),
                      _FeatureItem(
                        icon: Icons.call_end,
                        text: 'End call functionality',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Use the UserCubit to logout the user
    context.read<UserCubit>().logoutUser();
  }

  void _startVideoCall(BuildContext context, String otherUser) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                VideoCallScreen(username: username, otherUser: otherUser),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerName;
  final Function() onAccept;
  final Function() onDecline;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 20),
            // Caller information
            Column(
              children: [
                const Text(
                  'Incoming Video Call',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'is calling you...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),

            // Call animation
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const CallPulseAnimation(),
            ),

            // Call actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline call button
                GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // Accept call button
                GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CallPulseAnimation extends StatefulWidget {
  const CallPulseAnimation({super.key});

  @override
  State<CallPulseAnimation> createState() => _CallPulseAnimationState();
}

class _CallPulseAnimationState extends State<CallPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 150 * _animation.value,
            height: 150 * _animation.value,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3 * (1 - _animation.value)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 100 * _animation.value,
                height: 100 * _animation.value,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.6 * (1 - _animation.value)),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white, size: 50),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/call_model.dart';

class VideoCallScreen extends StatefulWidget {
  final String username;
  final String otherUser;

  const VideoCallScreen({
    super.key,
    required this.username,
    this.otherUser = "User B", // Default to User B if not specified
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  late RtcEngine _engine;
  bool _permissionsGranted = false;
  String _errorMessage = "";
  String _statusMessage = "Initializing...";
  bool _isMuted = false;
  bool _isCameraOff = false;
  String _channelName = "";

  @override
  void initState() {
    super.initState();
    _setupAndInitializeAgora();
  }

  @override
  void dispose() {
    if (_localUserJoined) {
      _engine.leaveChannel();
    }
    _engine.release();
    super.dispose();
  }

  Future<bool> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;

    if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
      Map<Permission, PermissionStatus> statuses =
          await [Permission.camera, Permission.microphone].request();

      if (statuses[Permission.camera]!.isGranted &&
          statuses[Permission.microphone]!.isGranted) {
        return true;
      } else {
        return false;
      }
    }

    return true;
  }

  Future<void> _setupAndInitializeAgora() async {
    try {
      // Check permissions first
      _permissionsGranted = await _checkPermissions();
      if (!_permissionsGranted) {
        setState(() {
          _errorMessage = "Camera and microphone permissions are required";
        });
        return;
      }

      await _initializeAgora();
    } catch (e) {
      setState(() {
        _errorMessage = "Error during setup: ${e.toString()}";
      });
    }
  }

  Future<void> _initializeAgora() async {

    // Generate channel name based on users
    _channelName = CallModel.generateChannelName(
      widget.username,
      widget.otherUser,
    );


    setState(() {
      _statusMessage = "Setting up video call...";
    });

    try {
      // Create an instance of the Agora engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        const RtcEngineContext(
          appId: CallModel.appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      // Register the event handler
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            setState(() {
              _localUserJoined = true;
              _statusMessage = "Connected to channel: $_channelName";
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            setState(() {
              _remoteUid = remoteUid;
              _remoteUserJoined = true;
            });
          },
          onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
          ) {
            setState(() {
              _remoteUid = null;
              _remoteUserJoined = false;
            });
          },
          onError: (ErrorCodeType err, String msg) {
            _handleAgoraError(err, msg);
          },
        ),
      );

      // Enable video
      await _engine.enableVideo();

      // Set video encoder configuration
      await _engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 15,
          bitrate: 1000,
        ),
      );

      // Start preview
      await _engine.startPreview();

      // Set user role as broadcaster
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Set channel options
      const ChannelMediaOptions options = ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishMicrophoneTrack: true,
        publishCameraTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      );

      // Join the channel
      await _engine.joinChannel(
        token: CallModel.tempToken ?? '',
        channelId: _channelName,
        uid: 0,
        options: options,
      );

      setState(() {
        _statusMessage = "Joined channel: $_channelName";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize Agora: ${e.toString()}";
        _statusMessage = "Call setup failed";
      });
    }
  }

  void _handleAgoraError(ErrorCodeType error, String message) {
    String errorInfo = "";

    switch (error) {
      case ErrorCodeType.errInvalidToken:
      case ErrorCodeType.errTokenExpired:
        errorInfo =
            "Invalid or expired token. Try rejoining without a token for testing.";
        break;
      case ErrorCodeType.errInvalidAppId:
        errorInfo =
            "Invalid App ID. Please check your Agora console for the correct App ID.";
        break;
      case ErrorCodeType.errInvalidChannelName:
        errorInfo =
            "Invalid channel name. Channel names must be alphanumeric and less than 64 characters.";
        break;
      case ErrorCodeType.errNotReady:
        errorInfo = "Engine not ready. Please try again.";
        break;
      default:
        errorInfo = "Error $error: $message";
    }

    setState(() {
      _errorMessage = errorInfo;
    });
  }

  void _toggleMic() async {
    _isMuted = !_isMuted;
    await _engine.muteLocalAudioStream(_isMuted);
    setState(() {
    });
  }

  void _toggleCamera() async {
    _isCameraOff = !_isCameraOff;
    await _engine.muteLocalVideoStream(_isCameraOff);
    setState(() {
    });
  }

  void _switchCamera() async {
    await _engine.switchCamera();
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call with ${widget.otherUser}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () => _endCall(),
            color: Colors.red,
            tooltip: 'End Call',
          ),
        ],
      ),
      body: SafeArea(
        child:
            _permissionsGranted && _errorMessage.isEmpty
                ? Stack(
                  children: [
                    // Video views container
                    Column(
                      children: [
                        // Remote video view
                        Expanded(
                          flex: 2,
                          child:
                              _remoteUserJoined
                                  ? AgoraVideoView(
                                    controller: VideoViewController.remote(
                                      rtcEngine: _engine,
                                      canvas: VideoCanvas(uid: _remoteUid),
                                      connection: RtcConnection(
                                        channelId: _channelName,
                                      ),
                                    ),
                                  )
                                  : Container(
                                    color: Colors.black87,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Waiting for other user to join...',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          if (_localUserJoined)
                                            const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                        ),
                        // Local video view
                        Expanded(
                          flex: 1,
                          child:
                              _localUserJoined
                                  ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    child: AgoraVideoView(
                                      controller: VideoViewController(
                                        rtcEngine: _engine,
                                        canvas: const VideoCanvas(uid: 0),
                                      ),
                                    ),
                                  )
                                  : Container(
                                    color: Colors.grey,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    // Control buttons
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Mute/Unmute
                          FloatingActionButton(
                            onPressed: _toggleMic,
                            backgroundColor:
                                _isMuted ? Colors.red : Colors.blue,
                            child: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                          ),
                          // End call
                          FloatingActionButton(
                            onPressed: _endCall,
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.call_end),
                          ),
                          // Camera on/off
                          FloatingActionButton(
                            onPressed: _toggleCamera,
                            backgroundColor:
                                _isCameraOff ? Colors.red : Colors.blue,
                            child: Icon(
                              _isCameraOff
                                  ? Icons.videocam_off
                                  : Icons.videocam,
                            ),
                          ),
                          // Switch camera
                          FloatingActionButton(
                            onPressed: _switchCamera,
                            backgroundColor: Colors.blue,
                            child: const Icon(Icons.switch_camera),
                          ),
                        ],
                      ),
                    ),
                    // Status indicator
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _localUserJoined
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color:
                                    _localUserJoined
                                        ? Colors.green
                                        : Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _localUserJoined
                                    ? _remoteUserJoined
                                        ? 'Connected with ${widget.otherUser}'
                                        : 'Waiting for ${widget.otherUser} to join...'
                                    : 'Connecting...',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _errorMessage.isNotEmpty
                          ? const Icon(Icons.error, color: Colors.red, size: 48)
                          : const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _errorMessage = "";
                              _statusMessage = "Retrying...";
                            });
                            _setupAndInitializeAgora();
                          },
                          child: const Text("Retry"),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _endCall,
                          child: const Text("Cancel Call"),
                        ),
                      ],
                    ],
                  ),
                ),
      ),
    );
  }
}

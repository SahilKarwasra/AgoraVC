class CallModel {
  static const String appId = "d26e83ee84ab443093f323cfc8f17299";

  // In production, this should be generated on server
  static const String? tempToken = null;

  static String generateChannelName(String currentUser, String otherUser) {
    // Sort usernames to ensure consistent channel name regardless of who initiates
    final users = [currentUser, otherUser]..sort();
    return "${users[0]}_${users[1]}_call";
  }

  // Get the other user's name
  static String getOtherUser(String currentUser) {
    return currentUser == 'User A' ? 'User B' : 'User A';
  }

  // Call settings
  static const int defaultVideoProfile = 30; // 640x480 @ 30fps
  static const bool enableDualStreamMode = true;

  // Video encodings
  static const int videoBitrate = 1500; // kbps
  static const int videoMinBitrate = 400; // kbps

  // Debug helper function
  static String debugInfo(String currentUser, String otherUser) {
    final channelName = generateChannelName(currentUser, otherUser);

    return """
    Current User: $currentUser
    Other User: $otherUser
    Channel Name: $channelName
    App ID: ${appId.substring(0, 8)}...
    """;
  }
}

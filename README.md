Show two buttons: Login as User A / Login as User B
Save selected user to SharedPreferences
Display logged-in user on the home screen
Integrate Agora RTC SDK
Use hardcoded channel name (e.g., userA_userB_call)
Implement:
Video view for local and remote
End call
Mute/unmute
Switch camera
Handle microphone and camera permissions
Simulate incoming call screen (no FCM)
Button: “Call User B”
If current user is A → trigger fake incoming call screen for B
Incoming Call screen:
Accept → go to video call screen
Decline → return to idle

# Firebase (Firestore/Realtime Database use reflection for model mapping)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Play Core split-install classes referenced by Flutter's deferred-components
# support; not used by this app but safe to silence if absent.
-dontwarn com.google.android.play.core.**

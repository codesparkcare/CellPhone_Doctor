# Ignore missing ProGuard annotation warnings
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
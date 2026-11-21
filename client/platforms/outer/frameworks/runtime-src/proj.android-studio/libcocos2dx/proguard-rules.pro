# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Cocos2d-x specific rules
-keep class org.cocos2dx.** { *; }
-dontwarn org.cocos2dx.**

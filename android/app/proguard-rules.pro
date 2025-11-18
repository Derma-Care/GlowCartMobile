# Razorpay SDK
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Google Pay
-keep class com.google.android.apps.nbu.paisa.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.**

# ProGuard Annotations
-keep @interface proguard.annotation.Keep
-keep @interface proguard.annotation.KeepClassMembers

# General Android rules (if not already present)
-dontwarn android.arch.**
-keep class android.support.** { *; }

-keep class **.zego.** { *; }

-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**


# Fix for Jackson missing JavaBeans annotations
-dontwarn java.beans.**

# Fix for missing DOM classes
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry

# Jackson core fix
-keep class com.fasterxml.jackson.** { *; }

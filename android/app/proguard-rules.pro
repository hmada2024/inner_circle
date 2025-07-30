# قواعد Flutter الافتراضية
-dontwarn io.flutter.embedding.**

# قواعد خاصة بـ Firebase للحفاظ على الكود المطلوب
# Firebase Core
-keep class com.google.firebase.** { *; }
-keep class org.apache.** { *; }
-dontwarn org.apache.**
-dontwarn com.google.common.**
-dontwarn com.google.firebase.auth.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.internal.firebase-auth.** { *; }
-keep class com.google.android.gms.safetynet.** { *; }

# Cloud Firestore
-keep class com.google.firebase.firestore.** { *; }

# مطلوب للحفاظ على أسماء الدوال الأصلية لقنوات الاتصال
-keepnames class * {
    @android.webkit.JavascriptInterface <methods>;
}

# مطلوب من قبل مغلفات JNI الخاصة بـ Flutter
-keepnames class io.flutter.embedding.engine.FlutterJNI
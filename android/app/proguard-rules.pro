# قواعد Flutter الافتراضية
-dontwarn io.flutter.embedding.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# القاعدة الأهم: الحفاظ على MainActivity الخاصة بالتطبيق
-keep class com.innercircle.MainActivity { *; }

# (الأسطر الجديدة هنا) -> قواعد لمنع حذف فئات Google Play
-dontwarn com.google.android.play.core.splitcompat.**
-keep class com.google.android.play.core.splitcompat.** { *; }

# قواعد خاصة بـ Firebase للحفاظ على الكود المطلوب
# Firebase Core & Auth
-keep class com.google.firebase.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepnames class com.google.android.gms.** {*;}
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.auth.**

# Cloud Firestore
-keep class com.google.firebase.firestore.** { *; }

# مطلوب للحفاظ على أسماء الدوال الأصلية لقنوات الاتصال
-keepnames class * {
    @android.webkit.JavascriptInterface <methods>;
}

# مطلوب من قبل مغلفات JNI الخاصة بـ Flutter
-keepnames class io.flutter.embedding.engine.FlutterJNI

# قواعد إضافية لـ Kotlin (مهم جداً)
-dontwarn kotlin.**
-keep class kotlin.Metadata { *; }
// lib/core/utils.dart

import 'package:flutter/material.dart';

// هذه هي الوحدة المركزية الجديدة لإظهار الرسائل للمستخدم
void showCustomSnackBar({
  required BuildContext context,
  required String content,
  bool isError = false,
}) {
  // التأكد من أن السياق لا يزال موجوداً قبل عرض أي شيء
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    // إخفاء أي SnackBar قديم قبل إظهار واحد جديد
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content),
        // تغيير اللون بناءً على نوع الرسالة (خطأ أم نجاح)
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        // جعل مدة العرض أطول
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // شكل أكثر حداثة
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(10.0),
      ),
    );
}

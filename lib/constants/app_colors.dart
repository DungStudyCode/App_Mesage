import 'package:flutter/material.dart';

/// Bộ màu chuẩn (Design System) theo thiết kế
class AppColors {
  // 1. Màu thương hiệu chính (Theo thiết kế)
  static const Color primary = Color(0xFF006AFF);       // Primary: Xanh dương điện
  static const Color secondary = Color(0xFF10B981);     // Secondary: Xanh ngọc lục bảo (Online, thành công)
  static const Color tertiary = Color(0xFFEF4444);      // Tertiary: Đỏ san hô (Thông báo, xóa, quan trọng)
  static const Color neutral = Color(0xFF0F172A);       // Neutral: Đen than chì (Text chính, nút inverted)

  // 2. Màu Pastel & Biến thể nhạt
  static const Color primaryLight = Color(0xFFDAE2FD);  // Xanh nhạt pastel (Ô tìm kiếm, thẻ phụ, tint)
  static const Color secondaryLight = Color(0xFFD1FAE5);// Xanh ngọc nhạt
  static const Color tertiaryLight = Color(0xFFFEE2E2); // Đỏ nhạt
  static const Color neutralLight = Color(0xFFF1F5F9);  // Xám nhạt viền & nền

  // 3. Màu nền & Bề mặt (Background & Surface)
  static const Color background = Color(0xFFF8FAFC);    // Nền app tổng thể
  static const Color surface = Colors.white;            // Nền Card, AppBar
  static const Color searchBar = Color(0xFFDAE2FD);     // Nền ô tìm kiếm

  // 4. Màu chữ (Typography)
  static const Color textPrimary = Color(0xFF0F172A);   // Headline, Body đậm
  static const Color textSecondary = Color(0xFF64748B); // Chữ phụ, mô tả, giờ
  static const Color textHint = Color(0xFF64748B);      // Placeholder tìm kiếm

  // 5. Trạng thái & Bong bóng tin nhắn
  static const Color myMessage = Color(0xFF006AFF);        // Tin nhắn của tôi
  static const Color myMessageText = Colors.white;
  static const Color otherMessage = Color(0xFFDAE2FD);     // Tin nhắn đối phương
  static const Color otherMessageText = Color(0xFF0F172A);

  static const Color online = Color(0xFF10B981);           // Chấm online xanh lá
  static const Color badge = Color(0xFFEF4444);            // Badge thông báo đỏ
  static const Color divider = Color(0xFFE2E8F0);          // Đường kẻ phân cách
}

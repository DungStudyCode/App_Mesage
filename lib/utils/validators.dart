class Validators {
  static bool isEmail(String input) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(input.trim());
  }

  static bool isPhoneNumber(String input) {
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    return phoneRegex.hasMatch(input.trim());
  }

  // Kiểm tra rỗng
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập $fieldName";
    }
    return null;
  }

  // Kiểm tra email hay sđt
  static String? account(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập email hoặc sđt: ";
    }
    final text = value.trim();
    if (!isEmail(text) && !isPhoneNumber(text)) {
      return "Vui lòng nhập đúng định dạng email hoặc sđt";
    }
    return null;
  }

  // Kiểm tra mật khẩu
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (value.length < 6) {
      return "Mật khẩu phải có ít nhất 6 chữ";
    }
    return null;
  }

  //xác nhận mật khẩu
  static String? confirmPassoword(String? value, String originalPassword) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (value != originalPassword) {
      return "Mật khẩu không khớp";
    }

    return null;
  }
}

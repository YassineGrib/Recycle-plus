class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    
    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم';
    }
    
    if (value.length < 2) {
      return 'الاسم يجب أن يكون أكثر من حرفين';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }
    
    // Basic phone validation - can be enhanced based on Lebanese phone format
    if (value.length < 8) {
      return 'رقم الهاتف غير صحيح';
    }
    
    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الموقع';
    }
    
    if (value.length < 3) {
      return 'الموقع يجب أن يكون أكثر من 3 أحرف';
    }
    
    return null;
  }

  // Ad title validation
  static String? validateAdTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال عنوان الإعلان';
    }
    
    if (value.length < 10) {
      return 'العنوان يجب أن يكون 10 أحرف على الأقل';
    }
    
    if (value.length > 100) {
      return 'العنوان يجب أن يكون أقل من 100 حرف';
    }
    
    return null;
  }

  // Ad description validation
  static String? validateAdDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال وصف المادة';
    }
    
    if (value.length < 20) {
      return 'الوصف يجب أن يكون 20 حرف على الأقل';
    }
    
    if (value.length > 500) {
      return 'الوصف يجب أن يكون أقل من 500 حرف';
    }
    
    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الكمية';
    }
    
    final quantity = double.tryParse(value);
    if (quantity == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    
    if (quantity <= 0) {
      return 'الكمية يجب أن تكون أكبر من صفر';
    }
    
    if (quantity > 10000) {
      return 'الكمية كبيرة جداً';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال السعر';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    
    if (price <= 0) {
      return 'السعر يجب أن يكون أكبر من صفر';
    }
    
    if (price > 1000) {
      return 'السعر مرتفع جداً';
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName يجب أن يكون رقماً';
    }
    
    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericValidation = validateNumeric(value, fieldName);
    if (numericValidation != null) return numericValidation;
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName يجب أن يكون أكبر من صفر';
    }
    
    return null;
  }

  // Length validation
  static String? validateLength(String? value, String fieldName, int minLength, [int? maxLength]) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    if (value.length < minLength) {
      return '$fieldName يجب أن يكون $minLength أحرف على الأقل';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName يجب أن يكون أقل من $maxLength حرف';
    }
    
    return null;
  }
}

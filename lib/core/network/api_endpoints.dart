class ApiEndpoints {
  ApiEndpoints._();
  static const baseUrl = 'http://3.108.80.130:5001/api';
  static const imageBaseUrl = 'http://3.108.80.130:5001/public';
  static const login = '/user/auth/login';
  static const verifyOtp = '/user/auth/verify_otp';
  static const pujaHome = '/user/dashboard/getPujaHomePageData';
  static const puja = '/user/puja/';
  static const createPujaOrder = '/user/payment/create_puja_order';
  static const transactions = '/user/payment/puja_transactions';
  static const transactionDetails = '/user/payment/puja_transaction_details';
  static const submitReview = '/user/pujaReview/submit';
  static const profile = '/user/auth/profile';
  static const updateProfile = '/user/auth/update_profile';
  static const deleteProfile = '/user/auth/delete_profile';
  static String image(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$imageBaseUrl/${path.startsWith('/') ? path.substring(1) : path}';
  }
}

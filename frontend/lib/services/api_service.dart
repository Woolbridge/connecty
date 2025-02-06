import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api', // Change as needed for production
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  String? authToken;

  /// Sets the token in the instance variable and in Dio's headers.
  void setAuthToken(String token) {
    authToken = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
    print('Auth token set: $token');
  }

  /// Retrieves the token from SharedPreferences.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  Future<Response> login(String email, String password) async {
    try {
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<void> initializeAuth(Dio dio) async {
    final token = await getToken();
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
      print('Token loaded: $token');
    }
  }

  Future<Response> register(String name, String email, String password) async {
    try {
      final response = await dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Save token in SharedPreferences.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<Response> getProfile() async {
    try {
      return await dio.get('/profile');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    try {
      return await dio.post('/update-profile', data: data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> uploadAvatar(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
      });
      return await dio.post('/profile/avatar', data: formData);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> getNearbyUsers(double radius) async {
    // Retrieve token either from the instance or from SharedPreferences.
    final token = authToken ?? await getToken();
    if (token == null || token.isEmpty) {
      throw Exception("No auth token found. Please sign in.");
    }
    setAuthToken(token); // Update headers with current token.
    try {
      return await dio.get('/nearby-users?radius=$radius');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> updateLocation(double lat, double lng) async {
    final token = authToken ?? await getToken();
    if (token == null || token.isEmpty) {
      throw Exception("No auth token found. Please sign in.");
    }
    setAuthToken(token);
    try {
      return await dio.post('/update-location', data: {
        'latitude': lat,
        'longitude': lng,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> getMessages(int userId) async {
    try {
      return await dio.get('/messages/$userId');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> sendMessage(int receiverId, String messageText) async {
    try {
      return await dio.post('/messages', data: {
        'receiver_id': receiverId,
        'message_text': messageText,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> sendTyping(int receiverId, bool isTyping) async {
    try {
      return await dio.post('/typing', data: {
        'receiver_id': receiverId,
        'is_typing': isTyping,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> markAsRead(int messageId) async {
    try {
      return await dio.put('/messages/$messageId/read');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> makePurchase(double amount, String type) async {
    try {
      return await dio.post('/purchase', data: {
        'amount': amount,
        'transaction_type': type,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Post-related methods
  Future<Response> getPosts(int userId) async {
    try {
      return await dio.get('/posts/$userId');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> createPost(Map<String, dynamic> data) async {
    try {
      return await dio.post('/posts', data: data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      print('Error: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
    } else {
      print('Connection error: ${e.message}');
    }
  }
}

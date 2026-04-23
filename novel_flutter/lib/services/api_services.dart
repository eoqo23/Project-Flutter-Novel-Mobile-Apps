import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/novel.dart';
import '../models/user.dart';
import '../models/chapter.dart';
import 'dart:io';
import '../models/genre.dart';


class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  /// =============================
  /// GET TOKEN (AUTO)
  /// =============================
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  /// =============================
  /// AUTH
  /// =============================
  static Future<User> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      final userData = data['user'];

      return User(
        token: data['token'] ?? '',
        role: userData['role'] ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        id: userData['id'].toString(),
      );
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  /// =============================
  /// PUBLIC NOVELS
  /// =============================
  static Future<List<Novel>> getNovels({String search = ""}) async {
    final uri = Uri.parse("$baseUrl/public/novels").replace(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
      },
    );

    print ("Memanggil URL: $uri"); 

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data'] as List;

      return data.map((item) => Novel.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load novels");
    }
  }

  /// =============================
  /// CREATE NOVEL
  /// =============================

static Future<void> createNovel({
  required String title,
  required String description,
  required List<int> genres,
  XFile? image,
}) async {
  final token = await getToken();

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/novels'),
  );

  request.headers['Authorization'] = 'Bearer $token';

  request.fields['title'] = title;
  request.fields['description'] = description;

  // GENRES
  for (var g in genres) {
    request.fields['genres[]'] = g.toString();
  }

  // IMAGE
  if (image != null) {
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'cover',
          bytes,
          filename: image.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'cover',
          image.path,
        ),
      );
    }
  }

  final response = await request.send();

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Gagal create novel");
  }
}
  /// =============================
  /// GET MY NOVELS
  /// =============================
static Future<List<Novel>> getMyNovels() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse("$baseUrl/my-novels"),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    final List data = jsonData['data']; // 🔥 ambil arraynya

    return data.map((e) => Novel.fromJson(e)).toList();
  } else {
    throw Exception(response.body);
  }
}

  /// =============================
  /// DELETE NOVEL
  /// =============================
  static Future<void> deleteNovel(int id) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/novels/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Delete failed: ${response.body}");
    }
  }

  /// =============================
  /// UPDATE NOVEL
  /// =============================
static Future<void> updateNovelFull({
  required int id,
  required String title,
  required String description,
  required List<int> genres,
  XFile? image,
}) async {
  final token = await getToken();

  var request = http.MultipartRequest(
    'POST', // ⚠️ Laravel biasanya pakai POST + _method PUT
    Uri.parse('$baseUrl/novels/$id'),
  );

  request.headers['Authorization'] = 'Bearer $token';

  // 🔥 METHOD SPOOFING (WAJIB DI LARAVEL)
  request.fields['_method'] = 'PUT';

  request.fields['title'] = title;
  request.fields['description'] = description;

  // GENRES
  for (var g in genres) {
    request.fields['genres[]'] = g.toString();
  }

  // IMAGE
  if (image != null) {
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'cover',
          bytes,
          filename: image.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'cover',
          image.path,
        ),
      );
    }
  }

  final response = await request.send();

  if (response.statusCode != 200) {
    throw Exception("Update gagal");
  }
}
/// =============================
/// GET SINGLE CHAPTER (FIX FINAL)
/// =============================
static Future<Chapter> getChapter(int chapterId) async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/chapters/$chapterId'),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print("TOKEN: $token");
  print("GET CHAPTER STATUS: ${response.statusCode}");
  print("GET CHAPTER BODY: ${response.body}");

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    // ✅ ambil data & navigation
    final data = decoded['data'];
    final nav = decoded['navigation']; // 🔥 FIX (bukan 'nav')

    if (data == null) {
      throw Exception("Chapter kosong (data null)");
    }

    // ✅ gabung navigation ke data
    if (nav != null) {
      data['next_id'] = nav['next_id'];
      data['prev_id'] = nav['prev_id'];
    }

    return Chapter.fromJson(data);
  } else {
    throw Exception('Failed load chapter: ${response.body}');
  }
}

/// =============================
/// LIKE CHAPTER
/// =============================
static Future<void> likeChapter(int chapterId) async {
  final token = await getToken();

  final response = await http.post(
    Uri.parse('$baseUrl/chapters/$chapterId/like'),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Like failed');
  }
}

/// =============================
/// GET COMMENTS
/// =============================
static Future<List<dynamic>> getComments(int chapterId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/chapters/$chapterId/comments'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  } else {
    throw Exception('Failed load comments');
  }
}

/// =============================
/// ADD COMMENT
/// =============================
static Future<void> addComment(int chapterId, String content) async {
  final token = await getToken();

  final response = await http.post(
    Uri.parse('$baseUrl/chapters/$chapterId/comments'),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
    body: {
      "content": content,
    },
  );

  if (response.statusCode != 201) {
    throw Exception('Comment failed');
  }
}

  /// =============================
  /// CHAPTERS
  /// =============================
  static Future<List<Chapter>> getChapters(int novelId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/novels/$novelId/chapters'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map && data.containsKey('data')) {
        return List<Chapter>.from(
          data['data'].map((e) => Chapter.fromJson(e)),
        );
      }

      return List<Chapter>.from(
        data.map((e) => Chapter.fromJson(e)),
      );
    } else {
      throw Exception('Failed load chapters: ${response.body}');
    }
  }


  static Future<List<Chapter>> getChapterWithToken(int novelId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/novels/$novelId/chapters'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map && data.containsKey('data')) {
        return List<Chapter>.from(
          data['data'].map((e) => Chapter.fromJson(e)),
        );
      }

      return List<Chapter>.from(
        data.map((e) => Chapter.fromJson(e)),
      );
    } else {
      throw Exception('Failed load chapters: ${response.body}');
    }
  }


  /// =============================
  /// CREATE CHAPTER
  /// =============================
static Future<void> createChapter(
  int novelId,
  String title,
  String content,
  int chapterNumber,
  String token,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/chapters"), // <- perhatikan /chapters saja
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "novel_id": novelId, // wajib kirim novel_id
      "title": title,
      "content": content,
      "chapter_number": chapterNumber,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception("Create chapter failed: ${response.body}");
  }
}

  /// =============================
  /// UPDATE CHAPTER
  /// =============================
  static Future<void> updateChapter(
    int chapterId,
    String title,
    String content,
    int chapterNumber,
    String token,
    int novelId,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/chapters/$chapterId"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "novel_id": novelId, // wajib kirim novel_id
        "title": title,
        "content": content,
        "chapter_number": chapterNumber,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Update chapter failed: ${response.body}");
    }
  }


  /// =============================
  /// DELETE CHAPTER
  /// =============================
  static Future<void> deleteChapterWithToken(
    int chapterId,
    String token,
  ) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/chapters/$chapterId"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Delete chapter failed: ${response.body}");
    }
  }

  

  // ================= ADMIN GET ALL =================
static Future<List<Novel>> getAllNovelsAdmin() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse("$baseUrl/admin/novels"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  final jsonData = jsonDecode(response.body);
  final List data = jsonData['data'];

  return data.map((e) => Novel.fromJson(e)).toList();
}

// ================= UPDATE STATUS =================
static Future<void> updateNovelStatus(int id, String status) async {
  final token = await getToken();

  final response = await http.put(
    Uri.parse("$baseUrl/admin/novels/$id/status"),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
    body: {
      "status": status,
    },
  );

  print(response.body); // 🔥 DEBUG

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

// ================= DELETE =================
static Future<void> deleteNovelAdmin(int id) async {
  final token = await getToken();

  final response = await http.delete(
    Uri.parse("$baseUrl/admin/novels/$id"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

/// =============================
/// GET GENRES
/// =============================
static Future<List<dynamic>> getGenres() async {
  final response = await http.get(
    Uri.parse('$baseUrl/genres'),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    // ✅ karena response langsung array
    return decoded; 
  } else {
    throw Exception("Failed load genres");
  }
}

static Future<User?> register(
  String name,
  String email,
  String password,
  String role,
) async {

  final response = await http.post(
    Uri.parse("$baseUrl/register"),
    headers: {
      "Accept": "application/json",
    },
    body: {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
    },
  );

  if (response.statusCode == 200) {

    final data = jsonDecode(response.body);

    return User.fromJson({
      "token": data['token'],
      "role": data['role'],
      "name": data['name'],
      "email": data['email'],
      "id": data['id'].toString()
    });
  }

  return null;
}

static Future<void> addFavorite(int novelId) async {
  final response = await http.post(
    Uri.parse("$baseUrl/favorites"),
    headers: {
      "Authorization": "Bearer ${await getToken()}",
      "Content-Type": "application/json", // 🔥 WAJIB
    },
    body: jsonEncode({
      "novel_id": novelId,
    }),
  );

  print("ADD FAVORITE: ${response.statusCode}");
  print("ADD FAVORITE BODY: ${response.body}");
}

static Future<void> removeFavorite(int novelId) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/favorites/$novelId"),
    headers: {
      "Authorization": "Bearer ${await getToken()}",
    },
  );

  print("REMOVE FAVORITE: ${response.body}");
}

static Future<List<Novel>> getFavorites() async {
  final response = await http.get(
    Uri.parse("$baseUrl/favorites"),
    headers: {
      "Authorization": "Bearer ${await getToken()}",
    },
  );

  final data = jsonDecode(response.body);

  return (data as List)
      .map((e) => Novel.fromJson(e['novel'])) // 🔥 karena pakai with('novel')
      .toList();
}

// =============================
// Bookmark Chapter
// =============================

static Future<List<dynamic>> getBookmarks() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse("$baseUrl/bookmarks"),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load bookmarks");
  }
}

static Future<void> addBookmark(int novelId, int chapterId) async {
  final token = await getToken();

  final response = await http.post(
    Uri.parse("$baseUrl/bookmarks"),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json", // 🔥 PENTING
    },
    body: jsonEncode({
      "novel_id": novelId,
      "chapter_id": chapterId,
    }),
  );

  if (response.statusCode != 200) {
    print(response.body); // 🔥 DEBUG
    throw Exception("Failed to add bookmark");
  }
}

static Future<void> removeBookmark(int chapterId) async {
  final token = await getToken();

  final response = await http.delete(
    Uri.parse("$baseUrl/bookmarks/$chapterId"),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to delete bookmark");
  }
}
}
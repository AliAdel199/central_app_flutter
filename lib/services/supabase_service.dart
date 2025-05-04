import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // تسجيل الدخول
  static Future<AuthResponse> signIn({required String email, required String password}) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // تسجيل الخروج
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // استعلام جميع المدارس
  static Future<List<Map<String, dynamic>>> getSchools() async {
    final response = await client.from('schools').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // إضافة مدرسة جديدة
  static Future<void> addSchool(Map<String, dynamic> data) async {
    await client.from('schools').insert(data);
  }

  // تحديث مدرسة
  static Future<void> updateSchool(int id, Map<String, dynamic> data) async {
    await client.from('schools').update(data).eq('id', id);
  }

  // حذف مدرسة
  static Future<void> deleteSchool(int id) async {
    await client.from('schools').delete().eq('id', id);
  }
}

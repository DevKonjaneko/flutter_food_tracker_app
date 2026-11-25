import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'food_tracker_tb';
  static const String _bucketName = 'food_tracker_bk';

  // ดึงข้อมูลอาหารทั้งหมด
  static Future<List<Food>> getAllFoods() async {
    final data = await _supabase
        .from(_tableName)
        .select()
        .order('foodDate', ascending: false);
    return (data as List).map((item) => Food.fromJson(item)).toList();
  }

  // เพิ่มข้อมูลอาหารใหม่
  static Future<void> insertFood(Food food) async {
    final data = food.toJson();
    data.remove('id');
    await _supabase.from(_tableName).insert(data);
  }

  // แก้ไขข้อมูลอาหาร
  static Future<void> updateFood(Food food) async {
    if (food.id == null) return;
    await _supabase
        .from(_tableName)
        .update(food.toJson())
        .eq('id', food.id!);
  }

  // ลบข้อมูลอาหาร
  static Future<void> deleteFood(String id) async {
    await _supabase.from(_tableName).delete().eq('id', id);
  }

  // อัปโหลดรูปภาพเข้า food_tracker_bk
  static Future<String?> uploadImage(XFile imageFile) async {
    final fileName = 'food_${DateTime.now().millisecondsSinceEpoch}.jpg';
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      await _supabase.storage.from(_bucketName).uploadBinary(fileName, bytes);
    } else {
      final file = File(imageFile.path);
      await _supabase.storage.from(_bucketName).upload(fileName, file);
    }
    return _supabase.storage.from(_bucketName).getPublicUrl(fileName);
  }

  // ลบรูปภาพเก่าออกจาก food_tracker_bk
  static Future<void> deleteImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    try {
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      await _supabase.storage.from(_bucketName).remove([fileName]);
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}
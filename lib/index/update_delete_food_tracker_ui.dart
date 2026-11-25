import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/food.dart';
import '../services/supabase_service.dart';

class UpdateDeleteFoodTrackerUi extends StatefulWidget {
  final Food food;
  const UpdateDeleteFoodTrackerUi({super.key, required this.food});

  @override
  State<UpdateDeleteFoodTrackerUi> createState() =>
      _UpdateDeleteFoodTrackerUiState();
}

class _UpdateDeleteFoodTrackerUiState extends State<UpdateDeleteFoodTrackerUi> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _personController;
  late TextEditingController _dateController;

  final List<String> _meals = ['เช้า', 'กลางวัน', 'เย็น', 'ว่าง'];
  late String _selectedMeal;
  XFile? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food.foodName ?? '');
    _priceController = TextEditingController(
      text: widget.food.foodPrice?.toString() ?? '',
    );
    _personController = TextEditingController(
      text: widget.food.foodPerson?.toString() ?? '',
    );
    _dateController = TextEditingController(text: widget.food.foodDate ?? '');
    _selectedMeal = _meals.contains(widget.food.foodMeal)
        ? widget.food.foodMeal!
        : 'เช้า';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _personController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _selectDate() async {
    final initial = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String? imageUrl = widget.food.foodImageUrl;

      if (_pickedImage != null) {
        final newUrl = await SupabaseService.uploadImage(_pickedImage!);
        if (widget.food.foodImageUrl != null &&
            widget.food.foodImageUrl!.isNotEmpty) {
          await SupabaseService.deleteImage(widget.food.foodImageUrl);
        }
        imageUrl = newUrl;
      }

      final updatedFood = Food(
        id: widget.food.id,
        foodName: _nameController.text.trim(),
        foodMeal: _selectedMeal,
        foodPrice: double.tryParse(_priceController.text.trim()),
        foodPerson: int.tryParse(_personController.text.trim()),
        foodDate: _dateController.text.trim(),
        foodImageUrl: imageUrl,
      );

      await SupabaseService.updateFood(updatedFood);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกแก้ไขเรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการแก้ไข: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteFood() async {
    if (widget.food.id == null) return;

    setState(() => _isLoading = true);
    try {
      if (widget.food.foodImageUrl != null &&
          widget.food.foodImageUrl!.isNotEmpty) {
        await SupabaseService.deleteImage(widget.food.foodImageUrl);
      }

      await SupabaseService.deleteFood(widget.food.id!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการลบ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF04336),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Food Tracker (แก้ไข/ลบ)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('กินอะไร', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'กรุณากรอกชื่ออาหาร' : null,
              ),
              const SizedBox(height: 16),
              const Text('กินมื้อไหน', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: _meals.map((meal) {
                  final isSelected = _selectedMeal == meal;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? const Color(0xFF43A047)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          setState(() => _selectedMeal = meal);
                        },
                        child: Text(meal, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('กินไปเท่าไหร่', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'กรุณากรอกราคา';
                  }
                  if (double.tryParse(val.trim()) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('กินกันกี่คน', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _personController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'กรุณากรอกจำนวนคน';
                  }
                  if (int.tryParse(val.trim()) == null) {
                    return 'กรุณากรอกจำนวนเต็ม';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('กินไปวันไหน', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'กรุณาเลือกวันที่' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _updateFood,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'บันทึกแก้ไข',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF04336),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _deleteFood,
                child: const Text(
                  'ลบข้อมูล',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: kIsWeb
            ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
            : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
      );
    }
    if (widget.food.foodImageUrl != null &&
        widget.food.foodImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          widget.food.foodImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.camera_alt_outlined, size: 65, color: Colors.grey),
        ),
      );
    }
    return const Icon(Icons.camera_alt_outlined, size: 65, color: Colors.grey);
  }
}
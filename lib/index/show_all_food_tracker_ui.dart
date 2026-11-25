import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/supabase_service.dart';
import 'add_food_tracker_ui.dart';
import 'update_delete_food_tracker_ui.dart';

class ShowAllFoodTrackerUi extends StatefulWidget {
  const ShowAllFoodTrackerUi({super.key});

  @override
  State<ShowAllFoodTrackerUi> createState() => _ShowAllFoodTrackerUiState();
}

class _ShowAllFoodTrackerUiState extends State<ShowAllFoodTrackerUi> {
  List<Food> _foodList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getAllFoods();
      if (!mounted) return;
      setState(() {
        _foodList = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ดึงข้อมูลไม่สำเร็จ: $e'),
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
        centerTitle: true,
        title: const Text(
          'Food Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.fastfood_rounded,
            size: 110,
            color: Color(0xFFF04336),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF04336),
                    ),
                  )
                : _foodList.isEmpty
                    ? const Center(
                        child: Text(
                          'ยังไม่มีรายการอาหาร',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchFoods,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _foodList.length,
                          itemBuilder: (context, index) {
                            final food = _foodList[index];
                            final isEven = index % 2 == 0;
                            return Card(
                              elevation: 0,
                              color: isEven
                                  ? const Color(0xFFE6F4EA)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (food.foodImageUrl != null &&
                                          food.foodImageUrl!.isNotEmpty)
                                      ? Image.network(
                                          food.foodImageUrl!,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _defaultFoodIcon(),
                                        )
                                      : _defaultFoodIcon(),
                                ),
                                title: Text(
                                  'กิน: ${food.foodName ?? "-"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'วันที่: ${food.foodDate ?? "-"} มื้อ: ${food.foodMeal ?? "-"}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFFF04336),
                                ),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateDeleteFoodTrackerUi(food: food),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchFoods();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF04336),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFoodTrackerUi(),
            ),
          );
          if (result == true) {
            _fetchFoods();
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _defaultFoodIcon() {
    return Container(
      width: 55,
      height: 55,
      color: Colors.orange.shade100,
      child: const Icon(Icons.restaurant, color: Color(0xFFF04336)),
    );
  }
}
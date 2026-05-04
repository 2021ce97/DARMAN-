import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../theme/app_colors.dart';

class Medicine {
  final String id;
  final String name;
  final String category;
  final String manufacturer;
  final double price;
  final String dosage;
  final bool requiresPrescription;
  final bool inStock;
  final String imageEmoji;

  const Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.manufacturer,
    required this.price,
    required this.dosage,
    this.requiresPrescription = false,
    this.inStock = true,
    this.imageEmoji = '💊',
  });
}

final medicinesProvider = Provider<List<Medicine>>((ref) => [
  Medicine(id: 'm1', name: 'Paracetamol', category: 'Pain Relief', manufacturer: 'Afghan Pharma', price: 50, dosage: '500mg × 20 tablets'),
  Medicine(id: 'm2', name: 'Amoxicillin', category: 'Antibiotics', manufacturer: 'Kabul Pharma', price: 180, dosage: '500mg × 14 capsules', requiresPrescription: true),
  Medicine(id: 'm3', name: 'Vitamin C', category: 'Vitamins', manufacturer: 'HealthPlus', price: 120, dosage: '1000mg × 30 tablets', imageEmoji: '🍊'),
  Medicine(id: 'm4', name: 'Omeprazole', category: 'Digestive', manufacturer: 'Afghan Pharma', price: 200, dosage: '20mg × 14 capsules', requiresPrescription: true),
  Medicine(id: 'm5', name: 'Cetirizine', category: 'Allergy', manufacturer: 'Kabul Pharma', price: 80, dosage: '10mg × 10 tablets'),
  Medicine(id: 'm6', name: 'Metformin', category: 'Diabetes', manufacturer: 'HealthPlus', price: 150, dosage: '500mg × 30 tablets', requiresPrescription: true),
  Medicine(id: 'm7', name: 'Ibuprofen', category: 'Pain Relief', manufacturer: 'Afghan Pharma', price: 90, dosage: '400mg × 20 tablets'),
  Medicine(id: 'm8', name: 'Vitamin D3', category: 'Vitamins', manufacturer: 'HealthPlus', price: 250, dosage: '1000 IU × 60 capsules', imageEmoji: '☀️'),
]);

final cartProvider = StateProvider<Map<String, int>>((ref) => {});
final pharmacySearchProvider = StateProvider<String>((ref) => '');
final selectedMedicineCategoryProvider = StateProvider<String>((ref) => 'All');

class PharmacyScreen extends ConsumerWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicinesProvider);
    final cart = ref.watch(cartProvider);
    final search = ref.watch(pharmacySearchProvider);
    final selectedCat = ref.watch(selectedMedicineCategoryProvider);

    final categories = ['All', ...{...medicines.map((m) => m.category)}];
    final filtered = medicines.where((m) {
      final matchCat = selectedCat == 'All' || m.category == selectedCat;
      final matchSearch = search.isEmpty || m.name.toLowerCase().contains(search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    final cartCount = cart.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pharmacy'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => _showCart(context, ref),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => ref.read(pharmacySearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Categories
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = selectedCat == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => ref.read(selectedMedicineCategoryProvider.notifier).state = cat,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Medicines grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _MedicineCard(
                medicine: filtered[index],
                quantity: cart[filtered[index].id] ?? 0,
                onAdd: () {
                  final updated = Map<String, int>.from(cart);
                  updated[filtered[index].id] = (updated[filtered[index].id] ?? 0) + 1;
                  ref.read(cartProvider.notifier).state = updated;
                },
                onRemove: () {
                  final updated = Map<String, int>.from(cart);
                  final current = updated[filtered[index].id] ?? 0;
                  if (current <= 1) {
                    updated.remove(filtered[index].id);
                  } else {
                    updated[filtered[index].id] = current - 1;
                  }
                  ref.read(cartProvider.notifier).state = updated;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCart(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider);
    final medicines = ref.read(medicinesProvider);

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    final cartItems = cart.entries.map((e) {
      final med = medicines.firstWhere((m) => m.id == e.key);
      return (medicine: med, quantity: e.value);
    }).toList();

    final total = cartItems.fold(0.0, (sum, item) => sum + item.medicine.price * item.quantity);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(item.medicine.imageEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.medicine.name)),
                  Text('×${item.quantity}', style: const TextStyle(color: AppColors.textHint)),
                  const SizedBox(width: 8),
                  Text('${(item.medicine.price * item.quantity).toInt()} AFN', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${total.toInt()} AFN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(cartProvider.notifier).state = {};
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Order placed successfully!'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Place Order', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MedicineCard({
    required this.medicine,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(medicine.imageEmoji, style: const TextStyle(fontSize: 28))),
            ),
          ),
          const SizedBox(height: 10),
          Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(medicine.dosage, style: const TextStyle(color: AppColors.textHint, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (medicine.requiresPrescription)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('Rx Required', style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.w600)),
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${medicine.price.toInt()} AFN', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
              quantity == 0
                  ? GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    )
                  : Row(
                      children: [
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.remove, color: AppColors.primary, size: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}


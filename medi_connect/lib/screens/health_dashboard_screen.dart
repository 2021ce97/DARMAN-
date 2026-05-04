import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import '../models/health_metric_model.dart';
import '../theme/app_colors.dart';

// Mock data provider
final healthMetricsProvider = StateProvider<List<HealthMetric>>((ref) {
  final now = DateTime.now();
  return [
    HealthMetric(id: '1', userId: 'u1', type: MetricType.bloodPressure, value: 120, unit: 'mmHg', recordedAt: now.subtract(const Duration(hours: 2))),
    HealthMetric(id: '2', userId: 'u1', type: MetricType.heartRate, value: 72, unit: 'bpm', recordedAt: now.subtract(const Duration(hours: 3))),
    HealthMetric(id: '3', userId: 'u1', type: MetricType.bloodSugar, value: 95, unit: 'mg/dL', recordedAt: now.subtract(const Duration(days: 1))),
    HealthMetric(id: '4', userId: 'u1', type: MetricType.weight, value: 70, unit: 'kg', recordedAt: now.subtract(const Duration(days: 2))),
    HealthMetric(id: '5', userId: 'u1', type: MetricType.oxygenSaturation, value: 98, unit: '%', recordedAt: now.subtract(const Duration(hours: 1))),
    HealthMetric(id: '6', userId: 'u1', type: MetricType.temperature, value: 36.6, unit: '°C', recordedAt: now.subtract(const Duration(hours: 4))),
  ];
});

class HealthDashboardScreen extends ConsumerWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(healthMetricsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/add_health_metric'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score Card
            _buildHealthScoreCard(),
            const SizedBox(height: 20),

            // Metrics Grid
            Text('Today\'s Vitals', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: metrics.length,
              itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
            ),
            const SizedBox(height: 20),

            // Trend Chart (simplified)
            _buildTrendSection(context),
            const SizedBox(height: 20),

            // Medication Reminders
            _buildMedicationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Health Score', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('87', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const Text('Good — Keep it up!', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 0.87,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const Text('87%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Trends', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 12),
          // Simple bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final entry in {'Mon': 0.6, 'Tue': 0.8, 'Wed': 0.7, 'Thu': 0.9, 'Fri': 0.75, 'Sat': 0.85, 'Sun': 0.87}.entries)
                _MiniBar(day: entry.key, value: entry.value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Medications', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.push('/medication_reminders'),
                child: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MedicationReminder(name: 'Paracetamol 500mg', time: '8:00 AM', taken: true),
          _MedicationReminder(name: 'Vitamin D3 1000IU', time: '12:00 PM', taken: false),
          _MedicationReminder(name: 'Amlodipine 5mg', time: '9:00 PM', taken: false),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final HealthMetric metric;
  const _MetricCard({required this.metric});

  Color get _statusColor {
    // Simplified status logic
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.type.emoji, style: const TextStyle(fontSize: 22)),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${metric.value.toStringAsFixed(metric.value.truncateToDouble() == metric.value ? 0 : 1)} ${metric.unit}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(metric.type.label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String day;
  final double value;
  const _MiniBar({required this.day, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 60 * value,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3 + value * 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ],
    );
  }
}

class _MedicationReminder extends StatelessWidget {
  final String name;
  final String time;
  final bool taken;
  const _MedicationReminder({required this.name, required this.time, required this.taken});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: taken ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              taken ? Icons.check_circle_rounded : Icons.medication_rounded,
              color: taken ? Colors.green : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: taken ? AppColors.textHint : AppColors.textPrimary)),
                Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          if (!taken)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: const Text('Take', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}


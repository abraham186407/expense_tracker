import 'dart:math';
import 'package:expense_tracker/expense.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  List<ExpenseBucket> get buckets {
    return [
      ExpenseBucket.forCategory(expenses, Category.food),
      ExpenseBucket.forCategory(expenses, Category.leisure),
      ExpenseBucket.forCategory(expenses, Category.travel),
      ExpenseBucket.forCategory(expenses, Category.work),
    ];
  }

  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
              Theme.of(context).colorScheme.primary.withOpacity(0.0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text('No expenses yet'),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.primary.withOpacity(0.0)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: CustomPaint(
              size: const Size(120, 120),
              painter: PieChartPainter(buckets, totalExpenses),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildLegendItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLegendItems(BuildContext context) {
    List<Widget> items = [];
    
    for (final bucket in buckets) {
      if (bucket.totalExpenses > 0) {
        final amount = bucket.totalExpenses;
        final percentage = (amount / totalExpenses) * 100;
        final categoryName = bucket.category.name;
        final amountStr = amount.toStringAsFixed(0);
        final percentageStr = percentage.toStringAsFixed(1);
        
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(bucket.category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$categoryName \$$amountStr ($percentageStr%)',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return items;
  }

  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.food:
        return Colors.red;
      case Category.leisure:
        return Colors.blue;
      case Category.travel:
        return Colors.green;
      case Category.work:
        return Colors.orange;
    }
  }
}

class PieChartPainter extends CustomPainter {
  PieChartPainter(this.buckets, this.totalExpenses);

  final List<ExpenseBucket> buckets;
  final double totalExpenses;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalExpenses == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    
    double startAngle = -pi / 2; 

    for (final bucket in buckets) {
      if (bucket.totalExpenses > 0) {
        final sweepAngle = (bucket.totalExpenses / totalExpenses) * 2 * pi;
        
        final paint = Paint()
          ..color = _getCategoryColor(bucket.category)
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );

        startAngle += sweepAngle;
      }
    }
  }

  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.food:
        return Colors.red;
      case Category.leisure:
        return Colors.blue;
      case Category.travel:
        return Colors.green;
      case Category.work:
        return Colors.orange;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
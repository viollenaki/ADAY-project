import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_finance/database/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>> _reportsFuture;
  List<String> selectedCategories = [];
  List<String> allCategories = []; // To hold all available categories
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedType = 'expense'; // Default to 'expense'
  String? selectedCategory; // Track the selected category for detailed view

  @override
  void initState() {
    super.initState();
    _reportsFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    try {
      final db = await _dbHelper.database;

      // Build the query based on filters
      String whereClause = "type = ?";
      List<dynamic> whereArgs = [selectedType];

      if (selectedCategories.isNotEmpty) {
        whereClause +=
        " AND category IN (${List.filled(selectedCategories.length, '?').join(',')})";
        whereArgs.addAll(selectedCategories);
      }

      if (selectedStartDate != null && selectedEndDate != null) {
        whereClause += " AND date BETWEEN ? AND ?";
        whereArgs.add(selectedStartDate!.toIso8601String().substring(0, 10));
        whereArgs.add(selectedEndDate!.toIso8601String().substring(0, 10));
      }

      final transactions = await db.query('transactions',
          where: whereClause, whereArgs: whereArgs);

      Map<String, double> categoryData = {};
      Map<String, double> monthlyData = {};

      // Collecting all unique categories for filtering
      allCategories.clear();
      for (var transaction in transactions) {
        String category = transaction['category'] as String;
        if (!allCategories.contains(category)) {
          allCategories.add(category);
        }
      }

      // Filtered data for charts
      for (var transaction in transactions) {
        String category = transaction['category'] as String;
        double amount = (transaction['amount'] as num).toDouble();
        String dateString = transaction['date'] as String;

        if (dateString.length >= 7) {
          String month = dateString.substring(0, 7);
          if (selectedCategories.isEmpty ||
              selectedCategories.contains(category)) {
            categoryData[category] = (categoryData[category] ?? 0) + amount;
          }
          monthlyData[month] = (monthlyData[month] ?? 0) + amount;
        }
      }

      return {
        "categorySpending": categoryData,
        "monthlySpending": monthlyData,
      };
    } catch (e) {
      throw Exception("Failed to load data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reports & Charts",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load data: ${snapshot.error}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final categorySpending =
          snapshot.data!["categorySpending"] as Map<String, double>;
          final monthlySpending =
          snapshot.data!["monthlySpending"] as Map<String, double>;

          // Calculate total amount for percentages
          double totalAmount = 0;
          categorySpending.forEach((key, value) {
            totalAmount += value;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(),
                const SizedBox(height: 20),
                _buildChartCard(
                  title: selectedType == 'income'
                      ? "Income Overview"
                      : "Expense Overview",
                  child: categorySpending.isEmpty
                      ? _buildNoDataWidget()
                      : Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: _getOrderedPieChartSections(
                                categorySpending, totalAmount),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            pieTouchData: PieTouchData(
                              enabled: true,
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                // Проверяем, было ли нажатие завершено
                                if (event is FlTapUpEvent ||
                                    event is FlPanEndEvent ||
                                    event is FlLongPressEnd) {
                                  if (pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection ==
                                          null) {
                                    setState(() {
                                      selectedCategory = null;
                                    });
                                    return;
                                  }

                                  final touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;

                                  if (touchedIndex >= 0 &&
                                      touchedIndex <
                                          _getOrderedCategories(
                                              categorySpending)
                                              .length) {
                                    final category =
                                    _getOrderedCategories(
                                        categorySpending)[
                                    touchedIndex];

                                    setState(() {
                                      // Toggle selection
                                      if (selectedCategory == category) {
                                        selectedCategory = null;
                                      } else {
                                        selectedCategory = category;
                                      }
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegend(categorySpending),
                      // Show detailed category view if category is selected
                      if (selectedCategory != null &&
                          categorySpending.containsKey(selectedCategory!))
                        _buildCategoryDetailCard(
                            selectedCategory!,
                            categorySpending[selectedCategory!]!,
                            totalAmount),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildChartCard(
                  title: "Monthly Spending Trends",
                  child: monthlySpending.isEmpty
                      ? _buildNoDataWidget()
                      : SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        barGroups: monthlySpending.entries.map((entry) {
                          return BarChartGroupData(
                            x: int.parse(entry.key.split('-')[1]),
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.purpleAccent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _getMonthLabel(value.toInt()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  "\$${value.toInt()}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build detailed card for selected category
  Widget _buildCategoryDetailCard(
      String category, double amount, double total) {
    final percentage = (amount / total * 100).toStringAsFixed(2);
    final icon = _getCategoryIcon(category);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getChartColor(category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    icon,
                    color: _getChartColor(category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$percentage%",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₱${amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: amount / total,
              backgroundColor: Colors.grey[200],
              valueColor:
              AlwaysStoppedAnimation<Color>(_getChartColor(category)),
            ),
          ],
        ),
      ),
    );
  }

  // Get icon based on category
  IconData _getCategoryIcon(String category) {
    final Map<String, IconData> icons = {
      'Food': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Entertainment': Icons.movie,
      'Shopping': Icons.shopping_bag,
      'Bills': Icons.receipt,
      'Rent': Icons.home,
      'Health': Icons.local_hospital,
      'Education': Icons.school,
      'Travel': Icons.flight,
      'Lottery': Icons.confirmation_number,
      'Grants': Icons.card_giftcard,
      'Coupons': Icons.local_offer,
      'Salary': Icons.work,
      'Investment': Icons.attach_money,
    };

    return icons[category] ?? Icons.category;
  }

  // Build the filter section
  Widget _buildFilters() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filters",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildTypeFilter(),
            const SizedBox(height: 12),
            _buildDateRangeFilter(),
            const SizedBox(height: 12),
            _buildCategoryFilter(),
          ],
        ),
      ),
    );
  }

  // Type filter (expense/income)
  Widget _buildTypeFilter() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: "Tyypeee",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'expense', child: Text("Expense")),
        DropdownMenuItem(value: 'income', child: Text("Income")),
      ],
      onChanged: (value) {
        setState(() {
          selectedType = value!;
          selectedCategory = null; // Reset selected category
          _reportsFuture = _loadData(); // Refresh data
        });
      },
    );
  }

  // Date range filter
  Widget _buildDateRangeFilter() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedStartDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  selectedStartDate = date;
                  _reportsFuture = _loadData(); // Refresh data
                });
              }
            },
            child: Text(
              selectedStartDate == null
                  ? "Select Start Date"
                  : "Start: ${selectedStartDate!.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedEndDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  selectedEndDate = date;
                  _reportsFuture = _loadData(); // Refresh data
                });
              }
            },
            child: Text(
              selectedEndDate == null
                  ? "Select End Date"
                  : "End: ${selectedEndDate!.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  // Category filter
  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Filter by Category",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: allCategories.map((category) {
            return FilterChip(
              label: Text(category),
              selected: selectedCategories.contains(category),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedCategories.add(category);
                  } else {
                    selectedCategories.remove(category);
                  }
                  _reportsFuture = _loadData(); // Refresh data
                });
              },
              selectedColor: Colors.blueAccent,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: selectedCategories.contains(category)
                    ? Colors.white
                    : Colors.black87,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build a card for charts
  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  // Widget to display when no data is available
  Widget _buildNoDataWidget() {
    return const Center(
      child: Text(
        "No data available for the selected filters",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // Build a legend for the pie chart
  Widget _buildLegend(Map<String, double> data) {
    final orderedCategories = _getOrderedCategories(data);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: orderedCategories.map((category) {
        final isSelected = category == selectedCategory;
        final double amount = data[category]!;
        final percentage = (amount / data.values.reduce((a, b) => a + b) * 100)
            .toStringAsFixed(1);

        return GestureDetector(
          onTap: () {
            setState(() {
              // Toggle selection - if already selected, deselect it
              if (selectedCategory == category) {
                selectedCategory = null;
              } else {
                selectedCategory = category;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                isSelected ? _getChartColor(category) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isSelected ? 14 : 12,
                  height: isSelected ? 14 : 12,
                  decoration: BoxDecoration(
                    color: _getChartColor(category),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "$category ($percentage%)",
                  style: TextStyle(
                    fontSize: isSelected ? 14 : 12,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Get month label for bar chart
  String _getMonthLabel(int month) {
    return DateTime(2023, month).toString().split(' ')[0].substring(5, 7);
  }

  // Get a unique color for each category
  Color _getChartColor(String category) {
    // Direct mapping using if/else for all categories with smooth color transition
    if (category == 'Food') {
      return const Color(0xFFFF9F43); // Deep orange
    } else if (category == 'Transport') {
      return const Color(0xFF54A0FF); // Bright blue
    } else if (category == 'Shopping') {
      return const Color(0xFFFF6B81); // Soft pink
    } else if (category == 'Bills') {
      return const Color(0xFFEE5253); // Coral red
    } else {
      // Default color for any other categories
      return const Color(0xFF9B9B9B); // Medium grey
    }
  }

  // Add these helper methods to order categories

  // Get categories in specific order
  List<String> _getOrderedCategories(Map<String, double> categoryData) {
    // Define the desired order
    final desiredOrder = ['Food', 'Transport', 'Shopping', 'Bills'];

    // Create result list
    List<String> result = [];

    // Add categories in desired order if they exist in data
    for (var category in desiredOrder) {
      if (categoryData.containsKey(category)) {
        result.add(category);
      }
    }

    // Add any remaining categories at the end
    for (var category in categoryData.keys) {
      if (!desiredOrder.contains(category)) {
        result.add(category);
      }
    }

    return result;
  }

  // Обновленный метод для создания секций диаграммы

  List<PieChartSectionData> _getOrderedPieChartSections(
      Map<String, double> categoryData, double totalAmount) {
    final orderedCategories = _getOrderedCategories(categoryData);

    return orderedCategories.asMap().entries.map((entry) {
      final int index = entry.key;
      final String category = entry.value;
      final isSelected = category == selectedCategory;

      return PieChartSectionData(
        value: categoryData[category]!,
        title: isSelected
            ? "${category}\n${(categoryData[category]! / totalAmount * 100).toStringAsFixed(1)}%"
            : "",
        radius: isSelected ? 65 : 50,
        color: _getChartColor(category),
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: null, // Полностью удалить значок
        badgePositionPercentageOffset: 0,
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }
}
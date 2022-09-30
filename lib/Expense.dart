import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Expense {
  int id;
  DateTime date;
  int amount;
  String shop;
  String category;
  Expense(this.id, this.date, this.amount, this.shop, this.category);

  static fromJson(String e) {
    List<String> parts = e.split(';');
    return Expense(int.parse(parts[0]), DateTime.parse(parts[1]),
        int.parse(parts[2]), parts[3].trim(), parts[4].trim());
  }

  static Map<String, IconData> categories = {
    "Food": Icons.fastfood,
    "Transport": Icons.directions_bus,
    "Groceries": Icons.local_grocery_store,
    "Entertainment": Icons.movie,
    "Health": Icons.local_hospital,
    "Clothes": Icons.shopping_bag,
    "Other": Icons.question_mark
  };

  static Map<String, String> categoryMeanings = {
    "spar": "Groceries",
    "tesco": "Groceries",
    "bu:fe": "Food",
    "cola": "Food",
    "riot": "Entertainment",
    "ne'pliget": "Transport",
    "diepthanhtam": "Groceries",
    "dm": "Groceries",
    "pull&bear": "Clothes",
    "h&m": "Clothes",
    "kfc": "Food",
    "epic games": "Entertainment",
    "disney": "Entertainment",
    "steam": "Entertainment",
    "fusion": "Food",
    "kemences": "Food",
    "pekseg": "Food",
    "neu*": "Food",
    "jetbrains": "Entertainment",
    "spotify": "Entertainment",
  };

  String toJson() {
    return '$id;${date.toIso8601String()};$amount;$shop;$category';
  }
}

class ExpenseWidget extends StatelessWidget {
  final Expense expense;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  ExpenseWidget(this.expense);

  @override
  Widget build(BuildContext context) {
    String expenseDay = expense.date.day.toString();
    String expenseShopName = expense.shop.length < 23
        ? expense.shop
        : '${expense.shop.substring(0, 23)}...';

    if (expenseDay.length == 1) {
      expenseDay = '0$expenseDay';
    }
    String expenseMonthShort = months[expense.date.month - 1].substring(0, 3);

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(99, 99, 98, 98),
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                expenseDay,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontSize: 19,
                ),
              ),
              Text(
                expenseMonthShort,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontSize: 19,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 30,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expenseShopName,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontSize: 11,
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      //Get icon by expense.category from categories map
                      Icon(
                        Expense.categories[expense.category],
                        color: Colors.white,
                        size: 23,
                      ),

                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        expense.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.amount} Ft',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

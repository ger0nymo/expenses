import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Expense {
  String date;
  int amount;
  String shop;
  Expense(this.date, this.amount, this.shop);
}

// Make it a widget
class ExpenseWidget extends StatelessWidget {
  final Expense expense;

  const ExpenseWidget(this.expense);
  @override
  Widget build(BuildContext context) {
    String expenseDate = expense.date.split(' ')[0];
    String expenseYear = expenseDate.split('.')[0];
    String expenseMonth = expenseDate.split('.')[1];
    String expenseDay = expenseDate.split('.')[2];
    String expenseShopName = expense.shop.length < 23
        ? expense.shop
        : '${expense.shop.substring(0, 23)}...';

    //Format one digit expenseDay to two digits
    if (expenseDay.length == 1) {
      expenseDay = '0$expenseDay';
    }
    //Get first 3 letters of the month by using the month number
    final DateFormat formatter = DateFormat('MMM');
    String expenseMonthShort = formatter
        .format(DateTime(int.parse(expenseYear), int.parse(expenseMonth),
            int.parse(expenseDay)))
        .toUpperCase();

    return Container(
      //put border radius
      decoration: const BoxDecoration(
        color: Color.fromARGB(99, 99, 98, 98),
        borderRadius: BorderRadius.all(Radius.circular(10)),
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
              Container(
                  child: Text(
                expenseShopName,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontSize: 11,
                ),
              )),
              Container(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(
                    children: const [
                      Icon(Icons.question_mark, size: 30, color: Colors.white),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                          fontSize: 25,
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
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

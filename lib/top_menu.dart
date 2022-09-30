import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TopMenu extends StatelessWidget {
  Function selectMonth;
  int? currentSelectedMonth;

  Function selectYear;
  int? currentSelectedYear;

  TopMenu(this.selectMonth, this.currentSelectedMonth, this.selectYear,
      this.currentSelectedYear);

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

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: DropdownButton<String>(
            value: currentSelectedMonth == null
                ? null
                : months[currentSelectedMonth! - 1],
            dropdownColor: const Color.fromARGB(255, 31, 31, 31),
            menuMaxHeight: 300,
            hint: const Text(
              "Select month",
              style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
            ),
            items: months.map<DropdownMenuItem<String>>((String month) {
              return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Quicksand')));
            }).toList(),
            onChanged: (month) => selectMonth(months.indexOf(month!) + 1),
          )),
      Container(
          margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: DropdownButton<int>(
            value: currentSelectedYear,
            dropdownColor: const Color.fromARGB(255, 31, 31, 31),
            items: [2022, 2021].map<DropdownMenuItem<int>>((year) {
              //TODO: change [2022, 2021] to be based on the spendings possible years
              return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Quicksand')));
            }).toList(),
            onChanged: (year) => selectYear(year),
          )),
    ]);
  }
}

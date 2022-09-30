import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Expense.dart';
import 'top_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      theme: ThemeData(
          fontFamily: 'Quicksand',
          scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31),
          primarySwatch: Colors.grey,
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 158, 158, 158))),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 158, 158, 158))),
            hintStyle: TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 156, 156, 156),
                fontFamily: 'Quicksand'),
            labelStyle: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
          )),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Expense> _expenses = [];

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool descending = true;

  int? selectedMonth;
  int? selectedYear;

  int spendings = 0;

  final List<String> _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void initState() {
    super.initState();
    getExpenses();
  }

  Future getExpenses() {
    return _prefs.then((SharedPreferences prefs) {
      var retrieved = prefs.getStringList('expenses');

      if (retrieved != null && retrieved.isNotEmpty) {
        log('this runs: ${retrieved.length}');
        _expenses = [];
        for (var element in retrieved) {
          var expense = Expense.fromJson(element);
          setState(() {
            _expenses.add(expense);
          });
        }
      } else {
        _getSms();
      }

      var month = prefs.getInt('selectedMonth');
      var year = prefs.getInt('selectedYear');
      setState(() {
        selectedMonth = month ?? DateTime.now().month;
        selectedYear = year ?? DateTime.now().year;
      });
    });
  }

  void calculateSpendings() {
    int sum = 0;
    for (var element in _expenses) {
      if (element.date.month == selectedMonth &&
          element.date.year == selectedYear) {
        sum += element.amount;
      }
    }
    setState(() {
      spendings = sum;
    });
  }

  Future<void> addNewExpense(Expense expense) {
    return _prefs.then((SharedPreferences prefs) {
      int index = 0;
      for (var element in _expenses) {
        log("Comparing ${element.date} and ${expense.date}");
        if (expense.date.isBefore(element.date)) {
          index++;
        } else {
          setState(() {
            _expenses.insert(index, expense);
          });
          prefs.setStringList(
              'expenses', _expenses.map((e) => e.toJson()).toList());
          break;
        }
      }
    });
  }

  Future<void> editExpense(Expense expense) {
    return _prefs.then((SharedPreferences prefs) {
      int index = 0;
      for (var element in _expenses) {
        if (element.id == expense.id) {
          setState(() {
            _expenses[index] = expense;
          });
          prefs.setStringList(
              'expenses', _expenses.map((e) => e.toJson()).toList());
          break;
        }
        index++;
      }
    });
  }

  Future<void> selectMonth(int month) {
    return _prefs.then((SharedPreferences prefs) {
      setState(() {
        selectedMonth = month;
      });
      prefs.setInt('selectedMonth', month);
    });
  }

  Future<void> selectYear(int year) {
    return _prefs.then((SharedPreferences prefs) {
      setState(() {
        selectedYear = year;
      });
      prefs.setInt('selectedYear', year);
    });
  }

  Future _getSms() async {
    await [Permission.sms].request();
    SmsQuery query = new SmsQuery();
    List<Expense> tmp = [];
    List<SmsMessage> messages = await query.querySms(address: "+36303444332");

    for (var element in messages) {
      if (element.body!.contains("Összeg: ") &&
          !element.body!.contains("ÉRVÉNYTELEN") &&
          !element.body!.contains("SIKERTELEN")) {
        String amount = element.body!.split("Összeg: ")[1].split(" HUF")[0];
        int amountInt = int.parse(amount.replaceAll(" ", ""));
        RegExp regExp2 = new RegExp(r"\d{4}.\d{2}.\d{2} \d{2}:\d{2}:\d{2}");
        String date = regExp2.stringMatch(element.body!)!;
        String shop = element.body!.split(", ").reversed.toList()[1];
        shop = shop.replaceAll("  ", " ").substring(1);

        DateTime dateTime = DateFormat("yyyy.MM.dd HH:mm:ss").parse(date);

        String category = "Other";

        for (String key in Expense.categoryMeanings.keys) {
          if (shop.toLowerCase().contains(key)) {
            category = Expense.categoryMeanings[key]!;
            break;
          }
        }

        setState(() {
          _expenses.add(
              Expense(_expenses.length, dateTime, amountInt, shop, category));
        });
      }
    }
    _prefs.then((SharedPreferences prefs) {
      prefs.setStringList('expenses', []);
      List<String> expenses = [];
      for (var element in _expenses) {
        expenses.add(element.toJson());
      }
      prefs.setStringList('expenses', expenses);
    });
    selectedMonth = selectedMonth ?? _expenses[0].date.month;
    selectedYear = selectedYear ?? _expenses[0].date.year;
  }

  Future refreshSmsList() async {
    await [Permission.sms].request();
    SmsQuery query = new SmsQuery();
    List<Expense> tmp = [];
    List<SmsMessage> messages = await query.querySms(address: "+36303444332");

    for (var element in messages) {
      if (element.body!.contains("Összeg: ") &&
          !element.body!.contains("ÉRVÉNYTELEN") &&
          !element.body!.contains("SIKERTELEN")) {
        String amount = element.body!.split("Összeg: ")[1].split(" HUF")[0];
        int amountInt = int.parse(amount.replaceAll(" ", ""));
        RegExp regExp2 = new RegExp(r"\d{4}.\d{2}.\d{2} \d{2}:\d{2}:\d{2}");
        String date = regExp2.stringMatch(element.body!)!;
        String shop = element.body!.split(", ").reversed.toList()[1];
        shop = shop.replaceAll("  ", " ").substring(1);

        DateTime dateTime = DateFormat("yyyy.MM.dd HH:mm:ss").parse(date);

        String category = "Other";

        for (String key in Expense.categoryMeanings.keys) {
          if (shop.toLowerCase().contains(key)) {
            category = Expense.categoryMeanings[key]!;
            break;
          }
        }

        Expense newExpense =
            Expense(_expenses.length, dateTime, amountInt, shop, category);
        //check if the expense is already in the list
        bool found = false;
        for (var expense in _expenses) {
          if (expense.id != newExpense.id &&
              expense.shop == newExpense.shop &&
              expense.date == newExpense.date &&
              expense.amount == newExpense.amount &&
              expense.category == newExpense.category) {
            found = true;
            break;
          }
        }

        if (!found) {
          addNewExpense(newExpense);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Selected month: $selectedMonth and year: $selectedYear");
    calculateSpendings();
    return Scaffold(
      floatingActionButton: _expenses.isEmpty
          ? null
          : FloatingActionButton(
              elevation: 5,
              backgroundColor: const Color.fromARGB(255, 119, 118, 118),
              onPressed: () {
                //Show a dialog to add a new expense
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddNewExpense(addNewExpense, _expenses.length);
                    });
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              )),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshSmsList();
            },
          )
        ],
        title: const Text(
          'Expenses',
          style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _expenses.isEmpty
              ? [const CircularProgressIndicator()]
              : <Widget>[
                  TopMenu(selectMonth, selectedMonth, selectYear, selectedYear),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: Align(
                            child: Container(
                              child: Text(
                                "${NumberFormat("#,###").format(spendings).replaceAll(",", " ")} Ft",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontFamily: 'Quicksand'),
                              ),
                            ),
                          ),
                        ),
                      ]),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            if (_expenses[index].date.year == selectedYear &&
                                _expenses[index].date.month == selectedMonth)
                              if (index == 0 ||
                                  _expenses[index].date.month !=
                                      _expenses[index - 1].date.month)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 0, 0, 10),
                                          child: Text(
                                            '${_months[_expenses[index].date.month - 1]} ${_expenses[index].date.year}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Quicksand',
                                                fontSize: 30),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0),
                                      child: IconButton(
                                        onPressed: () => setState(() {
                                          descending = !descending;
                                          _expenses.sort((a, b) => descending
                                              ? b.date.compareTo(a.date)
                                              : a.date.compareTo(b.date));
                                        }),
                                        icon: descending
                                            ? const Icon(
                                                Icons.south,
                                                color: Colors.white,
                                              )
                                            : const Icon(
                                                Icons.north,
                                                color: Colors.white,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                            if (_expenses[index].date.year == selectedYear &&
                                _expenses[index].date.month == selectedMonth)
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return EditExpense(
                                            editExpense, _expenses[index]);
                                      });
                                },
                                child: ExpenseWidget(_expenses[index]),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

class AddNewExpense extends StatefulWidget {
  Function addNewExpense;
  int expensesLength;
  AddNewExpense(this.addNewExpense, this.expensesLength);

  @override
  State<AddNewExpense> createState() => AddNewExpenseState();
}

class AddNewExpenseState extends State<AddNewExpense> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController amountInput = TextEditingController();
  TextEditingController shopInput = TextEditingController();

  String category = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      category = "Other";
    });
  }

  List<String> categories = Expense.categories.keys.toList();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //set height to bigger
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      title: const Text(
        "Add new expense",
        style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: amountInput,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Amount",
              hintText: "Enter the amount",
            ),
          ),
          TextField(
            controller: shopInput,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Shop",
              hintText: "Enter the shop",
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                  child: TextField(
                style: const TextStyle(color: Colors.white),
                readOnly: true,
                controller: dateInput,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today,
                      color: Colors.white), //icon of text field
                  labelText: "Select Date",
                ),
                onTap: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime.now())
                      .then(
                    (date) {
                      //set value of text field as per selected date except hour and minute and second
                      dateInput.text = date.toString().substring(0, 10);
                    },
                  );
                },
              ))),
          //Create a dropdown with icons. Use this.categories
          //as the list of items
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: DropdownButton<String>(
              //Set the value of the dropdown to the value of categoryInput
              value: category,
              hint: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Icon(Expense.categories["Other"],
                        color: Color.fromARGB(255, 165, 165, 165)),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Text("Select category",
                        style: TextStyle(
                            color: Color.fromARGB(255, 165, 165, 165))),
                  ),
                ],
              ),
              menuMaxHeight: 200,
              dropdownColor: const Color.fromARGB(255, 31, 31, 31),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(Expense.categories[category], color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(category,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value.toString();
                });
              },
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            DateTime date = DateTime.parse(dateInput.text);
            int amount = int.parse(amountInput.text);
            String shop = shopInput.text;
            Expense expense =
                Expense(widget.expensesLength, date, amount, shop, category);
            widget.addNewExpense(expense);
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

class EditExpense extends StatefulWidget {
  Function editExpense;
  Expense expense;
  EditExpense(this.editExpense, this.expense);

  @override
  State<EditExpense> createState() => EditExpenseState();
}

class EditExpenseState extends State<EditExpense> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController amountInput = TextEditingController();
  TextEditingController shopInput = TextEditingController();

  String category = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      category = widget.expense.category;
      dateInput.text = widget.expense.date.toString().substring(0, 10);
      amountInput.text = widget.expense.amount.toString();
      shopInput.text = widget.expense.shop;
    });
  }

  List<String> categories = Expense.categories.keys.toList();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //set height to bigger
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      title: const Text(
        "Add new expense",
        style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: amountInput,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Amount",
              hintText: "Enter the amount",
            ),
          ),
          TextField(
            controller: shopInput,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Shop",
              hintText: "Enter the shop",
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                  child: TextField(
                style: const TextStyle(color: Colors.white),
                readOnly: true,
                controller: dateInput,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today,
                      color: Colors.white), //icon of text field
                  labelText: "Select Date",
                ),
                onTap: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime.now())
                      .then(
                    (date) {
                      //set value of text field as per selected date except hour and minute and second
                      dateInput.text = date.toString().substring(0, 10);
                    },
                  );
                },
              ))),
          //Create a dropdown with icons. Use this.categories
          //as the list of items
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: DropdownButton<String>(
              //Set the value of the dropdown to the value of categoryInput
              value: category,
              hint: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Icon(Expense.categories["Other"],
                        color: Color.fromARGB(255, 165, 165, 165)),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Text("Select category",
                        style: TextStyle(
                            color: Color.fromARGB(255, 165, 165, 165))),
                  ),
                ],
              ),
              menuMaxHeight: 200,
              dropdownColor: const Color.fromARGB(255, 31, 31, 31),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(Expense.categories[category], color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(category,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value.toString();
                });
              },
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            int id = widget.expense.id;
            DateTime date = DateTime.parse(dateInput.text);
            int amount = int.parse(amountInput.text);
            String shop = shopInput.text;
            Expense expense = Expense(id, date, amount, shop, category);
            widget.editExpense(expense);
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

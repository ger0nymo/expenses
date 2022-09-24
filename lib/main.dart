import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Expense.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses app',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 31, 31, 31),
        primarySwatch: Colors.grey,
      ),
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

  List<String> _months = [
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
    _getSms();
  }

  Future _getSms() async {
    await [Permission.sms].request();
    SmsQuery query = new SmsQuery();
    List<SmsMessage> messages = await query.querySms(address: "+36303444332");

    messages.forEach((element) {
      if (element.body!.contains("Összeg: ") &&
          !element.body!.contains("ÉRVÉNYTELEN") &&
          !element.body!.contains("SIKERTELEN")) {
        String amount = element.body!.split("Összeg: ")[1].split(" HUF")[0];
        int amountInt = int.parse(amount.replaceAll(" ", ""));
        RegExp regExp2 = new RegExp(r"\d{4}.\d{2}.\d{2} \d{2}:\d{2}:\d{2}");
        String date = regExp2.stringMatch(element.body!)!;

        //Find the text before the last , and the , before that. That's the name of the shop.
        String shop = element.body!.split(", ").reversed.toList()[1];
        shop = shop.replaceAll("  ", " ").substring(1);

        DateTime dateTime = DateFormat("yyyy.MM.dd HH:mm:ss").parse(date);

        setState(() {
          _expenses.add(Expense(dateTime, amountInt, shop));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.settings),
            onPressed: () {
              print('Icon pressed');
            },
          )
        ],
        title: const Text(
          'Expenses app',
          style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _expenses.isEmpty
              ? [const CircularProgressIndicator()]
              : <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            //Check if the current month is the same as the previous one. If not, display the month name.
                            if (index == 0 ||
                                _expenses[index].date.month !=
                                    _expenses[index - 1].date.month)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(15, 15, 0, 10),
                                    child: Text(
                                      '${_expenses[index].date.year} ${_months[_expenses[index].date.month - 1]}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Quicksand',
                                          fontSize: 30),
                                    ),
                                  ),
                                ),
                              ),
                            TextButton(
                              //put border radius
                              onPressed: () {},
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

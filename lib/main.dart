import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Expense.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Expense> _expenses = [];

  void initState() {
    super.initState();
    _getSms();
  }

  Future _getSms() async {
    await [Permission.sms].request();
    SmsQuery query = new SmsQuery();
    List<SmsMessage> messages = await query.querySms(address: "+36303444332");

    //Loop through the messages. If the text has "Összeg: " in it, then it's a payment message.
    //The template is "... Összeg: N HUF ..." where N is the amount. So we need to extract the number.
    //Maybe we will create an Expense object that will contain amount, date, shop
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

        setState(() {
          _expenses.add(Expense(date, amountInt, shop));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        centerTitle: true,
        title: const Text(
          'Expenses app',
          style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //Display the expenses, mark the months with a divider
          children: _expenses.isEmpty
              ? [CircularProgressIndicator()]
              : <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        //Return the expense widget as a pressable button
                        return TextButton(
                          onPressed: () {},
                          child: ExpenseWidget(_expenses[index]),
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

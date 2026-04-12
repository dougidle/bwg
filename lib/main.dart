import 'package:bwg/resources/bwg_colors.dart';
import 'package:flutter/material.dart';
import 'widgets/bwg_widgets.dart';
import 'widgets/booking.dart';

void main() {
  runApp(const BWGApp());
}

class BWGApp extends StatelessWidget {
  const BWGApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barming Wargamers',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const BWGHomePage(title: 'Barming Wargames Community'),
    );
  }
}

class BWGHomePage extends StatefulWidget {
  const BWGHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<BWGHomePage> createState() => _BWGHomePageState();
}

enum LoadStates { done, loading, error}

class _BWGHomePageState extends State<BWGHomePage> {
  LoadStates _loadState = LoadStates.done;
  DateTime theDate =  DateTime.now();

  void _setDoneState() {
    setState(() {
    _loadState = LoadStates.done;
    });
  }

  void _setLoadingState() {
    setState(() {
    _loadState = LoadStates.loading;
    });
  }

  void _setErrorState() {
    setState(() {
    _loadState = LoadStates.error;
    });
  }

  void _loadBookings() async {
    if (_loadState != LoadStates.loading) {
      _setLoadingState();
      await getBookingsFromRemoteDb();
      _setDoneState();
    } else {
      print("Can't do it - I'm already doing it!");
    }
  }

  Future<void> getBookingsFromRemoteDb() async {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 1));
      print("Index: $i");
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget theIcon;
    if (_loadState == LoadStates.loading) {
      theIcon = Icon(Icons.warning_rounded);
    } else {
      theIcon = Icon(Icons.refresh);
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        foregroundColor: bwg_lilac,
        backgroundColor: Colors.black,
        // Here we take the value from the BWGHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        leading: IconButton(
          onPressed: _loadBookings, 
          icon: theIcon
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          children: <Widget>[
            MakeBookingTile(
              /*onSubmitGuess: (String guess) {
              setState(() { // NEW
                _game.guess(guess);
              });
              },*/
            ),
            DayBookingTile(
              "2 April 2026",
              [
                Booking("Doug I", "Kris R", "Warhammer 40,000"),
                Booking("Matt B", "Simon L", "Warhammer 40,000"),
                Booking("Cam B", "Tommy F", "Warhammer 40,000")
              ]
            ),
            DayBookingTile(
              "9 April 2026",
              [
                Booking("Matt B", "James D", "Warhammer 40,000"),
                Booking("Doug I", "Cam B", "Horus Heresy")
              ]
              ),
          ],
        ),
      ),
    );
  }
}

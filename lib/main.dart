import 'package:bwg/resources/bwg_colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
      home: const BWGHomePage(title: 'Barming Wargamers'),
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

class _BWGHomePageState extends State<BWGHomePage> with TickerProviderStateMixin {
  LoadStates _loadState = LoadStates.done;
  DateTime theDate =  DateTime.now();
  late AnimationController controller;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

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
    }
  }

  Future<void> getBookingsFromRemoteDb() async {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 1));
      print("Index: $i");
    }
  }

  @override
  void initState() {
    super.initState();
     _initPackageInfo();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() {
            setState(() {});
          })
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    Widget theIcon;
    if (_loadState == LoadStates.loading) {
      theIcon = Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.warning_rounded)
      );
    } else {
      theIcon = Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.refresh)
      );
    }

    Widget theProgressIndicator = 
    Padding(
      padding: EdgeInsets.only(left: 0,right: 20,top: 8,bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 14.0,
                  width: 14.0,
                  child:CircularProgressIndicator(
                    value: controller.value,
                    color: bwgLilac,
                  ),
                )   
              ]
            )
          )
        ]
      )
    );

    Widget theRefreshIcon;
    if (_loadState == LoadStates.loading) {
      theRefreshIcon = theProgressIndicator;
    } else {
      theRefreshIcon = IconButton(
          onPressed: _loadBookings, 
          icon: theIcon
        );
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
        foregroundColor: bwgLilac,
        backgroundColor: Colors.black,
        // Here we take the value from the BWGHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () {
            // Show an alert dialog when the button is pressed
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Barming Wargamers"),
                content: Text("Version: ${_packageInfo.version}\nBuild: ${_packageInfo.buildNumber}"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }, 
          icon: Icon(Icons.info)
        ),
        actions: [
          theRefreshIcon
        ],
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
            /*DayBookingTile(
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
              ),*/
          ],
        ),
      ),
    );
  }
}

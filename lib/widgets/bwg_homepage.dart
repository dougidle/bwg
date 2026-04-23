import 'package:bwg/resources/bwg_colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'bwg_widgets.dart';
import '../model/booking.dart';
import '../utilities/load_states.dart';
import '../model/bwg_homepage_viewmodel.dart';

class BWGHomePage extends StatefulWidget {
  const BWGHomePage({super.key, required this.title});
  final String title;

  @override
  State<BWGHomePage> createState() => _BWGHomePageState();
}

class _BWGHomePageState extends State<BWGHomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  LoadStates _loadState = LoadStates.done;
  DateTime theDate =  DateTime.now();
  late AnimationController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Booking> theBookingsList = [];
   Map<String, bool> expandedState = {};
   final viewModel = BWGHomePageViewModel();

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

  
  void _loadBookings() async {
    if (_loadState == LoadStates.loading) return;

    setState(() {
    _loadState = LoadStates.loading;
    });
    try {
      final bookings = await viewModel.fetchBookings();
      setState(() {
        theBookingsList = bookings;
        _loadState = LoadStates.done;
      });
    } catch (_) {
      setState(() {
      _loadState = LoadStates.error;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPackageInfo();
    _loadBookings();

    controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadBookings(); // 👈 refresh when app comes back
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DayBookingTile> allDaysBookingsTileList = [];
    final theGroupedBookings = viewModel.groupBookingsByDate(theBookingsList);
    final sortedEntries = theGroupedBookings.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // descending

    Color loginIconColor = bwgRed;
    Icon loginIcon = Icon(Icons.person_off);

    for (var entry in sortedEntries) {
      final key = entry.key.toIso8601String();
      allDaysBookingsTileList.add(
        DayBookingTile(
          entry.key,
          entry.value,
          isExpanded: expandedState[key] ?? true,
          onToggle: () {
            setState(() {
              expandedState[key] = !(expandedState[key] ?? true);
            });
          },
          key: ValueKey(key),
        ),
      );
    }
  
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
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: controller.value,
                        color: bwgLilac,
                      );
                    },
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        foregroundColor: bwgLilac,
        backgroundColor: Colors.black,
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
          theRefreshIcon,
          Builder(
          builder: (context) {
            return IconButton(
              icon: loginIcon,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: loginIconColor,
            );
          }
        ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          children: <Widget>[
            MakeBookingTile(),
          ] + allDaysBookingsTileList,
        ),
      ),
      drawer: Drawer(
        backgroundColor: bwgLilac,
        child: BWGDrawerMenu()
      ),
    );
  }
}
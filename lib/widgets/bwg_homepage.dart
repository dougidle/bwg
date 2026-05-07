import 'package:bwg/resources/bwg_colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'bwg_widgets.dart';
import '../model/table_booking.dart';
import '../model/game_booking.dart';
import '../model/gamer.dart';
import '../model/logged_in_user.dart';
import '../utilities/load_states.dart';
import '../model/bwg_homepage_viewmodel.dart';
import '../widgets/usericon.dart';
import '../widgets/contentcard.dart';
import '../widgets/mybookings.dart';

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
  List<GameBooking> theGameBookingsList = [];
  List<Gamer> theGamersList = [];
  late LoggedInUser theLoggedInUser; 
  Map<String, bool> expandedState = {};
  final viewModel = BWGHomePageViewModel();
  Color loginIconColor = bwgRed;
  Icon loginIcon = const Icon(Icons.person_off);

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
  
  Future<void> _refreshAllData() async {
    if (_loadState == LoadStates.loading) return;

    setState(() {
      _loadState = LoadStates.loading;
    });

    try {
      // Fetch both Bookings and Gamers in parallel for better performance
      final results = await Future.wait([
        viewModel.fetchBookings(),
        viewModel.fetchGameBookings(),
        viewModel.fetchGamers(),
      ]);

      setState(() {
        theGameBookingsList = results[1] as List<GameBooking>;
        theGamersList = results[2] as List<Gamer>;
        _loadState = LoadStates.done;
      });

      debugPrint('Successfully loaded ${theGamersList.length} gamers and ${theGameBookingsList.length} bookings.');
    } catch (e) {
      debugPrint('Error refreshing data: $e');
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
    _refreshAllData();

    // Handle initial value (already loaded from DB)
    final user = viewModel.theLoggedInUser;
    if (user != null ) {
      loginIcon = Icon(Icons.person);
      loginIconColor = bwgGreen;
    }

    viewModel.addListener(_onViewModelChange);

    controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: false);
  }

  void _onViewModelChange() {
    if (mounted) {
      setState(() {
        final user = viewModel.theLoggedInUser;

        if (user != null) {
          loginIcon = const Icon(Icons.person);
          loginIconColor = bwgGreen;
        } else {
          loginIcon = const Icon(Icons.person_off);
          loginIconColor = bwgRed;
        }
      });
      }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAllData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    viewModel.removeListener(_onViewModelChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DayBookingTile> allDaysBookingsTileList = [];
    final user = viewModel.theLoggedInUser;

    
    // Calculate user-specific bookings at the top of build to avoid syntax errors in the widget tree
    final userBookings = user != null
        ? theGameBookingsList.where((booking) =>
            booking.player1 == user.userId ||
            booking.player2 == user.userId
          ).toList()
        : <GameBooking>[];

    final theGroupedBookings = viewModel.groupGameBookingsByDate(theGameBookingsList);
    final sortedEntries = theGroupedBookings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var entry in sortedEntries) {
      final key = entry.key.toIso8601String();
      allDaysBookingsTileList.add(
        DayBookingTile(
          entry.key,
          entry.value,
          theGamersList,
          isExpanded: expandedState[key] ?? false,
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
    if (_loadState == LoadStates.error) {
      theIcon = Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.warning_rounded, color: bwgRed)
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
          onPressed: _refreshAllData, 
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
                title: const Text('Barming Wargamers'),
                content: Text('Version: ${_packageInfo.version}\nBuild: ${_packageInfo.buildNumber}'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('OK'),
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
            return UserIconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          children: <Widget>[
            if (viewModel.theLoggedInUser == null) 
             ContentCard(
              'Please login using the icon top right before you use the app.'
            ) else ...[
              if (userBookings.isNotEmpty)
                MyBookingsTile(myBookings: userBookings, theGamersList: theGamersList),
              MakeBookingTile(theGamersList: theGamersList, onBookingMade: _refreshAllData),
              ...allDaysBookingsTileList
            ] 
          ] 
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: BWGDrawerMenu()
      ),
    );
  }
}
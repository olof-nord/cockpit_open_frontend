import 'package:cockpit_devolo/deviceClass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'handleSocket.dart';
import 'DrawOverview.dart';
import 'helpers.dart';
import 'EmptyPage.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  //debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devolo Cockpit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: devoloBlue,
        canvasColor: Colors.white,
      ),
      home: MyHomePage(title: 'devolo Cockpit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DrawNetworkOverview _Painter;
  int numDevices = 0;
  Offset _lastTapDownPosition;

  @override
  void initState() {
    handleSocket();
    loadAllDeviceIcons();
  }

  void _incrementCounter() {
    setState(() {
      //doc = parseXML()
    });
  }

  @override
  Widget build(BuildContext context) {
    _Painter = DrawNetworkOverview(context, deviceList.devices);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: devoloBlue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            InkWell(
                child: SvgPicture.asset('assets/logo.svg', height: 24, color: Colors.white)
            ),
            Spacer(),
            SizedBox(width: 56)
          ],
        )
        ,
        centerTitle: true,
      ),
      body: Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child:
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp:_handleTap,
              onTapDown:_handleTapDown,
              // onLongPress: _handleLongPressStart,
              // onLongPressUp: _handleLongPressEnd,
              child: Center(
                child: CustomPaint(
                  painter: _Painter,
                  child: Container(),
                ),
              ),
            ),
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     ' Devices: ' + deviceList.devices.length.toString(),
            //     style: Theme
            //         .of(context)
            //         .textTheme
            //         .headline5,
            //   ),),
            // Expanded(
            //   child: ListView.builder(
            //       padding: const EdgeInsets.all(0),
            //       itemCount: deviceList.devices.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return ListTile(
            //           title: Text(deviceList.devices[index].type),
            //           subtitle: Text(deviceList.devices[index].name +
            //               ", " +
            //               deviceList.devices[index].ip +
            //               ", " +
            //               deviceList.devices[index].mac +
            //               ", " +
            //               deviceList.devices[index].serialno +
            //               ", " +
            //               deviceList.devices[index].MT),
            //         );
            //       }),
            // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Reload',
        backgroundColor: devoloBlue,
        hoverColor: Colors.blue,
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  void _handleTapDown(TapDownDetails details) {
    print('entering _tabDown');
    _lastTapDownPosition = details.localPosition;
  }


  void _handleTap(TapUpDetails details) async {
    print('entering dialog....');

    int index = 0;
    String hitDeviceName;
    String hitDeviceType;
    String hitDeviceSN;
    String hitDeviceMT;
    String hitDeviceIp;
    String hitDeviceMac;

    for (Offset deviceIconOffset in deviceIconOffsetList) {
      if (index >
          _Painter.numberFoundDevices) //do not check invisible circles
        break;

      Offset absoluteOffset = Offset(deviceIconOffset.dx + (_Painter.screenWidth / 2),
          deviceIconOffset.dy + (_Painter.screenHeight / 2));

      if (_Painter.isPointInsideCircle(details.localPosition, absoluteOffset, _Painter.hn_circle_radius)) {
        print("Hit icon #" + index.toString());

        hitDeviceName = deviceList.devices.elementAt(index).name;
        hitDeviceType = deviceList.devices.elementAt(index).type;
        hitDeviceSN = deviceList.devices.elementAt(index).serialno;
        hitDeviceMT = deviceList.devices.elementAt(index).MT;
        hitDeviceIp = deviceList.devices.elementAt(index).ip;
        hitDeviceMac = deviceList.devices.elementAt(index).mac;

        showDialog<void>(
          context: context,
          barrierDismissible: true, // user doesn't tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(hitDeviceName),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Name: ' +hitDeviceName),
                    Text('Type: ' +hitDeviceType),
                    Text('Serialnumber: ' +hitDeviceSN),
                    Text('MT-number: ' +hitDeviceMT),
                    Text('IP: ' +hitDeviceIp),
                    Text('MAC: ' +hitDeviceMac),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        IconButton(icon: Icon(Icons.web), tooltip: 'Launch Webinterface', onPressed: () => launchURL(hitDeviceIp),),
                        IconButton(icon: Icon(Icons.settings), tooltip: 'Settings', onPressed: () => print('Settings'),),
                        IconButton(icon: Icon(Icons.delete), tooltip: 'Delete Device', onPressed: () => print('Delete Device'),),
                      ],
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      index++;
    }
  }

// void _handleTap(TapUpDetails details) {
//   print('entering _handleTab');
//   RenderBox renderBox = context.findRenderObject();
//
//   int index = 0;
//   String hitDeviceName;
//   for (Offset deviceIconOffset in deviceIconOffsetList) {
//     if (index >
//         _Painter.numberFoundDevices) //do not check invisible circles
//       break;
//
//     Offset absoluteOffset = Offset(deviceIconOffset.dx + (_Painter.screenWidth / 2),
//         deviceIconOffset.dy + (_Painter.screenHeight / 2));
//
//     if (_Painter.isPointInsideCircle(details.localPosition, absoluteOffset, _Painter.hn_circle_radius)) {
//       print("Hit icon #" + index.toString());
//
//       hitDeviceName = deviceList.devices.elementAt(index).name;
//
//       if (deviceList.devices.elementAt(index).ip != null &&
//           deviceList.devices.elementAt(index).ip.length > 0 &&
//           deviceList.devices.elementAt(index).ip.compareTo("http://") != 0 &&
//           deviceList.devices.elementAt(index).ip.compareTo("https://") != 0) // ToDo understand... 3rd & 4th condition necessary? Ask what backend will send..just seen ips
//       {
//         String webUrl = "http://"+deviceList.devices.elementAt(index).ip;
//         print("Opening web UI at " + webUrl);
//
//         if (Platform.isFuchsia || Platform.isLinux)
//           print("Would now have opened the Web-Interface at " +
//               webUrl +
//               ", but we are experimental on the current platform. :-/");
//         else
//           launchURL(webUrl);
//
//       } else {
//         Navigator.push(
//           context,
//           new MaterialPageRoute(
//               builder: (context) => new EmptyScreen(title: hitDeviceName)),
//         );
//       }
//     }
//     index++;
//   }
// }
}
import 'package:cockpit_devolo/generated/l10n.dart';
import 'package:cockpit_devolo/models/deviceModel.dart';
import 'package:cockpit_devolo/services/drawOverview.dart';
import 'package:cockpit_devolo/services/handleSocket.dart';
import 'package:cockpit_devolo/shared/app_colors.dart';
import 'package:cockpit_devolo/shared/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cockpit_devolo/models/networkListModel.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;


class OverviewScreen extends StatefulWidget {
  OverviewScreen({Key key}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final networkIndex = 0;


  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int numDevices = 0;
  Offset _lastTapDownPosition;
  DrawOverview _Painter;

  bool showingSpeeds = false;
  int pivotDeviceIndex = 0;

  FocusNode myFocusNode = new FocusNode();


  @override
  void initState() {
    //dataHand();
  }

  @override
  Widget build(BuildContext context) {
    final socket = Provider.of<dataHand>(context);
    final _deviceList = Provider.of<NetworkList>(context);
    socket.setDeviceList(_deviceList);

    _Painter = DrawOverview(context, _deviceList, showingSpeeds, pivotDeviceIndex);

    print("drawing Overview...");

    return Scaffold(
      backgroundColor: Colors.transparent,
      body:  Container(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: _handleTap,
              onTapDown:_handleTapDown,
              onLongPress: () =>_handleLongPressStart(context),
              onLongPressUp: _handleLongPressEnd,
              child: Stack(
                children: [
                  Center(
                    child: CustomPaint(
                      painter: _Painter,
                      child: Container(),
                    ),
                  ),
                  if(_deviceList.getNetworkListLength() > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
                        tooltip: S.of(context).previousNetwork,
                        onPressed: () {
                          print("back");
                          setState(() {
                            if(_deviceList.selectedNetworkIndex  > 0){
                              _deviceList.selectedNetworkIndex --;
                              //_currImage = optimizeImages[_index];
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.white,),
                        tooltip: S.of(context).nextNetwork,
                        onPressed: () {
                          print("forward");
                          setState(() {
                            if(_deviceList.selectedNetworkIndex < _deviceList.getNetworkListLength()-1){ // -1 to not switch
                              _deviceList.selectedNetworkIndex++;
                              //_currImage = optimizeImages[_index];
                            }
                          });
                        },
                      ),
                    ],),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {setState(() {
          socket.sendXML('RefreshNetwork');
        });
        },
        tooltip: 'Neu laden',
        backgroundColor: secondColor,
        foregroundColor: fontColorDark,
        hoverColor: Colors.blue,
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  void _handleTapDown(TapDownDetails details) {
    print('entering tabDown');
    _lastTapDownPosition = details.localPosition;
  }

  void _handleTap(TapUpDetails details)  {
    print('entering dialog....');
    int index = 0;
    Device hitDevice;
    String hitDeviceName;
    String hitDeviceType;
    String hitDeviceSN;
    String hitDeviceMT;
    String hitDeviceVersion;
    String hitDeviceVersionDate;
    String hitDeviceIp;
    String hitDeviceMac;
    bool hitDeviceAtr;
    bool hitDeviceisLocal;

    final socket = Provider.of<dataHand>(context);
    final deviceList = Provider.of<NetworkList>(context);

    print(networkOffsetList);

    networkOffsetList.asMap().forEach((i, networkIconOffset) { //for (Offset networkIconOffset in _Painter.networkOffsets) {
      //Offset absoluteOffset = Offset(networkIconOffset.dx + (_Painter.screenWidth / 2), networkIconOffset.dy + (_Painter.screenHeight / 2));
      print("NetworkIcon: " + networkIconOffset.toString());
      print("Local: " + details.localPosition.toString());
      //print("absolute: " + absoluteOffset.toString());

      //test if network got hit
      if (_Painter.isPointInsideNetworkIcon(details.localPosition, networkIconOffset, _Painter.hn_circle_radius)) {
        print("Hit Network #" + i.toString());
        setState(() {
          deviceList.selectedNetworkIndex = i;
        });
      }
    });

    for (Offset deviceIconOffset in deviceIconOffsetList) {
      if (index >
          _Painter.numberFoundDevices) //do not check invisible circles
        break;

      Offset absoluteOffset = Offset(deviceIconOffset.dx + (_Painter.screenWidth / 2),
          deviceIconOffset.dy + (_Painter.screenHeight / 2));

        //test if device got hit
      if (_Painter.isPointInsideCircle(details.localPosition, absoluteOffset, _Painter.hn_circle_radius)) {
        print("Hit icon #" + index.toString());


        hitDevice = deviceList.getDeviceList()[index];
        hitDeviceName = deviceList.getDeviceList()[index].name;
        hitDeviceType = deviceList.getDeviceList()[index].type;
        hitDeviceSN = deviceList.getDeviceList()[index].serialno;
        hitDeviceMT = deviceList.getDeviceList()[index].MT;
        hitDeviceVersion = deviceList.getDeviceList()[index].version;
        hitDeviceVersionDate = deviceList.getDeviceList()[index].version_date;
        hitDeviceIp = deviceList.getDeviceList()[index].ip;
        hitDeviceMac = deviceList.getDeviceList()[index].mac;
        hitDeviceAtr = deviceList.getDeviceList()[index].attachedToRouter;
        hitDeviceisLocal = deviceList.getDeviceList()[index].isLocalDevice;

        String _newName = hitDeviceName;

        showDialog<void>(
          context: context,
          barrierDismissible: true, // user doesn't need to tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: backgroundColor.withOpacity(0.9),
              contentTextStyle: TextStyle(color: Colors.white, decorationColor: Colors.white, fontSize: 18),
              title: SelectableText('Geräteinfo', style: TextStyle(color: Colors.white),),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 15,),
                    Table(
                      defaultColumnWidth: FixedColumnWidth(200.0),
                    children: [
                      TableRow(children: [
                        SelectableText('Name: '),
                      TextFormField(
                        initialValue: _newName,
                        style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            //labelText: 'Testing',
                            labelStyle: TextStyle(color: myFocusNode.hasFocus ? Colors.amberAccent : Colors.white),
                            focusColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        onChanged: (value) => ( _newName = value),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Bitte Gerätenamen eintargen';
                          }
                          return null;
                        },
                      ),
                      ]),
                      TableRow(children: [
                        SelectableText(S.of(context).type),
                        SelectableText(hitDeviceType),
                      ]),
                      TableRow(children: [
                        SelectableText((S.of(context).serialNumber)),
                        SelectableText(hitDeviceSN),
                      ]),
                      TableRow(children: [
                        SelectableText(S.of(context).mtnumber),
                        SelectableText(hitDeviceMT.substring(2)),
                      ]),
                      TableRow(children: [
                        SelectableText((S.of(context).version)),
                        SelectableText('${hitDeviceVersion} (${hitDeviceVersionDate})'),
                      ]),
                      TableRow(children: [
                        SelectableText(S.of(context).ipaddress),
                        SelectableText(hitDeviceIp),
                      ]),
                      TableRow(children: [
                        SelectableText((S.of(context).macaddress)),
                        SelectableText(hitDeviceMac),
                      ]),
                      TableRow(children: [
                        SelectableText(S.of(context).attachedToRouter),
                        SelectableText(hitDeviceAtr.toString()),
                      ]),
                      TableRow(children: [
                        SelectableText(S.of(context).isLocalDevice ),
                        SelectableText(hitDeviceisLocal.toString()),
                      ]),
                    ],),
                    //Text('Rates: ' +hitDeviceRx),
                    Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        IconButton(icon: Icon(Icons.public, color: secondColor,), tooltip: S.of(context).launchWebinterface, onPressed: () => launchURL(hitDeviceIp),),
                        IconButton(icon: Icon(Icons.lightbulb, color: secondColor,), tooltip: S.of(context).identifyDevice, onPressed: () => socket.sendXML('IdentifyDevice', mac: hitDeviceMac)),
                        IconButton(icon: Icon(Icons.find_in_page, color: secondColor,), tooltip: S.of(context).showManual,
                            onPressed: () async {
                          socket.sendXML('GetManual', newValue: hitDeviceMT, valueType: 'product', newValue2: 'de', valueType2: 'language');
                          var response = await socket.recieveXML(["GetManualResponse"]);
                          setState(() {
                            openFile(response['filename']);
                          });
                        }),
                        IconButton(icon: Icon(Icons.upload_file, color: secondColor,), tooltip: S.of(context).factoryReset, onPressed: () =>_handleCriticalActions(context, socket, 'ResetAdapterToFactoryDefaults', hitDevice),),
                        IconButton(icon: Icon(Icons.delete, color: secondColor,), tooltip: S.of(context).deleteDevice, onPressed: () =>_handleCriticalActions(context, socket, 'RemoveAdapter', hitDevice),), //ToDo Delete Device see wiki
                      ],
                    ),

                  ],
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.check_circle_outline,
                    size: 35,
                    color: fontColorLight,
                  ), //Text('Bestätigen'),
                  tooltip: S.of(context).confirm,
                  onPressed: () {
                    // Critical things happening here
                    socket.sendXML('SetAdapterName', mac: hitDeviceMac, newValue: _newName, valueType: 'name');
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

  //ToDo UI doesn't change
  void _handleLongPressStart(context) {
    print("long press down");
    RenderBox renderBox = context.findRenderObject();

    int index = 0;
    String hitDeviceName;
    for (Offset deviceIconOffset in deviceIconOffsetList) {
      if (index >
          _Painter.numberFoundDevices) //do not check invisible circles
        break;

      Offset absoluteOffset = Offset(deviceIconOffset.dx + (_Painter.screenWidth / 2),
          deviceIconOffset.dy + (_Painter.screenHeight / 2));

      if (_Painter.isPointInsideCircle(_lastTapDownPosition, absoluteOffset, _Painter.hn_circle_radius)) {
        print("Long press on icon #" + index.toString());

        final deviceList = Provider.of<NetworkList>(context);
        hitDeviceName = deviceList.getDeviceList()[index].name;

        setState(() {
          //if (_Painter.showSpeedsPermanently && index == _Painter.pivotDeviceIndex) {
          if (config["show_speeds_permanent"]) {
            //_Painter.showingSpeeds = !_Painter.showingSpeeds;
            showingSpeeds = true;
            config["show_speeds"] = true;
          } else {
            //_Painter.showingSpeeds = true;
            showingSpeeds = true;
            config["show_speeds"] = true;
          }
          //_Painter.pivotDeviceIndex = index;
          pivotDeviceIndex = index;

          //do not update pivot device when the "router device" is long pressed
          print('Pivot on longPress:' +_Painter.pivotDeviceIndex.toString());
          print('sowingSpeed on longPress:' +showingSpeeds.toString());
        });
        return;
      }
      index++;
    }
  }

  void _handleLongPressEnd() {
    print("long press up");

    setState(() {
      if (!config["show_speeds_permanent"]) {
        showingSpeeds = false;
        config["show_speeds"] = false;
        _Painter.pivotDeviceIndex = 0;
        pivotDeviceIndex = 0;
      } else {
        if (!showingSpeeds) _Painter.pivotDeviceIndex = 0;
      }
    });
  }

  void _handleCriticalActions(context, socket, messageType, Device hitDevice) {
    showDialog<void>(
    context: context,
    barrierDismissible: true, // user doesn't need to tap button!
    builder: (BuildContext context) {
    return AlertDialog(
      title: Text(messageType),
      backgroundColor: backgroundColor.withOpacity(0.9),
      content: hitDevice.attachedToRouter?Text(S.of(context).pleaseConfirmActionAttentionYourRouterIsConnectedToThis):Text(S.of(context).pleaseConfirmAction),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check_circle_outline,
            size: 35,
            color: fontColorLight,
          ), //Text('Bestätigen'),
          tooltip: S.of(context).confirm,
          onPressed: () {
            // Critical things happening here
            socket.sendXML(messageType, mac: hitDevice.mac);
            Navigator.of(context).pop();
          },
        ),
        Spacer(),
        IconButton(
            icon: Icon(
              Icons.cancel_outlined,
              size: 35,
              color: fontColorLight,
            ), //Text('Abbrechen'),
            tooltip: S.of(context).cancel,
            onPressed: () {
              // Cancel critical action
              Navigator.of(context).pop();
            }),

      ],
    );
  });
  }

}
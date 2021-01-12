import 'dart:async';

import 'package:cockpit_devolo/services/drawOverview.dart';
import 'package:cockpit_devolo/services/handleSocket.dart';
import 'package:cockpit_devolo/shared/app_colors.dart';
import 'package:cockpit_devolo/shared/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cockpit_devolo/views/logsScreen.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key, this.title, this.painter}) : super(key: key);

  final String title;
  DrawNetworkOverview painter;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _newPw;
  bool _hiddenPw = true;
  bool _isLoading = false;

  void toggleCheckbox(bool value) {
    setState(() {
      widget.painter.showSpeedsPermanently = value;
      print(value);

      if (widget.painter.showSpeedsPermanently) {
        widget.painter.showingSpeeds = true;
        widget.painter.pivotDeviceIndex = 0;
      } else {
        widget.painter.showingSpeeds = false;
        widget.painter.pivotDeviceIndex = 0;
      }
    });
  }

  //creating the timer that stops the loading after 15 secs
  void startTimer() {
    Timer.periodic(const Duration(seconds: 10), (t) {
      setState(() {
        _isLoading = false; //set loading to false
      });
      t.cancel(); //stops the timer
    });
  }

  @override
  Widget build(BuildContext context) {
    dataHand socket = Provider.of<dataHand>(context);

    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: new Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                Text(
                  "GUI",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ]),
              Card(
                color: Colors.blueGrey[50],
                child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  new Text(" Enable Showing Speeds"),
                  new Checkbox(
                    value: false, //widget.painter.showSpeedsPermanently,
                    onChanged: toggleCheckbox,
                  ),
                ]),
              ),
              Card(
                color: Colors.blueGrey[50],
                child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  new Text(" Internet Zentrisch"),
                  new Switch(
                    value: config["internet_centered"],
                    onChanged: (value) {
                      setState(() {
                        config["internet_centered"] = value;
                        socket.sendXML('RefreshNetwork');
                      });
                    },
                    activeTrackColor: devoloBlue.withAlpha(120),
                    activeColor: devoloBlue,
                  ),
                ]),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                Text(
                  "Netzwerk",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ]),
              Card(
                color: Colors.blueGrey[50],
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  new Text(" Alle zukünftigen Updates ignorieren"),
                  new Checkbox(
                      value: config["ignore_updates"], //ToDo
                      onChanged: (bool value) {
                        setState(() {
                          config["ignore_updates"] = !config["ignore_updates"];
                          socket.sendXML('Config');
                        });
                      }),
                ]),
              ),
              Card(
                color: Colors.blueGrey[50],
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  new Text(" Übertragungsleistung der Geräte Aufzeichnen und an devolo übermitteln"),
                  new Checkbox(
                      value: config["allow_data_collection"], //ToDo
                      onChanged: (bool value) {
                        setState(() {
                          config["allow_data_collection"] = !config["allow_data_collection"];
                          socket.sendXML('Config');
                        });
                      }),
                ]),
              ),
              Card(
                color: Colors.blueGrey[50],
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  new Text(" Windows Netzwerkdrosselung"),
                  new Switch(
                    value: !config["windows_network_throttling_disabled"],
                    onChanged: (value) {
                      setState(() {
                        config["windows_network_throttling_disabled"] = !value;
                        print(config["windows_network_throttling_disabled"]);
                      });
                    },
                    activeTrackColor: devoloBlue.withAlpha(120),
                    activeColor: devoloBlue,
                  ),
                ]),
              ),
              Card(
                color: Colors.blueGrey[50],
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        // ToDo sendXml find out Device Mac connected to Internet + Password formfield (hidden)
                        initialValue: _newPw,
                        obscureText: _hiddenPw,
                        decoration: InputDecoration(
                          labelText: ' PLC-Netzwerk Kennwort ändern',
                          //helperText: 'Devicename',
                        ),
                        onChanged: (value) => (_newPw = value),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Bitte neues Passwort eintragen';
                          }
                          return null;
                        },
                      ),
                    ),
                    new Checkbox(
                        value: !_hiddenPw, //ToDo
                        onChanged: (bool value) {
                          setState(() {
                            _hiddenPw = !_hiddenPw;
                          });
                        }),
                    Text("Kennwort anzeigen ")
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                Text(
                  "Support",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ]),
              Card(
                color: Colors.blueGrey[50],
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  RaisedButton(
                      child: Text('Support Informationen generieren'),
                      //color: devoloBlue,
                      //textColor: Colors.white,
                      onPressed: () async {
                        socket.sendXML('SupportInfoGenerate');
                        print(await socket.recieveXML());
                        setState(() {
                          //socket.recieveXML().then((path) =>openFile(path[0]));
                          socket.recieveXML().whenComplete(() => print('COPÜMLETEE'));
                          _isLoading = true;
                          startTimer();  //ToDo check status complete from xml Response instead of timer
                        });
                      }),
                  Flexible(child: _isLoading ? CircularProgressIndicator() : Text(" ")),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.open_in_browser_rounded),
                    tooltip: 'öffne bowser',
                    color: devoloBlue,
                    onPressed: () {
                      socket.recieveXML().then((response) => openFile(response['htmlfilename']));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.archive_outlined),
                    tooltip: 'öffne zip',
                    color: devoloBlue,
                    onPressed: () {
                      socket.recieveXML().then((response) => openFile(response['zipfilename']));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.send_and_archive),
                    tooltip: 'sende an devolo',
                    color: devoloBlue,
                    onPressed: () {
                      _contactInfoAlert(context);
                    },
                  ),
                ]),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                IconButton(
                  icon: Icon(Icons.list_alt),
                  tooltip: 'Show Logs',
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(builder: (context) => new DebugScreen(title: 'Logs')),
                    );
                  }, //ToDo
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCriticalActions(context, socket, messageType, {mac}) {
    showDialog<void>(
        context: context,
        barrierDismissible: true, // user doesn't need to tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(messageType),
            content: Text('Bitte Aktion bestätigen.'),
            actions: <Widget>[
              FlatButton(
                child: Icon(Icons.check_circle_outline, size: 35,color: devoloBlue,),//Text('Bestätigen'),
                onPressed: () {
                  // Critical things happening here
                  socket.sendXML(messageType, mac: mac);
                  Navigator.of(context).pop();
                },),
              FlatButton(
                  child: Icon(Icons.cancel_outlined, size: 35,color: devoloBlue,),//Text('Abbrechen'),
                  onPressed: () {
                    // Cancel critical action
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  void _contactInfoAlert(context) {
    showDialog<void>(
        context: context,
        barrierDismissible: true, // user doesn't need to tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Kontakt Info"),
            content: Column(children: <Widget> [
              Text('Die erstellten Support-Informationen können jetzt zum devolo Support gesendet werden.\nBitte füllen sie folgende Felder aus.'),
              TextFormField(
                //initialValue: _newPw,
                decoration: InputDecoration(
                  labelText: ' Bearbeitungsnummer',
                  //helperText: 'Devicename',
                ),
                onChanged: (value) => (_newPw = value),
                validator: (value) {
                  if (value.isEmpty) {return 'Bitte Bearbeitungsnummer eintragen';}
                  return null;
                },
              ),
              TextFormField(
                //initialValue: _newPw,
                decoration: InputDecoration(
                  labelText: ' Ihr Name',
                  //helperText: 'Devicename',
                ),
                onChanged: (value) => (_newPw = value),
                validator: (value) {
                  if (value.isEmpty) {return 'Bitte ihren Namen eintragen';}
                  return null;
                },
              ),
              TextFormField(
                //initialValue: _newPw,
                decoration: InputDecoration(
                  labelText: ' Ihre Mail-Adresse',
                  //helperText: 'Devicename',
                ),
                onChanged: (value) => (_newPw = value),
                validator: (value) {
                  if (value.isEmpty) {return 'Bitte ihre Mail-Adresse eintragen';}
                  return null;
                },
              ),
            ],),
            actions: <Widget>[
              FlatButton(
              child: Icon(Icons.check_circle_outline, size: 35,color: devoloBlue,),//Text('Bestätigen'),
              onPressed: () {
                // action happening here
                Navigator.of(context).pop();
              },),
              FlatButton(
                  child: Icon(Icons.cancel_outlined, size: 35,color: devoloBlue,),//Text('Abbrechen'),
                  onPressed: () {
                    // Cancel critical action
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

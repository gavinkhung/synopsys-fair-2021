import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/card.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

final PermissionHandler _permissionHandler = PermissionHandler();

Future<loc.LocationData> getLocation() async {
  requestLocationPermission();
  loc.Location location = new loc.Location();

  bool _serviceEnabled;
  loc.PermissionStatus _permissionGranted;
  loc.LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {}
  }
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {}
  }

  return _locationData = await location.getLocation();
}

Future<bool> requestLocationPermission() async {
  return requestPermission(PermissionGroup.locationWhenInUse);
}

Future<bool> requestPermission(PermissionGroup permission) async {
  var result = await _permissionHandler.requestPermissions([permission]);
  if (result[permission] == PermissionStatus.granted) {
    return true;
  }
  return false;
}

Widget showLocData(BuildContext context) {
  var coords;
  try {
    UserModel user = Provider.of<UserModel>(context, listen: false);
    coords = new Coordinates(user.loc.latitude, user.loc.longitude);
  } catch (Exception) {
    return Row(
      children: [
        Text(
          DemoLocalizations.of(context).vals["FirstPage"]["7"],
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
          ),
          softWrap: true,
        ),
        Text(
          " NA",
          style: TextStyle(
            color: Colors.black54,
            fontSize: MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
          ),
          softWrap: true,
        ),
      ],
    );
  }

  return FutureBuilder<List<Address>>(
    future: Geocoder.local.findAddressesFromCoordinates(coords),
    builder: (context, data) {
      if (data.hasData) {
        return Container(
          child: Wrap(
            children: [
              Text(
                DemoLocalizations.of(context).vals["FirstPage"]["7"],
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
                ),
                softWrap: true,
              ),
              Text(
                data.data[0].addressLine,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
                ),
                //softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}

Widget buildWeatherCard(BuildContext context, int times) {
  Map<dynamic, dynamic> weather;
  String humidity, typeWeather, temp, minTemp, maxTemp, day, id;
  return card(
    context,
    IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder(
              future: getWeatherData(
                  Provider.of<UserModel>(context, listen: false).uid),
              builder: (context, value) {
                try {
                  times++;
                  if (value == null) {
                    print("1");
                    return Column(
                      children: times == 0
                          ? [
                              CircularProgressIndicator(
                                backgroundColor:
                                    Color.fromRGBO(24, 165, 123, 1),
                              )
                            ]
                          : [locNotEnabled()],
                    );
                  } else if (value.hasData) {
                    weather = value.data;

                    if (weather != null) {
                      temp = weather['main']['temp'].round().toString();
                      minTemp = weather['main']['temp_min'].round().toString();
                      maxTemp = weather['main']['temp_max'].round().toString();
                      humidity = weather['main']['humidity'].toString();
                      typeWeather = weather['weather'][0]['main'].toString();
                      day = DateFormat.yMMMEd().format(DateTime.now());
                      id = weather['weather'][0]['icon'].toString();
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      day,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize:
                                            MediaQuery.of(context).size.height <
                                                    600
                                                ? 16.5
                                                : 25,
                                      ),
                                    ),
                                    Text(
                                      temp + "°C",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height <
                                                    600
                                                ? 20
                                                : 30,
                                      ),
                                    ),
                                    Text(
                                      minTemp + "°C/" + maxTemp + "°C",
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontSize:
                                            MediaQuery.of(context).size.height <
                                                    600
                                                ? 10
                                                : 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Image.network(
                                    "http://openweathermap.org/img/wn/" +
                                        id +
                                        "@2x.png",
                                    scale: 1.5),
                              ],
                            ),
                            Divider(color: Color.fromRGBO(24, 165, 123, 1)),
                            Wrap(
                              children: [
                                Text(
                                  DemoLocalizations.of(context)
                                      .vals["FirstPage"]["1"],
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.height < 600
                                            ? 11.3
                                            : 17,
                                  ),
                                ),
                                Text(
                                  typeWeather,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        MediaQuery.of(context).size.height < 600
                                            ? 11.3
                                            : 17,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              children: [
                                Text(
                                  DemoLocalizations.of(context)
                                      .vals["FirstPage"]["2"],
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.height < 600
                                            ? 11.3
                                            : 17,
                                  ),
                                ),
                                Text(
                                  humidity + "%",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        MediaQuery.of(context).size.height < 600
                                            ? 11.3
                                            : 17,
                                  ),
                                ),
                              ],
                            ),
                            showLocData(context),
                          ],
                        ),
                      );
                    } else {
                      print("2");
                      return Column(
                        children: times == 0
                            ? [
                                CircularProgressIndicator(
                                  backgroundColor:
                                      Color.fromRGBO(24, 165, 123, 1),
                                )
                              ]
                            : [locNotEnabled()],
                      );
                    }
                  } else {
                    print("3");
                    return Column(
                      children: times == 0
                          ? [
                              CircularProgressIndicator(
                                backgroundColor:
                                    Color.fromRGBO(24, 165, 123, 1),
                              )
                            ]
                          : [locNotEnabled()],
                    );
                  }
                } catch (e) {
                  print("4");
                  print(e.toString());
                  return Column(
                    children: times == 0
                        ? [
                            CircularProgressIndicator(
                              backgroundColor: Color.fromRGBO(24, 165, 123, 1),
                            )
                          ]
                        : [locNotEnabled()],
                  );
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class locNotEnabled extends StatefulWidget {
  locNotEnabled();

  @override
  _locNotEnabled createState() => _locNotEnabled();
}

class _locNotEnabled extends State<locNotEnabled> {
  _locNotEnabled();
  bool switchState = false;
  PermissionHandler _permissionHandler = PermissionHandler();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            DemoLocalizations.of(context).vals["FirstPage"]["8"],
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text("Enable Location Permissions: "),
          trailing: CupertinoSwitch(
            value: switchState,
            activeColor: Color.fromRGBO(24, 165, 123, 1),
            onChanged: (selected) {
              setState(
                () {
                  switchState = !switchState;
                  _permissionHandler
                      .checkPermissionStatus(PermissionGroup.locationWhenInUse)
                      .then((value) => print(value));
                  print(Provider.of<UserModel>(context, listen: false)
                      .loc
                      .toString());
                },
              );
            },
          ),
        )
      ],
    );
  }
}

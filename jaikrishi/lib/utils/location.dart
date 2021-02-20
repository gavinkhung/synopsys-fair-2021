import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/models/weather_model.dart';
import 'package:leaf_problem_detection/screens/home/profile.dart';
import 'package:leaf_problem_detection/text.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/card.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

final PermissionHandler _permissionHandler = PermissionHandler();

Future<loc.LocationData> getLocation() async {
  bool check = await requestLocationPermission();
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

  if (check)
    _locationData = await location.getLocation();
  else {
    analytics.logEvent(name: "denied_loc_permission");
    _locationData =
        new loc.LocationData.fromMap({"latitude": 20, "longitude": 79});
  }
  return _locationData;
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
  String address;
  try {
    UserModel user = Provider.of<UserModel>(context, listen: false);
    address = user.address;
  } catch (Exception) {
    analytics.logEvent(name: "loc_data_failed");
    return Row(
      children: [
        Text(
          texts["FirstPage"]["7"],
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

  return Container(
    child: Wrap(
      children: [
        Text(
          texts["FirstPage"]["7"],
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
          ),
          softWrap: true,
        ),
        Text(
          address,
          style: TextStyle(
            color: Colors.black54,
            fontSize: MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
          ),
          //softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget buildWeatherCard(BuildContext context) {
  return card(
    context,
    IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: usingWeatherData(context),
          ),
        ],
      ),
    ),
  );
}

Widget usingWeatherData(BuildContext context) {
  try {
    LatLng loccc = Provider.of<UserModel>(context, listen: false).loc;
    if (loccc.latitude == 20 && loccc.longitude == 79) throw Exception;
    WeatherModel data = Provider.of<WeatherModel>(context, listen: true);
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
                    data.day,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 16.5 : 25,
                    ),
                  ),
                  Text(
                    data.temp + "°F",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 20 : 30,
                    ),
                  ),
                  Text(
                    data.minTemp + "°F/" + data.maxTemp + "°F",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 10 : 15,
                    ),
                  ),
                ],
              ),
              Image.network(
                  "http://openweathermap.org/img/wn/" + data.id + "@2x.png",
                  scale: 1.5),
            ],
          ),
          Divider(color: Color.fromRGBO(24, 165, 123, 1)),
          Wrap(
            children: [
              Text(
                texts["FirstPage"]["1"],
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
                ),
              ),
              Text(
                data.typeWeather,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
                ),
              ),
            ],
          ),
          Wrap(
            children: [
              Text(
                texts["FirstPage"]["2"],
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
                ),
              ),
              Text(
                data.humidity + "%",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 11.3 : 17,
                ),
              ),
            ],
          ),
          showLocData(context),
        ],
      ),
    );
  } catch (e) {
    print("error: " + e.toString());
    return locNotEnabled();
  }
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
    analytics.logEvent(name: "switch_showed_up");
    return Column(
      children: [
        Center(
          child: Text(
            texts["FirstPage"]["8"],
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(texts["error"]["loc"]),
          trailing: CupertinoSwitch(
            value: switchState,
            activeColor: Color.fromRGBO(24, 165, 123, 1),
            onChanged: (selected) async {
              setState(
                () {
                  switchState = !switchState;
                },
              );
              loc.LocationData value = await getLocation();
              Provider.of<UserModel>(context, listen: false).loc =
                  LatLng(value.latitude, value.longitude);
              await setWeatherData(
                  Provider.of<UserModel>(context, listen: false).uid,
                  context,
                  value.latitude.toString(),
                  value.longitude.toString());
              await updateUserWeather(
                  Provider.of<UserModel>(context, listen: false).uid, value);

              Coordinates coords =
                  new Coordinates(value.latitude, value.longitude);
              List<Address> temp =
                  await Geocoder.local.findAddressesFromCoordinates(coords);
              Provider.of<UserModel>(context, listen: false).address =
                  temp.first.addressLine;

              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => profile()));
            },
          ),
        )
      ],
    );
  }
}

Future<Map> getWeatherData(String uid, String lat, String long) async {
  String apiKey = await rootBundle.loadString("data/keys.json");
  String weatherKey = jsonDecode(apiKey)["weather"];
  String path = 'http://api.openweathermap.org/data/2.5/weather?lat=' +
      lat.toString().trim() +
      '&lon=' +
      long.toString().trim() +
      '&appid=' +
      "d0f5b0af2e8edc9e079d4f8e16932b82" +
      '&units=imperial';

  var request = await http.get(path);
  return json.decode(request.body);
}

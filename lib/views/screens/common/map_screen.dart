import 'dart:async';
import 'dart:convert';
import 'dart:math' show asin, cos, sqrt;

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  MapScreenState();
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();

  // List _items = [];
  List _items = [];

  Set<Marker> markers = {};
  List sca = [];
  List sca_arr = [];

  List params = [];
  String datafile = '';
  String agency = '';
  int gradient1 = 0, gradient2 = 0;
  var g1 = '', g2 = '';
  LatLng _currentlocation = const LatLng(8.804396, 77.38305);

  //new added
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  //end new added
  String radius_value = '30';
  String sac_value = '';
  List _data = [], _data1 = [], filteredlist = [], data2 = [], data3 = [];
  // List _data1 = [];

  // Fetch content from the json file

  List radiuskm = [
    {
      'display': '1 KM',
      'value': '1',
    },
    {
      'display': '5 KM',
      'value': '5',
    },
    {
      'display': '10 KM',
      'value': '10',
    },
    {
      'display': '15 KM',
      'value': '15',
    },
    {
      'display': '20 KM',
      'value': '20',
    },
    {
      'display': '30 KM',
      'value': '30',
    }
  ];
  late BitmapDescriptor centreIcon;
  late BitmapDescriptor currentLocationIcon;

  //ciw start
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }
  //ciw end

  @override
  void initState() {
    super.initState();

    radius_value = '30';
    sac_value = 'PACS';

    getLocation();
    readconfigJson();
    setCentreMarker();
    setCurrentMarker();
  }

  Set<Circle> circles = {
    Circle(
      circleId: const CircleId('radius_circle'),
      center: const LatLng(8.804396, 77.38305),
      fillColor: Colors.blueAccent.withOpacity(0.3),
      strokeWidth: 1,
      radius: 4000,
    )
  };

  void setCentreMarker() async {
    centreIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 5), 'assets/centreicon.jpeg');
  }

  void setCurrentMarker() async {
    currentLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 5), 'assets/currentlocation.jpeg');
  }

  //get current location with marker
  Future<void> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final GoogleMapController controller = await _controller.future;

    setState(() {
      String markid = 'current_location';
      final MarkerId markerId = MarkerId(markid);
      final Marker marker = Marker(
          markerId: markerId,
          icon: currentLocationIcon,
          position: LatLng(position.latitude, position.longitude));
      markers.add(marker);

      _currentlocation = LatLng(position.latitude, position.longitude);

      controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 11.0,
        ),
      ));

      //set radius circle
      circles = {
        Circle(
          circleId: const CircleId('radius_circle'),
          center: _currentlocation,
          fillColor: Colors.blueAccent.withOpacity(0.3),
          strokeWidth: 1,
          strokeColor: Colors.blueAccent.withOpacity(0.3),
          radius: 4000,
        )
      };
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    //ciw start
    _customInfoWindowController.googleMapController = controller;
    //ciw end
    _controller.complete(controller);
  }

  //set radius circle

  void setCircle(latLng) {
    setState(() {
      circles = {
        Circle(
          circleId: const CircleId('radius_circle'),
          center: LatLng(latLng.latitude, latLng.longitude),
          fillColor: Colors.blueAccent.withOpacity(0.3),
          strokeWidth: 1,
          strokeColor: Colors.blueAccent.withOpacity(0.3),
          radius:
              radius_value.isNotEmpty ? (int.parse(radius_value) * 1000) : 4000,
        )
      };
    });
  }

  //set current location marker
  void setMarker(latLng) {
    String markid = 'tap_location';
    final MarkerId markerId = MarkerId(markid);
    final Marker marker = Marker(
        markerId: markerId,
        icon: currentLocationIcon,
        position: LatLng(latLng.latitude, latLng.longitude));

    markers.add(marker);
  }

  //calculate distance (return in km)
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //set centre's marker
  void setCentreMarkers(latLng) {
    setState(() {
      //set location markers
      for (int i = 0; i < _items.length; i++) {
        double distance = calculateDistance(latLng.latitude, latLng.longitude,
            double.parse(_items[i]['Lat']), double.parse(_items[i]['Long']));

        radius_value = (radius_value.isEmpty) ? '4' : radius_value;

        if (distance <= (int.parse(radius_value))) {
          //sca value filter
          if ((sac_value.isNotEmpty && sac_value == _items[i][agency]) ||
              sac_value.isEmpty) {
            String markid = 'marker_$i';
            final MarkerId markerId = MarkerId(markid);
            final Marker marker = Marker(
                markerId: markerId,
                onTap: () {
                  var data = _items[i];
                  String info = '';
                  //
                  int HC = 0;
                  for (HC = 0; HC < params.length; HC++) {
                    info = '${info + data[params[HC]]}\n';
                  }
                  info = '$info${distance.toStringAsFixed(1)} kilo meters from my location';
                  print('test8b');

                  //print(info1);

                  _customInfoWindowController.addInfoWindow!(
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(info),
                                ],
                              ),
                            ),
                          ),
                        ),
                        /* Triangle.isosceles(
                            edge: Edge.BOTTOM,
                            child: Container(
                              color: Colors.white,
                              width: 20.0,
                              height: 10.0,
                            ),
                          ),*/
                      ],
                    ),
                    LatLng(double.parse(_items[i]['Lat']),
                        double.parse(_items[i]['Long'])),
                  );
                  //ciw end
                },
                position: LatLng(double.parse(_items[i]['Lat']),
                    double.parse(_items[i]['Long'])));

            markers.add(marker);
          }
        }
      }
    });
  }

  // Fetch content from the json file
  Future<void> readJson(String jsonfile) async {
    print('read json value  $jsonfile');
    final response = await rootBundle.loadString('assets/json/$jsonfile');
    final data = await json.decode(response);

    /* setState(() {
      _items = data["MapScreen"];

    });
    //print(_items);
    // print(_items2);
    String item=_items[2]["jsonfile"];
    //print(item);
    final response1 =  await rootBundle.loadString('assets/$item');
    // print(response);
    final data1 = await json.decode(response1);
*/
    setState(() {
      //print(data1);
      _items = data['CSC_Tenkasi'];
      print('_items:$_items');
      for (int i = 0; i < _items.length; i++) {
        sca.add(_items[i]['SCA']);
        print('sca::$sca');
        //sca.add(_items[i][agency]);
      }
      sca = sca.toSet().toList();
      print('sca:$sca');
      for (int j = 0; j < sca.length; j++) {
        sca_arr.add({'value': sca[j]});
        print('sca_arr inside forloop:$sca_arr');
      }
      print('sca_arr outside forloop:$sca_arr');
    });
  }
  //new added

  Future<void> readconfigJson() async {
    final String response =
        await rootBundle.loadString('assets/json/config.json');
    final data = await json.decode(response);

    setState(() {
      _data = data['splashscreen'];
      _data1 = data['SubMenu'];
    });
    g1 = _data[0]['gradient_color1'];
    g2 = _data[0]['gradient_color2'];
    print('gradient color');
    print(g1);
    print(g2);
    gradient1 = int.parse(g1);
    gradient2 = int.parse(g2);
    filteredlist = _data1.where((val) => val['MenuId'] == 'code').toList();
    print('filteredlist:$filteredlist');
    setState(() {
      data2 = filteredlist[0]['PopupScreen'];
      print(data2);
      data3 = filteredlist[0]['MapScreen'];
      print(data3);
      agency = data3[2]['combovalue'];
      datafile = data3[2]['jsonfile'];
      params = data2[0]['params'];
      print(agency);
      print(datafile);
      print(params);
      // agency = data["MapScreen"][2]["combovalue"];
      // datafile=data["PopupScreen"][0]["jsonfile"];
      // params = data["PopupScreen"][0]["params"];
      // print("op params is "+params);
      readJson(datafile);
    });

    // datafile=data2["PopupScreen"][0]["jsonfile"];
    // params = data2["PopupScreen"][0]["params"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_data.isNotEmpty ? _data[0]['App_Name'].toString() : ''),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color(gradient1),
                  Color(gradient2),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            radiuslabel(),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              height: MediaQuery.of(context).size.width * 0.25,
              child: DropdownButtonFormField<String>(
                // titleText: data3.isNotEmpty ? data3[0]["combotitle"].toString(): " ",
                hint: Text(
                    data3.isNotEmpty ? data3[0]['combohint'].toString() : ' '),
                value: radius_value,
                onSaved: (value) {
                  setState(() {
                    radius_value = value!;
                    markers = {};

                    //set marker
                    setMarker(_currentlocation);

                    //set radius circle
                    setCircle(_currentlocation);

                    //setCentreMarker
                    setCentreMarkers(_currentlocation);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    radius_value = value!;
                    markers = {};

                    //set marker
                    setMarker(_currentlocation);

                    //set radius circle
                    setCircle(_currentlocation);

                    //setCentreMarker
                    setCentreMarkers(_currentlocation);
                  });
                },
                items: radiuskm.map<DropdownMenuItem<String>>((item) {
                  print('source_combo inside radiuskm item:$radiuskm');
                  return DropdownMenuItem(
                    value: item['value'].toString(), //id based 1,2,
                    onTap: () {
                      setState(() {
                        dynamic toolname = item['display'];
                        print('toolname:$toolname');
                      });
                    },
                    child: Text(
                      item['display'],
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            agencylabel(),
            const SizedBox(
              height: 5,
            ),

            Container(
              padding: const EdgeInsets.all(5),
              height: MediaQuery.of(context).size.width * 0.25,
              child: DropdownButtonFormField<String>(
                // titleText: data3.isNotEmpty ? data3[0]["combotitle"].toString(): " ",
                hint: Text(
                    data3.isNotEmpty ? data3[0]['combohint'].toString() : ' '),
                value: sac_value,
                onSaved: (value) {
                  setState(() {
                    sac_value = value!;
                    markers = {};

                    //set marker
                    setMarker(_currentlocation);

                    //set radius circle
                    setCircle(_currentlocation);

                    //setCentreMarker
                    setCentreMarkers(_currentlocation);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    sac_value = value!;
                    markers = {};

                    //set marker
                    setMarker(_currentlocation);

                    //set radius circle
                    setCircle(_currentlocation);

                    //setCentreMarker
                    setCentreMarkers(_currentlocation);
                  });
                },
                items: sca_arr.map<DropdownMenuItem<String>>((item) {
                  print('source_combo inside sca_arr item:$sca_arr');
                  return DropdownMenuItem(
                    value: item['value'].toString(), //id based 1,2,
                    onTap: () {
                      setState(() {
                        dynamic toolname = item['value'];
                        print('toolname:$toolname');
                      });
                    },
                    child: Text(
                      item['value'],
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),

            Stack(
              //height: MediaQuery.of(context).size.width * 1.22,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width * 1.22,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentlocation,
                      zoom: 5,
                    ),
                    markers: markers,
                    circles: circles,

                    //new added
                    polylines: Set<Polyline>.of(polylines.values),
                    //end new added
                    onTap: (latLng) {
                      setState(() {
                        _currentlocation =
                            LatLng(latLng.latitude, latLng.longitude);

                        //set null of markers
                        markers = {};

                        //set marker
                        setMarker(latLng);

                        //set radius circle
                        setCircle(latLng);

                        //setCentreMarker
                        setCentreMarkers(latLng);
                      });
                      _customInfoWindowController.hideInfoWindow!();
                    },
                    onCameraMove: (position) {
                      _customInfoWindowController.onCameraMove!();
                    },
                  ),
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 150,
                  width: 250,
                  offset: 42,
                ),
              ],
            )
            //ciw end
          ],
        ),
      ),
    );
  }

  Widget radiuslabel() {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: const Text(
        'Choose Radius',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget agencylabel() {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: const Text(
        'Choose Agency',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: const Text('OK'),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text('Select'),
    content: const Text('Please Select Radius value'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

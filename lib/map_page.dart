
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import 'distance_slider.dart';

class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage>{

  int distance = 10;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  //initialized the camera position to the center of Sri Lanka
  CameraPosition cameraPosition = const CameraPosition(target: LatLng(7.8731, 80.7718), zoom: 7.5);
  late GoogleMapController mapController;
  List<Circle> circles = [];
  List<Marker> markers = [];


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: size.height*0.03,
            ),
            SizedBox(
              height: size.height*0.8 - padding.top,
              width: size.width*0.9,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: cameraPosition,
                        myLocationButtonEnabled: false,// used custom my location button
                        circles: Set.of(circles),
                        cameraTargetBounds: CameraTargetBounds(
                          //limited the camera to move within a range
                          LatLngBounds(
                            northeast: const LatLng(9.812994, 81.792497),
                            southwest: const LatLng(5.869899, 79.683066),
                          ),
                        ),
                        markers: Set<Marker>.of(markers),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          mapController = controller;
                        },
                        onTap: onMapClick
                    ),
                  ),
                  //custom my location button
                  Positioned(
                      bottom: size.height*0.015,
                      right: size.height*0.015,
                      child: InkWell(
                        onTap: (){
                          getUserLocation();
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black12,
                          ),
                          padding: EdgeInsets.all(size.height*0.01),
                          child: Icon(
                            Icons.my_location_rounded,
                            size: size.height*0.02,
                            color: Colors.black,
                          ),
                        ),
                      )
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height*0.03,
            ),
            DistanceSlider(
              distance: distance,
              onChanged: (value) {
                if(value >= 5){
                  setState(() {
                    distance = value.toInt();
                  });
                }
              },
              onChangeEnd: (value){
                addCircle(markers.first.position, true);
              },
            ),
            SizedBox(width: size.width)
          ],
        ),
      ),
    );
  }

  getUserLocation() async {
    Position currentLocation;
    currentLocation = await determinePosition();
    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;
    final center = LatLng(lat, lng);
    mapController.animateCamera(CameraUpdate.newLatLngZoom(center, 14)); //animate the camera to the current location
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> onMapClick(LatLng location) async {
    displayMarkerAndCircle(location, false);
  }

  displayMarkerAndCircle(LatLng location, bool animate){
    markers.clear();
    markers.add(Marker(
        position: location,
        markerId: const MarkerId('<--Unique ID-->'),
        infoWindow: const InfoWindow(title: 'You')
    ));
    addCircle(location, animate);
    setState(() {});
  }

  addCircle(LatLng location, bool onRadiusChange){
    circles.clear();
    var uuid = const Uuid();
    setState(() {
      circles.add(
          Circle(
            circleId: CircleId(uuid.v1()),
            center: location,
            strokeWidth: 1,
            strokeColor: Colors.blueAccent.shade200.withOpacity(0.4),
            fillColor: Colors.blueAccent.shade100.withOpacity(0.3),
            radius: 1000 * distance.toDouble(), // in Km
          )
      );
    });
    if(onRadiusChange) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(location, getZoomLevel(circles.first)));
    }
  }

  //calculate the zoom level to display whole circle in the map screen
  double getZoomLevel(Circle circle) {
    double zoomLevel = 0;
    double radius = circle.radius;
    double scale = radius / 400;
    zoomLevel = (16 - log(scale) / log(2));
    return zoomLevel;
  }

}
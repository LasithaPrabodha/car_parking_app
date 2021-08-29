import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:creative_park/app/top_level_providers.dart';
import 'package:creative_park/app/verify/verify_view_model.dart';
import 'package:creative_park/constants/keys.dart';
import 'package:creative_park/constants/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;

  LatLng _initialcameraposition = const LatLng(6.8996408, 79.8536051);
  late BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  Location _location = Location();
  bool isDestinationClicked = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    getLoc();
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData _currentPosition = await _location.getLocation();

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!), zoom: 15),
      ),
    );

    _location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.latitude} : ${currentLocation.longitude}");

//      if(isDestinationClicked) return;
//
//      _currentPosition = currentLocation;
//
//      mapController.animateCamera(
//        CameraUpdate.newCameraPosition(
//          CameraPosition(target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),zoom: 15),
//        ),
//      );

    });
  }

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();
  }

  void setCustomMapPin() async {
    final Uint8List? markerIcon = await getBytesFromAsset('assets/parking-sign.png', 100);

    if (markerIcon != null) {
      setState(() {
        Marker marker = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Car Park: A'),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          position: const LatLng(6.8996408, 79.8536051),
          onTap: () {
            isDestinationClicked = true;
          },
        );
        _markers.add(marker);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.homePage),
        actions: <Widget>[
          TextButton(
            key: const Key(Keys.logout),
            child: const Text(
              Strings.logout,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: () => _confirmSignOut(context, firebaseAuth),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialcameraposition,
          zoom: 15.0,
        ),
        mapType: MapType.normal,
        markers: _markers,
        myLocationEnabled: true,

      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    final bool didRequestSignOut = await showAlertDialog(
          context: context,
          title: Strings.logout,
          content: Strings.logoutAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.logout,
        ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut(context, firebaseAuth);
    }
  }

  Future<void> _signOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    try {
      await firebaseAuth.signOut();
      await resetEmailVerification(context);
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: Strings.logoutFailed,
        exception: e,
      ));
    }
  }

  Future<void> resetEmailVerification(BuildContext context) async {
    final verifyViewModel = context.read(verifyViewModelProvider.notifier);
    await verifyViewModel.reset();
  }
}

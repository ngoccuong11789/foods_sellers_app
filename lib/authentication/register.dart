// import 'dart:html';

// ignore_for_file: unnecessary_import, depend_on_referenced_packages

//import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foods_sellers_app/widgets/custom_text_field.dart';
import 'package:foods_sellers_app/widgets/error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
//import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:location_platform_interface/location_platform_interface.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  Position? position;
  List<Placemark>? placeMarks;

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please select an image",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        
        if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty && nameController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty && phoneController.text.isNotEmpty && locationController.text.isNotEmpty) {
            // Upload image to firebase

        } else {
          showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: "Please write the complete required info",
            );
          },
        );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: "Password don't match",
            );
          },
        );
      }
    }
  }

  Future<Position> _determinePosition() async {
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
    } else {
      await getCurrentLocation();
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
    //return getCurrentLocation();
  }

  getCurrentLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("${newPosition}");
    position = newPosition;
    placeMarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);
    Placemark pMark = placeMarks![0];
    String completeAddress =
        '${pMark.subThoroughfare} ${pMark.thoroughfare} ${pMark.subLocality} ${pMark.locality} ${pMark.subAdministrativeArea} ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
    locationController.text = completeAddress;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () => {_getImage()},
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile == null
                    ? null
                    : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        size: MediaQuery.of(context).size.width * 0.20,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      data: Icons.person,
                      controller: nameController,
                      hintText: "Name",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.email,
                      controller: emailController,
                      hintText: "Email",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.lock,
                      controller: passwordController,
                      hintText: "Password",
                      isObsecre: true,
                    ),
                    CustomTextField(
                      data: Icons.lock,
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      isObsecre: true,
                    ),
                    CustomTextField(
                      data: Icons.phone,
                      controller: phoneController,
                      hintText: "Phone Number",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.my_location,
                      controller: locationController,
                      hintText: "Cafe/Restaurant Address",
                      isObsecre: false,
                      enable: false,
                    ),
                    Container(
                      width: 400,
                      height: 40,
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          //getCurrentLocation();
                          _determinePosition();
                        },
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Get my current location",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            )),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => {formValidation()},
              child: Text(
                "Sign Up",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.cyan,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
// this.controller,
//     this.data,
//     this.hintText,
//     this.isObsecre,
//     this.enable,

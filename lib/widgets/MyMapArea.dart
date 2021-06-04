import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as constant;
import '../models/police_force.dart';
import './police_details_card.dart';

class MyMapArea extends StatefulWidget {
  @override
  _MyMapAreaState createState() => _MyMapAreaState();
}

class _MyMapAreaState extends State<MyMapArea> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(53.19607165470859, -2.753357526393399),
    zoom: 14.4746,
  );

  String polForce = constant.placeholder;
  String message = constant.selectString;
  Color messageColour = Colors.black;
  bool clickedCorrectly = true;
  PoliceForce pForce = new PoliceForce();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: clickedCorrectly,
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                color: messageColour,
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 500,
            maxWidth: double.infinity,
          ),
          child: GoogleMap(
            onTap: (latLng) => getPolice(latLng),
            initialCameraPosition: CameraPosition(
              target: LatLng(
                53.20603382558906,
                -2.7169211795353454,
              ),
              zoom: 10,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ],
    );
  }

  Future<void> getPolice(latlng) async {
    var policeForce = await http
        .read(
      Uri.parse('https://data.police.uk/api/locate-neighbourhood?q=${latlng}'),
    )
        .whenComplete(() {
      setState(() {
        clickedCorrectly = false;
      });
    })
        // ignore: missing_return
        .onError((error, stackTrace) {
      setState(() {
        clickedCorrectly = true;
        messageColour = Colors.red;
        message = constant.errorString;
        return;
      });
    });
    if (policeForce != null) {
      Map<String, dynamic> pf = jsonDecode(policeForce);
      var policeDetailsRaw = await http.read(
        Uri.parse(
          'https://data.police.uk/api/${pf[constant.pf]}/${pf[constant.area]}',
        ),
      );
      var policeDetails = jsonDecode(policeDetailsRaw);
      setState(
        () {
          polForce = pf[constant.pf];
          pForce = createPolice(policeDetails);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoliceDetailsCard(polForce: pForce),
            ),
          );
        },
      );
    }
  }

// a function to create a police force object from the decoded json.
  createPolice(Map<String, dynamic> details) {
    String locationName = constant.noDetails;

    String locationAddres = constant.noDetails;

    String locationPostcode = constant.noDetails;

    String locationTel = constant.noDetails;

    String contactEmail = constant.noDetails;

    String contactPhone = constant.noDetails;

    String contactFb = constant.noDetails;

    String contactTwitter = constant.noDetails;

    String website = checkForNull(details['url_force']);
    if (details['contact_details'].length > 0) {
      contactEmail = checkForNull(details['contact_details']['email']);
      contactPhone = checkForNull(details['contact_details']['telephone']);
      contactFb = checkForNull(details['contact_details']['facebook']);
      contactTwitter = checkForNull(details['contact_details']['twitter']);
    }
    String neighbourhoodName = checkForNull(details['name']);
    if (details['locations'].length > 0) {
      locationName = checkForNull(details['locations'][0]['name']);
      locationAddres = checkForNull(details['locations'][0]['address']);
      locationPostcode = checkForNull(details['locations'][0]['postcode']);
      locationTel = checkForNull(details['locations'][0]['telephone']);
    }
    String description = checkForNull(details['description']);
    return new PoliceForce(
      force: polForce,
      contactEmail: contactEmail,
      website: website,
      contactFb: contactFb,
      contactPhone: contactPhone,
      contactTwitter: contactTwitter,
      neighbourhoodName: neighbourhoodName,
      locationName: locationName,
      locationAddress: locationAddres,
      locationPostcode: locationPostcode,
      locationTel: locationTel,
      description: description,
    );
  }

  String checkForNull(String toCheck) {
    if (toCheck == null) {
      return constant.noDetails;
    }
    return toCheck;
  }
}

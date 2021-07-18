import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
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

  String dropdownValue = constant.choices[0];
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(53.19607165470859, -2.753357526393399),
    zoom: 14.4746,
  );

  bool pointAbsorb = false;
  String polForce = constant.placeholder;
  String message = constant.selectString;
  String details = "";
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
            maxHeight: MediaQuery.of(context).size.height * 0.4,
            maxWidth: double.infinity,
          ),
          child: GoogleMap(
            myLocationButtonEnabled: true,
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
        Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(polForce),
                      !clickedCorrectly
                          ? OutlinedButton(
                              onPressed: moreDetails,
                              child: Text('See all info'),
                            )
                          : Text(''),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: Colors.amber,
                          child: DropdownSelection(),
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          SelectableHtml(data: details),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        ),
      ],
    );
  }

  DropdownButton<String> DropdownSelection() {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_circle_down_rounded),
      isDense: true,
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
          details = setDetails(newValue);
          // pointAbsorb = false;
        });
      },
      items: constant.choices.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

// The function to get  the police details from the API.
  Future<void> getPolice(latlng) async {
    var policeForce = await http
        .read(
      Uri.parse('https://data.police.uk/api/locate-neighbourhood?q=${latlng}'),
    )
        .whenComplete(() {
      setState(() {
        clickedCorrectly = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        clickedCorrectly = true;
        messageColour = Colors.red;
        message = constant.errorString;
        polForce = constant.placeholder;
      });
      return "true";
    });
    // ignore: unnecessary_null_comparison
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
          polForce = 'Police force: ${parseHtml(pf[constant.pf])}';
          pForce = createPolice(policeDetails);
          details = setDetails(dropdownValue);
        },
      );
    }
  }

  void moreDetails() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PoliceDetailsCard(polForce: pForce),
        ));
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

  String setDetails(String details) {
    switch (details) {
      case 'Website':
        return pForce.website;

      case 'Email-Address':
        return pForce.contactEmail;

      case 'Phone-number':
        return pForce.contactPhone;

      case 'Facebook':
        return pForce.contactFb;

      case 'Twitter':
        return pForce.contactTwitter;

      case 'Neighbourhood':
        return parseHtml(pForce.neighbourhoodName);

      case 'Location':
        return parseHtml(pForce.locationName);

      case 'Address':
        return parseHtml(pForce.locationAddress);

      case 'Description':
        return parseHtml(pForce.description);
      default:
        return "No info";
    }
  }

  String parseHtml(String s) {
    final document = parse(s);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}

import 'package:flutter/material.dart';
import '../models/police_force.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';

class PoliceDetailsCard extends StatelessWidget {
  PoliceDetailsCard({
    required this.polForce,
  });

  final PoliceForce polForce;

  @override
  Widget build(BuildContext context) {
    String force = polForce.force;
    String website = polForce.website;
    String contactEmail = polForce.contactEmail;
    String contactPhone = polForce.contactPhone;
    String contactFb = polForce.contactFb;
    String contactTwitter = polForce.contactTwitter;
    String neighbourhoodName = polForce.neighbourhoodName;
    String locationName = polForce.locationName;
    String locationAddress = polForce.locationAddress;
    String locationPostcode = polForce.locationPostcode;
    String locationTel = polForce.locationTel;
    String description = polForce.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          force,
        ),
      ),
      body: Card(
        color: Colors.blueGrey[50],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              detailsRow(
                title: 'Website address:',
                detail: website,
              ),
              detailsRow(
                title: 'Email:',
                detail: contactEmail,
              ),
              detailsRow(
                title: 'Phone:',
                detail: contactPhone,
              ),
              detailsRow(
                title: 'Facebook:',
                detail: contactFb,
              ),
              detailsRow(
                title: 'Twitter:',
                detail: contactTwitter,
              ),
              detailsRow(
                title: 'Neighbourhood:',
                detail: neighbourhoodName,
              ),
              detailsRow(
                title: 'Location:',
                detail: locationName,
              ),
              detailsRow(
                title: 'Address:',
                detail: locationAddress,
              ),
              detailsRow(
                title: 'Postcode:',
                detail: locationPostcode,
              ),
              detailsRow(
                title: 'Telephone:',
                detail: locationTel,
              ),
              detailsRow(
                title: 'Description:',
                detail: description,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class detailsRow extends StatelessWidget {
  final String title;
  final String detail;
  const detailsRow({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                children: [
                  SelectableHtml(
                    data: detail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String parseHtml(String s) {
    final document = parse(s);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}

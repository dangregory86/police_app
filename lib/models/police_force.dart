import '../constants.dart' as constant;

class PoliceForce {
  String force;
  String website;
  String contactEmail;
  String contactPhone;
  String contactFb;
  String contactTwitter;
  String neighbourhoodName;
  String locationName;
  String locationAddress;
  String locationPostcode;
  String locationTel;
  String description;
  PoliceForce({
    this.force = constant.noDetails,
    this.website = constant.noDetails,
    this.contactEmail = constant.noDetails,
    this.contactPhone = constant.noDetails,
    this.contactFb = constant.noDetails,
    this.contactTwitter = constant.noDetails,
    this.neighbourhoodName = constant.noDetails,
    this.locationName = constant.noDetails,
    this.locationAddress = constant.noDetails,
    this.locationPostcode = constant.noDetails,
    this.locationTel = constant.noDetails,
    this.description = constant.noDetails,
  });
}

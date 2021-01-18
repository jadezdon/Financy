import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class LocationModel extends Equatable {
  static const tblLocation = "t_location";
  static const colId = "id";
  static const colLatitude = "latitude";
  static const colLongitude = "longitude";
  static const colCountry = "country";
  static const colCity = "city";
  static const colStreet = "street";
  static const colHouseNumber = "house_number";

  int id;
  double latitude;
  double longitude;
  String country;
  String city;
  String street;
  String houseNumber;

  LocationModel({
    this.latitude,
    this.longitude,
    this.country,
    this.city,
    this.street,
    this.houseNumber,
  });

  LocationModel.withId({
    this.id,
    this.latitude,
    this.longitude,
    this.country,
    this.city,
    this.street,
    this.houseNumber,
  });

  LocationModel clone() {
    return LocationModel.withId(
      id: this.id,
      latitude: this.latitude,
      longitude: this.longitude,
      country: this.country,
      city: this.city,
      street: this.street,
      houseNumber: this.houseNumber,
    );
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map[colId] = id;
    }
    map[colLatitude] = latitude;
    map[colLongitude] = longitude;
    map[colCountry] = country;
    map[colCity] = city;
    map[colStreet] = street;
    map[colHouseNumber] = houseNumber;
    return map;
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel.withId(
      id: map[colId],
      latitude: map[colLatitude],
      longitude: map[colLongitude],
      country: map[colCountry],
      city: map[colCity],
      street: map[colStreet],
      houseNumber: map[colHouseNumber],
    );
  }

  bool isValidAddress() {
    return country != null && city != null && street != null && houseNumber != null;
  }

  String getAddressString() {
    return "$country, $city, $street $houseNumber.";
  }

  @override
  List<Object> get props => [
        id,
        latitude,
        longitude,
        country,
        city,
        street,
        houseNumber,
      ];
}

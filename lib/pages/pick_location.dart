import 'package:Financy/config/theme.dart';
import 'package:Financy/data/models/location_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationPage extends StatefulWidget {
  final LocationModel location;
  PickLocationPage({Key key, this.location}) : super(key: key);

  @override
  _PickLocationPageState createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  GoogleMapController mapController;
  Set<Marker> markers = Set();
  LocationModel selectedLocation = LocationModel(latitude: 46.2587, longitude: 20.14222);

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      selectedLocation = widget.location.clone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("choose-location")),
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(selectedLocation.latitude, selectedLocation.longitude),
                    zoom: 16,
                  ),
                  markers: markers,
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                    });
                  },
                  onTap: (argument) => _onMapTap(argument),
                ),
              ),
            ],
          ),
          if (selectedLocation.isValidAddress())
            Positioned(
              left: MediaQuery.of(context).size.width * 0.1,
              bottom: 100,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(AppSize.borderRadius)),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 100,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        selectedLocation.getAddressString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context, selectedLocation);
                        },
                        color: Theme.of(context).accentColor,
                        child: Text(
                          tr("select"),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTap(LatLng latLng) async {
    final coordinates = Coordinates(latLng.latitude, latLng.longitude);
    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      selectedLocation.latitude = latLng.latitude;
      selectedLocation.longitude = latLng.longitude;
      markers.clear();
      markers.add(Marker(
        markerId: MarkerId(selectedLocation.id.toString()),
        position: LatLng(selectedLocation.latitude, selectedLocation.longitude),
        icon: BitmapDescriptor.defaultMarker,
      ));

      final first = addresses.first;
      selectedLocation.country = first.countryName;
      selectedLocation.city = first.locality;
      selectedLocation.street = first.thoroughfare;
      selectedLocation.houseNumber = first.subThoroughfare;
    });
  }
}

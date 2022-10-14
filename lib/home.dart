import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import 'constants/app_constants.dart';
import 'models/map_marker_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final pageController = PageController();
  var currentLocation = AppConstants.myLocation;
  int selectedIndex = 0;
  bool isDetailShow = false;

  late final MapController mapController;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72.0),
        child: FloatingActionButton(
          onPressed: () {
            _animatedMapMove(AppConstants.myLocation, 12);
            if (isDetailShow) Navigator.pop(context);
            setState(() {
              isDetailShow = false;
            });
          },
          backgroundColor: const Color(0xff76A1A1),
          child: const Icon(
            Icons.my_location_outlined,
            size: 24.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              minZoom: 5,
              maxZoom: 18,
              zoom: 12,
              center: currentLocation,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/reynaldi18/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                additionalOptions: {
                  'mapStyleId': AppConstants.mapBoxStyleId,
                  'accessToken': AppConstants.mapBoxAccessToken,
                },
              ),
              MarkerLayerOptions(
                markers: [
                  for (int i = 0; i < mapMarkers.length; i++)
                    Marker(
                      height: 62,
                      width: 62,
                      point: mapMarkers[i].location ?? AppConstants.myLocation,
                      builder: (_) {
                        return GestureDetector(
                          onTap: () {
                            selectedIndex = i;
                            currentLocation = mapMarkers[i].location ??
                                AppConstants.myLocation;
                            _animatedMapMove(currentLocation, 11.8);
                            showDetail(mapMarkers[i]);
                            setState(() {
                              isDetailShow = true;
                            });
                          },
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 500),
                            scale: selectedIndex == i ? 1 : 0.7,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: selectedIndex == i ? 1 : 0.5,
                              child: SvgPicture.asset(
                                'assets/icons/map_marker.svg',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              )
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isDetailShow
                ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 68.0,
                        right: 24.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            isDetailShow = false;
                          });
                        },
                        child: ClipOval(
                          child: Container(
                            height: 46.0,
                            width: 46.0,
                            color: Colors.white,
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: mapController.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: mapController.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: mapController.zoom,
      end: destZoom,
    );

    var controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void showDetail(MapMarker data) {
    scaffoldKey.currentState?.showBottomSheet(
      (context) => SizedBox(
        height: 324,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 308,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xff527676),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            (data.title ?? '').toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset('assets/icons/ic_battery.svg'),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                // (data.battery ?? 0).toString(),
                                ('Battre').toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '\$${data.price}/min',
                            style: const TextStyle(
                              color: Color(0xffFFE55C),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${data.distance}m',
                            style: const TextStyle(
                              color: Color(0xffFFE55C),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                    topLeft: Radius.circular(30),
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Reserve',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                data.image ?? '',
                fit: BoxFit.cover,
                height: 205,
                width: 205,
              ),
            ),
          ],
        ),
      ),
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }
}

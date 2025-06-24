import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import 'package:medi_shop_demo/user_data.dart';

class UserMap extends ConsumerStatefulWidget {
  const UserMap({super.key, required this.centerLat, required this.centerLng});

  final double centerLat;
  final double centerLng;

  @override
  ConsumerState<UserMap> createState() => _UserMapState();
}

class _UserMapState extends ConsumerState<UserMap> {
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.centerLat, widget.centerLng),
        minZoom: 16.0, //중심에서 상하좌우 약 800m
        initialZoom: 17.0, //숫자가 클수록 확대된다
        maxZoom: 18.0, //중심에서 상하좌우 약 200m
        //Flutter Map이 준비된 후
        onMapReady: () async {
          //첫 실행히 전달받은 초기 위치 값으로 지도를 그린다.
          ref.watch(pvLocation.notifier).state = LatLng(
            widget.centerLat,
            widget.centerLng,
          );
          //첫 실행히 전달받은 초기 위치 값으로 목록을 만든다.
          ref.watch(pvShopList.notifier).state = await getShopList(
            widget.centerLat,
            widget.centerLng,
            mapController.camera.zoom,
          );
        },
        onMapEvent: (p0) async {
          //MapEvent가 끝나면 = MapEventMoveEnd = 맵 움직임이 멈추면
          if (p0 is MapEventMoveEnd || p0 is MapEventScrollWheelZoom) {
            //이벤트 종료시 위치를 현재 위치로 업데이트하며 지도를 그린다.
            ref.watch(pvLocation.notifier).state = p0.camera.center;

            //이벤트 종료시 위치를 현재 위치로 업데이트하며 목록을 만든다.
            ref.watch(pvShopList.notifier).state = await getShopList(
              p0.camera.center.latitude,
              p0.camera.center.longitude,
              mapController.camera.zoom,
            );
          }
        },
        interactionOptions: InteractionOptions(
          // 상호작용 제한
          flags:
              InteractiveFlag.pinchZoom |
              InteractiveFlag.pinchMove |
              InteractiveFlag.scrollWheelZoom |
              InteractiveFlag.drag,
        ),
      ),
      children: [
        //Layer 순서에 따라 덮어그려지기도 한다.

        //배경 그리기
        TileLayer(
          tileProvider: CancellableNetworkTileProvider(),
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.thinkaholic.com.app',
        ),

        //목록에 따른 위치 그리기
        MarkerLayer(markers: makeTextMarkers(ref.watch(pvShopList))),

        //처음엔 사용자 위치 그리기 -> 맵 이동 후 센터 위치 그리기
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(
                ref.watch(pvLocation).latitude,
                ref.watch(pvLocation).longitude,
              ),
              child: Icon(Icons.location_on_sharp),
              height: 60,
              width: 60,
            ),
          ],
        ),
      ],
    );
  }
}

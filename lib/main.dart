import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medi_shop_demo/user_data.dart';
import 'package:medi_shop_demo/user_map.dart';
import 'package:medi_shop_demo/user_list.dart';

/*
위치를 읽고
목록을 읽고
위치에 따른 목록 리스트를 뽑고
지도에 넘겨 표시한다.
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //플러터 바인딩 초기화
  runApp(ProviderScope(child: const MyApp())); //riverpod 초기화
}

//App 시작 시 초기화를 위한 initState를 사용하고자 StatefulWidget을 사용한다.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    //initState에서 await 사용하기 위한 방법, 하지만 여전히 위젯은 비동기다
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getPermission(); //위치 허용
      await getTotalList(); //csv 읽어오기
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isWideScreen = screenWidth > screenHeight;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(appName),
        ),
        body: Center(
          child: FutureBuilder<List>(
            //future가 완료되면 builder를 수행한다
            future: Future.wait([getLocationData(), getTotalList()]),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                //future 도중엔 로딩화면
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                //future 중 에러발생 시 에러 표시
                return Text('Error: ${snapshot.error}');
              } else {
                //future 완료, 준비된 데이터로 그리자.
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  direction: isWideScreen ? Axis.horizontal : Axis.vertical,
                  children: <Widget>[
                    SizedBox(
                      width: isWideScreen
                          ? screenWidth * 0.6
                          : screenWidth * 0.9,
                      height: isWideScreen
                          ? screenHeight * 0.8
                          : screenHeight * 0.4,
                      child: UserMap(
                        centerLat: snapshot.data![0].latitude!,
                        centerLng: snapshot.data![0].longitude!,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      width: isWideScreen
                          ? screenWidth * 0.3
                          : screenWidth * 0.9,
                      height: isWideScreen
                          ? screenHeight * 0.8
                          : screenHeight * 0.4,
                      child: UserList(shopList: ref.watch(pvShopList)),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

/*
Add the following to E:\Project\medi_shop_demo\android\app\build.gradle.kts:
    android {
        ndkVersion = "27.0.12077973"
        ...
    }
*/

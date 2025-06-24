# medi_shop_demo

## 프로젝트 소개

사용자의 위치를 중심으로
의료기기 판매업으로 등록된 업체 목록을
지도와 함께 표시합니다.

## 개발 기간
2025년 6월
공공데이터 검색 및 분석
공공데이터 변환
Flutter UI 구성
Flutter 구현

## 개발 환경
언어:Flutter
IDE:VS Code

## 실행모습
![Web에서 실행 시](https://github.com/daumhch/medi_shop_demo/blob/main/document/web%20example.png)
![Android에서 실행 시](https://github.com/daumhch/medi_shop_demo/blob/main/document/android_example.png)

## 특이사항
공공데이터에서 제공하는 자료의 위도/경도 좌표와,
본 프로젝트에서 사용한 flutter_map 라이브러리에서
사용하는 위도/경도 좌표의 형식이 달라서,
공공데이터에서 받은 자료의 위도/경도 좌표를
C#을 이용하여 변환 작업을 거쳤습니다.

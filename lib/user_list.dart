import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserList extends ConsumerStatefulWidget {
  const UserList({super.key, required this.shopList});

  final List<dynamic> shopList;

  @override
  ConsumerState<UserList> createState() => _UserListState();
}

class _UserListState extends ConsumerState<UserList> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true, // [스크롤바 항상 표시 여부]
      trackVisibility: true, // [막대 이동 경로 표시 활성 여부]

      child: ListView.separated(
        // 구분선이 있는 ListView
        shrinkWrap: true,
        itemCount: widget.shopList.length, // 넘겨받은 리스트 길이만큼
        itemBuilder: (context, index) {
          // Text 정보를 표시한다
          return ListTile(
            style: ListTileStyle.list,
            title: Text(
              '${widget.shopList[index][0]}',
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(), //구분선
        controller: _scrollController,
      ),
    );
  }
}

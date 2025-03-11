import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 0;

  final List<String> _filters = ['전체', '팔로우', '좋아요', '답글'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                size: 20, color: Color(0xFF474747)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),
        title: Text(
          '활동',
          style: TextStyle(
            color: Color(0xFF474747),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 탭 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory, // ✅ 스플래시 효과 제거
                highlightColor: Colors.transparent, // ✅ 터치 강조 효과 제거
                chipTheme: ChipThemeData(
                  selectedColor: Color(0xFFDDEBFF),
                  backgroundColor: Color(0xFFF2F2F2),
                  disabledColor: Colors.grey,
                  elevation: 0, // ✅ 그림자 제거
                  pressElevation: 0, // ✅ 터치 시 그림자 제거
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_filters.length, (index) {
                  bool isSelected = _selectedIndex == index;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Color(0xFF477BFF)
                                  : Color(0xFF474747),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 탭별 내용
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildTabContent('전체 알림이 없습니다.'),
                _buildTabContent('팔로우 알림이 없습니다.'),
                _buildTabContent('좋아요 알림이 없습니다.'),
                _buildTabContent('답글 알림이 없습니다.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ModalBar extends StatelessWidget {
  const ModalBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FractionallySizedBox(
      widthFactor: 0.15, // 화면 크기에 맞게 조절(너비 자동 조절) 0.25
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12), // 위아래 여백 추가
        height: 4, // 높이 설정 5
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor, // 테마 색상 반영
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }
}

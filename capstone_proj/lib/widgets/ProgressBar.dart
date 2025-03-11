import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 진행률 (0.0 ~ 1.0)

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 400,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF477BFF)),
              ),
            ),
          ),
        ),
        SizedBox(height: 24), // 진행바와 텍스트 사이 여백
      ],
    );
  }
}

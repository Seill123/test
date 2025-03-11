import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/PhoneSignUpScreen.dart';
import 'package:capstone_proj/screens/onboarding/language_add_screen.dart';
import 'package:capstone_proj/screens/onboarding/language_screen.dart';
import 'package:capstone_proj/screens/onboarding/nationality_screen.dart';
import 'package:capstone_proj/screens/onboarding/profile_screen.dart';
import 'package:capstone_proj/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicInfoScreen extends StatefulWidget {
  final int currentStep; // 현재 회원가입 단계

  const BasicInfoScreen({
    Key? key,
    this.currentStep = 7,
  }) : super(key: key);

  @override
  _BasicInfoScreenState createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  bool isNextButtonEnabled = false; // 다음 버튼 활성화 여부

  @override
  void initState() {
    super.initState();

    _updateNextButtonState();
  }

  void _updateNextButtonState() {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    setState(() {
      isNextButtonEnabled = signUpProvider.data.location.isNotEmpty &&
          signUpProvider.data.nativeLanguage.isNotEmpty &&
          signUpProvider.data.preferredLanguage.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PhoneSignUpScreen()),
              );
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressBar(progress: widget.currentStep / 10),
            Text(
              '기본정보',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '이후 변경할 수 없으니 정확히 선택해 주세요',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),

            // 국적 선택
            _buildOptionTile(
                '국적', signUpProvider.data.location, Icons.arrow_forward_ios,
                onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NationalitySelectionScreen()),
              );
              _updateNextButtonState();
            }),

            // 모국어 선택
            _buildOptionTile('모국어', signUpProvider.data.nativeLanguage,
                Icons.arrow_forward_ios, onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageScreen(),
                ),
              );
              _updateNextButtonState();
            }),

            // 관심 언어 선택
            _buildOptionTile('관심언어', signUpProvider.data.preferredLanguage,
                Icons.arrow_forward_ios, onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageAddScreen(),
                ),
              );
              _updateNextButtonState();
            }),

            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isNextButtonEnabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          );
                        }
                      : null, // 버튼 비활성화
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isNextButtonEnabled
                        ? const Color(0xFF477BFF)
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, String value, IconData icon,
      {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        tileColor: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : '선택하세요',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(icon, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

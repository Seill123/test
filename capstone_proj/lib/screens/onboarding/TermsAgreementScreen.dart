import 'package:capstone_proj/screens/onboarding/signup_screen.dart';
import 'package:flutter/material.dart';

class TermsAgreementScreen extends StatefulWidget {
  @override
  _TermsAgreementScreenState createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  bool _allChecked = false;
  bool _termsChecked = false;
  bool _privacyChecked = false;
  bool _locationChecked = false;
  bool _ageChecked = false;
  bool _marketingChecked = false;
  bool _adsChecked = false;

  void _toggleAll() {
    setState(() {
      bool newValue = !_allChecked;
      _allChecked = newValue;
      _termsChecked = newValue;
      _privacyChecked = newValue;
      _locationChecked = newValue;
      _ageChecked = newValue;
      _marketingChecked = newValue;
      _adsChecked = newValue;
    });
  }

  void _toggleIndividual() {
    setState(() {
      _allChecked = _termsChecked &&
          _privacyChecked &&
          _locationChecked &&
          _ageChecked &&
          _marketingChecked &&
          _adsChecked;
    });
  }

  bool get _isButtonEnabled =>
      _termsChecked && _privacyChecked && _locationChecked && _ageChecked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tabtalk 이용약관에 \n동의해 주세요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Tabtalk 서비스를 이용하시려면\n개인정보 및 필수 동의가 필요합니다.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            _buildAgreementCheckbox("전체 동의 (선택 항목 포함)",
                checked: _allChecked,
                isMain: true,
                onChanged: (_) => setState(() => _toggleAll())),
            Divider(),
            _buildAgreementCheckbox("(필수) 서비스 이용 약관",
                checked: _termsChecked,
                onChanged: (val) => setState(() {
                      _termsChecked = val;
                      _toggleIndividual();
                    }),
                isRequired: true),
            _buildAgreementCheckbox("(필수) 개인정보 처리방침",
                checked: _privacyChecked,
                onChanged: (val) => setState(() {
                      _privacyChecked = val;
                      _toggleIndividual();
                    }),
                isRequired: true),
            _buildAgreementCheckbox("(필수) 위치 기반 서비스 이용약관",
                checked: _locationChecked,
                onChanged: (val) => setState(() {
                      _locationChecked = val;
                      _toggleIndividual();
                    }),
                isRequired: true),
            _buildAgreementCheckbox("(필수) 만 18세 이상입니다.",
                checked: _ageChecked,
                onChanged: (val) => setState(() {
                      _ageChecked = val;
                      _toggleIndividual();
                    }),
                isRequired: true),
            _buildAgreementCheckbox("(선택) 마케팅 활용 동의",
                checked: _marketingChecked,
                onChanged: (val) => setState(() {
                      _marketingChecked = val;
                      _toggleIndividual();
                    })),
            _buildAgreementCheckbox("(선택) 광고성 정보 수신 동의",
                checked: _adsChecked,
                onChanged: (val) => setState(() {
                      _adsChecked = val;
                      _toggleIndividual();
                    })),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      }
                    : null,
                child: Text(
                  '시작하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isButtonEnabled ? Color(0xFF477BFF) : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementCheckbox(
    String text, {
    bool checked = false,
    bool isMain = false,
    bool isRequired = false,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked
                    ? Color(0xFF477BFF)
                    : Color(0xFFD9D9D9), // ✅ 체크 여부에 따라 배경 변경
              ),
              child: checked
                  ? Icon(Icons.check, size: 16.0, color: Colors.white) // 체크된 상태
                  : Icon(Icons.check,
                      size: 16.0, color: Colors.white), // 체크 안된 상태
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    if (isRequired)
                      TextSpan(
                          text: '(필수) ',
                          style: TextStyle(color: Color(0xFFFE2D56))),
                    TextSpan(
                      text: text.replaceFirst('(필수)', ''),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isMain ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

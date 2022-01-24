import 'dart:io';
import 'package:device_information/device_information.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalm/api/api.dart';
import 'package:kalm/color/colors.dart';
import 'package:kalm/controller/user_controller.dart';
import 'package:kalm/main_tab.dart';
import 'package:kalm/model/login_payload.dart';
import 'package:kalm/model/user_model/user_model.dart';
import 'package:kalm/pages/auth/onboarding.dart';
import 'package:kalm/widget/button.dart';
import 'package:kalm/widget/safe_area.dart';
import 'package:kalm/widget/snack_bar.dart';
import 'package:kalm/widget/space.dart';
import 'package:kalm/widget/text.dart';
import 'package:kalm/widget/textfield.dart';
import 'package:wonderpush_flutter/wonderpush_flutter.dart';

class LoginPage extends StatelessWidget {
  final _controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (_) {
      return NON_MAIN_SAFE_AREA(
          child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/wave/login_wave.png'),
                alignment: Alignment.bottomCenter)),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  if (MediaQuery.of(context).viewInsets.bottom == 0.0)
                    Column(
                      children: [
                        Image.asset('assets/icon/kalm.png', scale: 2.5),
                        SPACE(),
                        Image.asset('assets/icon/login_icon.png', scale: 2.5),
                      ],
                    ),
                  TEXT_FIELD(_.emailField,
                      focusNode: _.emailFocus,
                      onSubmitted: (val) => _.onSubmittedEmail(val),
                      onChanged: (val) => _.onChangeEmail(val),
                      prefixIcon: const Icon(Icons.email_outlined),
                      hint: 'Email'),
                  SPACE(),
                  if (_.validateEmail != null) _.validateEmail!,
                  SPACE(),
                  TEXT_FIELD(_.passwodField,
                      obscureText: _.passwordObsecure,
                      onSubmitted: (val) async => await _.onSubmittedPassword(val),
                      focusNode: _.passwordFocus,
                      onChanged: (val) => _.onChangePassword(val),
                      prefixIcon:
                          Icon(_.passwordObsecure ? Icons.lock_outline : Icons.lock_open_outlined),
                      hint: "Password",
                      suffixIcon: IconButton(
                          onPressed: () => _.onChangeObsecure(),
                          icon: Icon(_.passwordObsecure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility))),
                  SPACE(),
                  if (_.validatePassword != null) _.validatePassword!,
                  SPACE(height: 20),
                  BUTTON("Masuk",
                      verticalPad: 15,
                      circularRadius: 30,
                      onPressed: _.validationForm ? () async => await _.submit() : null),
                  SPACE(),
                  BUTTON("Daftar",
                      verticalPad: 15,
                      circularRadius: 30,
                      onPressed: () => Get.to(OnBoardingPage())),
                  SPACE(height: 20),
                  _forgetPassword(_),
                ],
              ),
            )
          ],
        ),
      ));
    });
  }

  InkWell _forgetPassword(LoginController _) {
    return InkWell(
        onTap: () async {
          TextEditingController _emailController = TextEditingController();
          bool _validateEmail = false;
          await Get.bottomSheet(StatefulBuilder(builder: (context, st) {
            return Container(
                color: Colors.white,
                height: Get.height / 3.5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      TEXT("Lupa Password", style: Get.textTheme.headline2),
                      SPACE(),
                      Column(
                        children: [
                          SizedBox(
                            height: 40,
                            child: CupertinoTextField(
                              onChanged: (val) {
                                st(() {
                                  if (val.isEmail) {
                                    _validateEmail = true;
                                  } else {
                                    _validateEmail = false;
                                  }
                                });
                              },
                              placeholder: "Email",
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 0.5, color: BLUEKALM)),
                              controller: _emailController,
                            ),
                          ),
                          if (!_validateEmail && _emailController.text.length > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ERROR_VALIDATION_FIELD("Email tidak valid"),
                            )
                        ],
                      ),
                      SPACE(),
                      Row(
                        children: [
                          BUTTON(
                            "Lanjutkan",
                            onPressed: () async {
                              Get.back();
                              await _.forgotPassword(_emailController.text);
                            },
                            isExpanded: true,
                            expandedHorizontalPad: 5,
                          ),
                          BUTTON("Batalkan", onPressed: () {
                            Get.back();
                          }, isExpanded: true, expandedHorizontalPad: 5),
                        ],
                      ),
                    ],
                  ),
                ));
          }), barrierColor: BLUEKALM.withOpacity(0.6));
        },
        child: TEXT("Lupa Kata Sandi?",
            style: COSTUM_TEXT_STYLE(color: ORANGEKALM, fontWeight: FontWeight.w600)));
  }
}

class LoginController extends GetxController {
  Widget? validateEmail, validatePassword;
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  TextEditingController emailField = TextEditingController();
  TextEditingController passwodField = TextEditingController();
  bool passwordObsecure = true;
  bool get validationForm =>
      (validateEmail == null && validatePassword == null) &&
      (emailField.text.isNotEmpty && passwodField.text.isNotEmpty);

  void onChangeObsecure() {
    passwordObsecure = !passwordObsecure;
    update();
  }

  void onChangeEmail(String val) {
    if (val.isEmpty) {
      validateEmail = null;
    } else if (!val.isEmail) {
      validateEmail = ERROR_VALIDATION_FIELD("Email tidak valid");
    } else {
      // validateEmail = SUCCESS_VALIDATION_FIELD("Email Terverifikasi");
      validateEmail = null;
    }
    update();
  }

  void onChangePassword(String val) {
    if (val.isEmpty) {
      validatePassword = null;
    } else if (val.length < 6) {
      validatePassword = ERROR_VALIDATION_FIELD("Password minimal 6 digit");
    } else {
      // validatePassword = SUCCESS_VALIDATION_FIELD("Password Terverifikasi");
      validatePassword = null;
    }
    update();
  }

  void onSubmittedEmail(String val) {
    emailFocus.unfocus();
    FocusScope.of(Get.context!).requestFocus(passwordFocus);
  }

  Future<void> onSubmittedPassword(String val) async {
    validationForm ? await submit() : null;
  }

  Future<int?> _deviceNum() async {
    try {
      var _dImei = await DeviceInformation.deviceIMEINumber;
      return double.parse(_dImei.replaceAll(RegExp(r"\D"), '').replaceAll("-", "")).floor();
    } on FormatException catch (e) {
      return 000000;
    }
  }

  Future<String?> _installationId() async {
    if (Platform.localHostname == "Dayonas-MacBook-Pro.local") {
      return "test-installation";
    } else {
      try {
        return await WonderPush.getInstallationId();
      } catch (e) {
        ERROR_SNACK_BAR("Perhatian", "$e");
        return null;
      }
    }
  }

  Future<void> submit() async {
    if (await _installationId() == null) {
      ERROR_SNACK_BAR('Perhatian',
          "Anda tidak mengizinkan fitur Notifikasi di ponsel Anda\n Silahkan restart aplikasi KALM untuk mengaktifkan notifikasi kembali");
      return;
    }
    passwordFocus.unfocus();
    var _firebaseToken = await PRO.firebaseAuth.currentUser?.getIdToken();
    var _payload = LoginPayload(
        email: emailField.text,
        password: passwodField.text,
        deviceNumber: 000000,
        installationId: await _installationId(),
        deviceType: Platform.isAndroid ? 0 : 1,
        firebaseToken: _firebaseToken,
        role: "10");
    var _res = await Api().POST(AUTH, _payload.toJson());
    if (_res?.statusCode == 200) {
      var _user = UserModel.fromJson(_res?.data).data;
      await PRO.saveLocalUser(_user);
      if (_user?.userHasActiveCounselor != null) {
        await PRO.getCounselor(useLoading: true);
      }
      // await PRO.updateSession(userCode: _user?.code, token: _user?.token, useLoading: true);
      await Get.offAll(KalmMainTab());
    } else {
      return;
    }
  }

  Future<void> forgotPassword(String email) async {
    var _res = await Api().POST(FORGOT_PASSWORD, {"email": email, "role": "10"});
    if (_res?.statusCode == 200) {
      SUCCESS_SNACK_BAR("Perhatian", _res?.data['message']);
      return;
    } else {
      return;
    }
  }
}

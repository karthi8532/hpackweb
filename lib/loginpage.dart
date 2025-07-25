import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hpackweb/models/loginmodel.dart';
import 'package:hpackweb/service/apiservice.dart';
import 'package:hpackweb/utils/apputils.dart';
import 'package:hpackweb/utils/customsavebutton.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:hpackweb/widgets/assetimage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ApiService apiService = ApiService();
  bool loading = false;
  bool _obscureText = false;
  String selectedLoginType = 'Employee'; // Default

  final List<String> loginTypes = ['Employee', 'Supervisor'];
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          !loading
              ? Row(
                children: [
                  // Left panel
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.blue.shade700,
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/hpacklogo.png',
                            fit: BoxFit.fill,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Welcome back to the best. We\'re always here, waiting for you!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // Right panel
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: Center(
                        child: SizedBox(
                          width: 400,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Login to Account",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              const SizedBox(height: 20),
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  labelText: 'User Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                obscureText: !_obscureText,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: Icon(Icons.visibility_off),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: selectedLoginType,
                                items:
                                    loginTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedLoginType = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Login Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text("Forgot Password?"),
                                ),
                              ),
                              const SizedBox(height: 10),

                              SizedBox(
                                width: 400,
                                height: 40,
                                child: CustomButton(
                                  label: "Login",
                                  onPressed: () async {
                                    if (usernameController.text.isEmpty) {
                                      AppUtils.showSingleDialogPopup(
                                        context,
                                        "Please Enter UserName",
                                        "Ok",
                                        () {
                                          AppUtils.pop(context);
                                        },
                                        null,
                                      );
                                    } else if (passwordController
                                        .text
                                        .isEmpty) {
                                    } else {
                                      _handleLogin();
                                    }
                                  },
                                  isPrimary: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }

  void _handleLogin() async {
    setState(() {
      loading = true;
    });
    String loginTypeCode = selectedLoginType == 'Approver' ? 'A' : 'U';
    var body = {
      "username": usernameController.text,
      "password": passwordController.text,
      "LoginBy": loginTypeCode,
    };
    print(jsonEncode(body));
    try {
      final response = await apiService.getloginRequest(body);

      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'].toString().toLowerCase() == "true") {
          LoginModel loginModel = LoginModel.fromJson(jsonResponse);
          await addsharedpref(loginModel); // Save to prefs
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            jsonResponse['message'] ?? "Login failed",
            "Ok",
            exitpopup,
            AssetsImageWidget.errorimage,
          );
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        exitpopup,
        AssetsImageWidget.errorimage,
      );
    }
  }

  Future addsharedpref(LoginModel model) async {
    Prefs.setEmpID(model.salesEmployeeId);
    Prefs.setName(model.salesEmployeeName);
    Prefs.setLoggedIn(true);
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (Route<dynamic> route) => false,
      );
    }
  }

  void exitpopup() {
    AppUtils.pop(context);
  }
}

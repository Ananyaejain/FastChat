import 'package:chat_app/consts.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/pushNotification_service.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late PushNotificationService _pushNotificationService;

  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
    _databaseService = getIt.get<DatabaseService>();
    _pushNotificationService = getIt.get<PushNotificationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 20,
        ),
        child: Column(
          children: [
            _headerText(),
            _loginForm(),
            _loginButton(),
            _createAnAccountLink()
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, Welcome Back',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Hello Again! We missed you',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormField(
                hintText: 'Email',
                height: MediaQuery.sizeOf(context).height * 0.1,
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onSave: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              CustomFormField(
                hintText: 'Password',
                height: MediaQuery.sizeOf(context).height * 0.1,
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                obscureText: true,
                onSave: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
            ],
          )),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);
            if (result) {
              _navigationService.pushReplacementNamed(HomePageRoute);
            } else {
              _alertService.showToast(
                text: 'Failed to login, Please try again!',
                icon: Icons.error,
              );
            }
          }
        },
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _createAnAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Don't have an account?"),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed(RegisterRoute);
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

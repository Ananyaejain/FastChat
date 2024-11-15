import 'dart:io';

import 'package:chat_app/consts.dart';
import 'package:chat_app/exceptions.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/pushNotification_service.dart';
import 'package:chat_app/services/stroage_service.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  File? selectedImage;
  final GlobalKey<FormState> _registerKey = GlobalKey();
  String? email, password, name;
  final GetIt getIt = GetIt.instance;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;
  late PushNotificationService _pushNotificationService;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = getIt.get<MediaService>();
    _navigationService = getIt.get<NavigationService>();
    _authService = getIt.get<AuthService>();
    _storageService = getIt.get<StorageService>();
    _databaseService = getIt.get<DatabaseService>();
    _alertService = getIt.get<AlertService>();
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
            if (!isLoading) _registerForm(),
            if (!isLoading) _createAnAccountLink(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
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
            "Let's get going!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Register an account using the form below',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            CustomFormField(
              hintText: "Name",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegEx: NAME_VALIDATION_REGEX,
              onSave: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomFormField(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onSave: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormField(
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSave: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? _file = await _mediaService.getImageFromGallery();
        if (_file != null) {
          setState(() {
            selectedImage = _file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.sizeOf(context).width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerKey.currentState?.validate() ?? false) &&
                (selectedImage != null)) {
              _registerKey.currentState?.save();
              bool result = await _authService.register(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                  file: selectedImage!,
                  uid: _authService.user!.uid,
                );
                if (pfpURL != null) {
                  await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                      uid: _authService.user!.uid,
                      name: name,
                      pfpURL: pfpURL,
                      pushToken: await _pushNotificationService.getFirebaseMessagingToken(),
                    ),
                  );
                  _alertService.showToast(
                    text: 'User registered successfully',
                    icon: Icons.check,
                  );
                  _navigationService.goBack();
                  _navigationService.pushReplacementNamed(HomePageRoute);
                } else {
                  throw Exception('Unable to upload user');
                }
              }
            } else {
              throw UnableToRegisterUserException();
            }
          } on UnableToRegisterUserException catch (e) {
            _alertService.showToast(
              text: 'Please select a profile picture',
              icon: Icons.error,
            );
          } catch (e) {
            print(e.runtimeType);
            _alertService.showToast(
              text: 'Failed to register! Please try again',
              icon: Icons.error,
            );
          }
          setState(() {
            isLoading = false;
          });
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
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
          const Text("Do have an account?"),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              'Login',
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

import 'dart:io';
import 'package:chat_app_firebase/models/user_profile.dart';
import 'package:chat_app_firebase/services/database_service.dart';
import 'package:chat_app_firebase/services/media_service.dart';
import 'package:chat_app_firebase/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../consts.dart';
import '../services/Alert_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../widgets/custom_form.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  File? selectedImage;
  String? email, password, name;
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
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
          _buildHeader(),
          if (!isLoading) _signUpForm(),
          if (!isLoading) _registerButton(),
          if (!isLoading) _loginAccountLink(),
          if (isLoading)
            const Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ))
        ],
      ),
    ));
  }

  Widget _buildHeader() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's, get going!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            "Register an account using the form below",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _signUpForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            CustomForm(
              hintText: "Name",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: NAME_VALIDATION_REGEX,
              onSave: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomForm(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: EMAIL_VALIDATION_REGEX,
              onSave: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomForm(
              hintText: "password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSave: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
          ],
        ),
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
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _registerFormKey.currentState?.save();
              print(email);
              print(password);
              final result = await _authService.signUp(email!, password!);
              print(result);

              if (result) {
                String? pfpUrl = await _storageService.uploadUserPfp(file: selectedImage!, uid: _authService.user!.uid);
                if(pfpUrl!=null){
                  await _databaseService.createUserProfile(userProfile: UserProfile(uid: _authService.user!.uid, name: name, pfpURL: pfpUrl));
                }
                _alertService.showToast(
                    text: "User Register Successfully!",
                    icon: Icons.check);
                _navigationService.goBack();
                _navigationService.pushReplacementNamed("/home");
              } else {
                _alertService.showToast(
                    text: "Failed to login Please Try again ",
                    icon: Icons.error);
                throw Exception("Unable to upload user profile picture");
              }
            }
            setState(() {
              isLoading = false;
            });
          } catch (e) {
            throw Exception("Unable to register user");

            print(e);
          }
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLink() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
            onTap: () {
              _navigationService.pushNamed('/login');
            },
            child: const Text("Login!")),
      ],
    ));
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();

        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }
}

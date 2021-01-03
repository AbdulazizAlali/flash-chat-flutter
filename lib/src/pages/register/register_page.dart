import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/widgets/form_textfield.dart';
import 'package:flutter_firebase_chat/src/widgets/form_button.dart';
import 'package:flutter_firebase_chat/src/widgets/appbar_with_backbutton.dart';
import 'package:flutter_firebase_chat/src/widgets/customizable_listtile.dart';
import 'package:flutter_firebase_chat/src/utils/loading.dart';
import 'package:flutter_firebase_chat/src/utils/snackbar_with_color.dart';
import 'package:flutter_firebase_chat/src/pages/register/register_bloc.dart';
import 'package:flutter_firebase_chat/src/pages/auth/auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  Loading _loading;
  RegisterBloc _registerBloc;

  void _onTextFieldChanged() {
    _registerBloc.add(
      RegisterTextFieldChangedEvent(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text
      )
    );
  }

  void _signUpPressed() {
    _registerBloc.add(RegisterPressedEvent());
  }

  void _imagePressed() {
    PlatformActionSheet().displaySheet(
      context: context,
      actions: [
        ActionSheetAction(
          text: 'Take Photo',
          onPressed: () {
            Navigator.pop(context);
            _registerBloc.add(
              RegisterImageFromCameraEvent()
            );
          }
        ),
        ActionSheetAction(
          text: 'Photo from Library',
          onPressed: () {
            Navigator.pop(context);
            _registerBloc.add(
              RegisterImageFromLibraryEvent()
            );
          }
        ),
        ActionSheetAction(
          text: "Cancel",
          onPressed: () => Navigator.pop(context),
          isCancel: true,
          defaultAction: true
        )
      ]
    );
  }

  void _blocListener(context, state) {
    if (state.isLoading)
      _loading = Loading(context);
    else if (state.isSuccess) {
      _loading.close();
      BlocProvider.of<AuthBloc>(context).add(AuthLoggedInEvent());
      Navigator.pop(context);
      FocusScope.of(context).requestFocus(FocusNode());
    }
    else if (state.error.isNotEmpty) {
      _loading.close();
      SnackbarWithColor(
        context: context,
        text: state.error,
        color: Colors.red
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
        appBar: AppBarWithBackButton(),
        body: BlocListener<RegisterBloc, RegisterState>(
          listener: _blocListener,
          child: BlocBuilder<RegisterBloc, RegisterState>(
            builder: (_, state) => ListView(
              padding: EdgeInsets.fromLTRB(30, 22, 30, 30),
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 34),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: blackColor
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: CustomizableListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: blueColor,
                      child: Icon(
                        Icons.camera_alt,
                        color: whiteColor
                      ),
                      backgroundImage: (state.imageFile != null) ?
                        FileImage(state.imageFile) : null
                    ),
                    title: 'Upload a profile picture',
                    onTap: _imagePressed
                  )
                ),
                FormTextField(
                  hintText: 'Username',
                  controller: _usernameController,
                  onChanged: _onTextFieldChanged
                ),
                FormTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  onChanged: _onTextFieldChanged,
                  keyboardType: TextInputType.emailAddress
                ),
                FormTextField(
                  hintText: 'Password',
                  controller: _passwordController,
                  onChanged: _onTextFieldChanged,
                  obscureText: true
                ),
                FormTextField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  onChanged: _onTextFieldChanged,
                  obscureText: true
                ),
                FormButton(
                  text: 'Register',
                  onPressed: state.isValid ? _signUpPressed : null
                )
              ]
            )
          )
        )
      )
    );
  }
}
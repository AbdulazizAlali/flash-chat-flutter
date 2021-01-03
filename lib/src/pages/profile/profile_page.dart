import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/widgets/form_textfield.dart';
import 'package:flutter_firebase_chat/src/widgets/form_button.dart';
import 'package:flutter_firebase_chat/src/widgets/raw_icon_button.dart';
import 'package:flutter_firebase_chat/src/widgets/customizable_listtile.dart';
import 'package:flutter_firebase_chat/src/utils/loading.dart';
import 'package:flutter_firebase_chat/src/utils/confirm_alert.dart';
import 'package:flutter_firebase_chat/src/utils/snackbar_with_color.dart';
import 'package:flutter_firebase_chat/src/pages/profile/profile_bloc.dart';
import 'package:flutter_firebase_chat/src/pages/auth/auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin<ProfilePage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  Loading _loading;
  ProfileBloc _profileBloc;

  void _onTextFieldChanged() {
    _profileBloc.add(
      ProfileTextFieldChangedEvent(
        username: _usernameController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text
      )
    );
  }

  void _savePressed() {
    _profileBloc.add(
      ProfileSaveEvent()
    );
  }

  void _imagePressed() {
    PlatformActionSheet().displaySheet(
      context: context,
      actions: [
        ActionSheetAction(
          text: 'Take Photo',
          onPressed: () {
            Navigator.pop(context);
            _profileBloc.add(
              ProfileImageFromCameraEvent()
            );
          }
        ),
        ActionSheetAction(
          text: 'Photo from Library',
          onPressed: () {
            Navigator.pop(context);
            _profileBloc.add(
              ProfileImageFromLibraryEvent()
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

  void _logoutPressed() {
    ConfirmAlert(
      context: context,
      title: 'Are you sure you want to logout?',
      onConfirm: () {
        BlocProvider.of<AuthBloc>(context).add(
          AuthLoggedOutEvent()
        );
      }
    );
  }

  void _blocListener(context, state) {
    if (state.isLoading)
      _loading = Loading(context);
    else if (state.isSuccess) {
      _loading.close();
      SnackbarWithColor(
        context: context,
        text: 'Saved'
      );
    }
    else if (state.error.isNotEmpty) {
      _loading.close();
      SnackbarWithColor(
        context: context,
        text: state.error,
        color: Colors.red
      );
    }
    else if (state.isFetched) {
      _usernameController.text = state.profileData.username;
      _emailController.text = state.profileData.email;
      _passwordController.text = state.profileData.password;
      _confirmPasswordController.text = state.profileData.confirmPassword;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _profileBloc.add(ProfileFetchEvent());
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
    super.build(context);
    return Scaffold(
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: _blocListener,
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (_, state) => SafeArea(
            child: ListView(
              padding: EdgeInsets.all(30),
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 34),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: blackColor
                        )
                      )
                    ),
                    RawIconButton(
                      height: 38,
                      padding: EdgeInsets.only(left: 10),
                      icon: Icon(
                        Icons.exit_to_app,
                        color: blackColor,
                        size: 25
                      ),
                      onPressed: _logoutPressed
                    )
                  ])
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
                      backgroundImage: (state.profileData.imageFile != null) ?
                        FileImage(state.profileData.imageFile) :
                        ((state.profileData.imageUrl != null) ?
                        NetworkImage(state.profileData.imageUrl) : null)
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
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true
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
                  text: 'Save',
                  onPressed: state.isValid ? _savePressed : null
                )
              ]
            ),
          )
        )
      )
    );
  }
}
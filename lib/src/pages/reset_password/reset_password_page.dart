import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/widgets/appbar_with_backbutton.dart';
import 'package:flutter_firebase_chat/src/widgets/form_textfield.dart';
import 'package:flutter_firebase_chat/src/widgets/form_button.dart';
import 'package:flutter_firebase_chat/src/utils/loading.dart';
import 'package:flutter_firebase_chat/src/utils/snackbar_with_color.dart';
import 'package:flutter_firebase_chat/src/pages/reset_password/reset_password_bloc.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController _emailController = TextEditingController();
  Loading _loading;
  ResetPasswordBloc _resetPasswordBloc;

  void _onTextFieldChanged() {
    _resetPasswordBloc.add(
      ResetPasswordTextFieldChangedEvent(
        email: _emailController.text
      )
    );
  }

  void _resetPasswordPressed() {
    _resetPasswordBloc.add(
      ResetPasswordPressedEvent()
    );
  }

  void _blocListener(context, state) {
    if (state.isLoading)
      _loading = Loading(context);
    else if (state.isSuccess) {
      _emailController.text = '';
      _onTextFieldChanged();
      _loading.close();
      SnackbarWithColor(
        context: context,
        text: 'An email has been sent. Please click the link when you get it.'
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
  }

  @override
  void initState() {
    super.initState();
    _resetPasswordBloc = BlocProvider.of<ResetPasswordBloc>(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
        appBar: AppBarWithBackButton(),
        body: BlocListener<ResetPasswordBloc, ResetPasswordState>(
          listener: _blocListener,
          child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            builder: (_, state) => ListView(
              padding: EdgeInsets.fromLTRB(30, 22, 30, 30),
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: blackColor
                    )
                  )
                ),
                FormTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  onChanged: _onTextFieldChanged,
                  keyboardType: TextInputType.emailAddress
                ),
                FormButton(
                  text: 'Reset Password',
                  onPressed: state.isValid ? _resetPasswordPressed : null
                )
              ]
            )
          )
        )
      )
    );
  }
}
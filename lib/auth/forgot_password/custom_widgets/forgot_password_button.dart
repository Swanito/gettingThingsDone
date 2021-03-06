import 'package:flutter/material.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback _onPressed;

  ForgotPasswordButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      onPressed: _onPressed,
      child: Text('Recuperar contraseña'),
    );
  }
}

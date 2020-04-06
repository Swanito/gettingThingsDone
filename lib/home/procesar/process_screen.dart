import 'package:flutter/material.dart';
import 'package:gtd/common/gtd_app_bar.dart';
import 'package:gtd/core/repositories/remote/user_repository.dart';

class ProcessScreen extends StatelessWidget {
  final UserRepository _userRepository;

  ProcessScreen({Key key, UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GTDAppBar(title: 'Procesar'),
        ],
      ),
    );
  }
}

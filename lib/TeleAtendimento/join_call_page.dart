import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'join_call_page_mobile.dart';
import 'join_call_page_web.dart';

class JoinCallPage extends StatelessWidget {
  const JoinCallPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return JoinCallPageWeb();
    } else {
      return JoinCallPageMobile();
    }
  }
}


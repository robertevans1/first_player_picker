import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'StartupPickerWidget.dart';

void main() {
  runApp(
      Phoenix(
          child: new MaterialApp(home: new StartupPickerWidget()),
      )
  );
}


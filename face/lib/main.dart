import 'package:camera/camera.dart';
import 'package:face/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/image/image_source.dart';
import 'feature/image/saveImage/presentation/cubit/disFunction_cubit.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DisplayCubit(),
      child: MaterialApp(
        theme: DartModeTheme.darkTheme,
        home: CameraPage(cameras: _cameras),
      ),
    );
  }
}

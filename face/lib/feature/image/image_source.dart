import 'package:camera/camera.dart';
import 'package:face/core/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

import '../detect_face/detect_face.dart';
import 'saveImage/presentation/cubit/disFunction_cubit.dart';
import 'saveImage/presentation/pages/display_image.dart';
import 'two_face_display.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        CameraController(widget.cameras[selectedIndex], ResolutionPreset.max);
    _initializeControllerFuture =
        _controller.initialize().then((value) => setState(() {}));
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      appBar: customAppBar(true, context),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            width: double.infinity,
            child: CameraPreview(_controller),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(60, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                bool gotTwoFace = await isFacesAretwoOrMoreOrZero(
                    InputImage.fromFilePath(image.path));
                BlocProvider.of<DisplayCubit>(context).loadImage(image);
                // print(gotTwoFace);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => gotTwoFace
                        ? DetectTwoFacePage(
                            imagePath: image.path,
                          )
                        : DisplayPhotoPage(imagePath: image.path, image: image),
                  ),
                );
              } catch (e) {
                print('Error taking photo: $e');
              }
            },
            child: null,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // select from gallary
                IconButton(
                    onPressed: () async {
                      try {
                        final image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        bool gotTwoFace = await isFacesAretwoOrMoreOrZero(
                            InputImage.fromFilePath(image!.path));
                          
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => gotTwoFace
                                ? DetectTwoFacePage(
                                    imagePath: image.path,
                                  )
                                : DisplayPhotoPage(
                                    imagePath: image.path, image: image),
                          ),
                        );
                      } catch (e) {
                        // Handle errors gracefully, e.g., show an error message
                        print(e);
                      }
                    },
                    icon: const Icon(Icons.image)),
                // rotate camera
                IconButton(
                    onPressed: () {
                      setState(() {
                        selectedIndex =
                            (selectedIndex + 1) % widget.cameras.length;
                        _controller = CameraController(
                          widget.cameras[selectedIndex],
                          ResolutionPreset.max,
                        );
                        _initializeControllerFuture = _controller
                            .initialize()
                            .then((value) => setState(() {}));
                      });
                    },
                    icon: const Icon(Icons.cached))
              ],
            ),
          )
        ],
      ),
    );
  }
}

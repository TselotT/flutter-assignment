import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../../../../core/appbar.dart';
import '../../../../../core/snack_bar.dart';
import '../../../../detect_face/detect_face.dart';
import '../cubit/disFunction_cubit.dart';

class DisplayPhotoPage extends StatefulWidget {
  final String imagePath;
  final XFile image;
  DisplayPhotoPage({Key? key, required this.imagePath, required this.image})
      : super(key: key);

  @override
  State<DisplayPhotoPage> createState() => _DisplayPhotoPageState();
}

class _DisplayPhotoPageState extends State<DisplayPhotoPage> {
  // late img.Image? modifiedImage;
  late Uint8List? modifiedImage;
  bool isEye = false;
  bool isMouth = false;
  @override
  @override
  void initState() {
    super.initState();
    modifiedImage = null;
    BlocProvider.of<DisplayCubit>(context).loadImage(widget.image);
  }

  Future<Uint8List> imageToUint8ListFromPath(XFile image) {
    return image.readAsBytes();
  }

  bool saveIsActive = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DisplayCubit, DisplayCubitState>(
      listener: (ctx, state) {
        if (state is ThrowSuccessState) {
          displaySnack(context, state.message);
        }
        if (state is ErrorState) {
          displaySnack(context, state.message);
        }
        if (state is InitialState) {
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is ImageLoaded) {
          modifiedImage = state.imageBytes;
          return Scaffold(
            appBar: customAppBar(false, context),
            body: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    width: double.infinity,
                    child:
                        //modifiedImage == null
                        //     ? Image.file(File(widget.imagePath),
                        //         fit: BoxFit.cover)
                        Image.memory(state.imageBytes,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: MediaQuery.sizeOf(context).height * 0.55),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.reply, color: Colors.white),
                        SizedBox(width: 3),
                        Text("다시찍기", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // eyes
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(60, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            isEye = true;
                            final newImg =
                                await imageToUint8ListFromPath(widget.image);
                            final result = await getFaceLandMarkPoints(
                                InputImage.fromFilePath(widget.imagePath));

                            Offset leftEye = Offset(
                                result.leftEye!.x.toDouble(),
                                result.leftEye!.y.toDouble());
                            Offset rightEye = Offset(
                                result.rightEye!.x.toDouble(),
                                result.rightEye!.y.toDouble());
                            saveIsActive = true;
                            if (modifiedImage == null) {
                              BlocProvider.of<DisplayCubit>(context)
                                  .drawEllipseOnEye(
                                newImg,
                                leftEye,
                                rightEye,
                              );
                            } else {
                              BlocProvider.of<DisplayCubit>(context)
                                  .drawEllipseOnEye(
                                modifiedImage!,
                                leftEye,
                                rightEye,
                              );
                            }

                            setState(() {});
                            // drawCircleOnEye(imagePath: widget.imagePath,isEye:isEye,isMouth:isMouth, leftEyePoint:leftEye, rightEyePoint:rightEye,);
                          },
                          child: const Text(
                            "눈",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // mouth
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(60, 60),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () async {
                            final newImg =
                                await imageToUint8ListFromPath(widget.image);
                            final result = await getFaceLandMarkPoints(
                                InputImage.fromFilePath(widget.imagePath));
                            Offset leftmouth = Offset(
                                result.leftmouth!.x.toDouble(),
                                result.leftmouth!.y.toDouble());
                            Offset rightmouth = Offset(
                                result.rightmouth!.x.toDouble(),
                                result.rightmouth!.y.toDouble());
                            saveIsActive = true;
                            if (modifiedImage == null) {
                              BlocProvider.of<DisplayCubit>(context)
                                  .drawEllipseOnMouth(
                                      newImg, leftmouth, rightmouth);
                            } else {
                              BlocProvider.of<DisplayCubit>(context)
                                  .drawEllipseOnMouth(
                                      modifiedImage!, leftmouth, rightmouth);
                            }
                            setState(() {});
                          },
                          child:
                              Text("입", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (saveIsActive) {
                          try {
                            BlocProvider.of<DisplayCubit>(context)
                                .save(modifiedImage!);
                          } catch (error) {
                            print('Error saving image: $error');
                            // Handle the error gracefully, e.g., show an error message to the user
                          }
                        } else {
                          print('unable to save');
                        }
                      },
                      child:
                          Text("저장하기", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: !saveIsActive
                              ? const ui.Color.fromARGB(255, 212, 212, 212)
                              : Color(0xFF7B8FF7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize:
                              Size(MediaQuery.sizeOf(context).width, 60)),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
          );
        }
      },
    );
  }
}

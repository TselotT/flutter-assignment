import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path; // For path manipulation
import 'package:image_gallery_saver/image_gallery_saver.dart'; // For saving to gallery


part 'disFunction_state.dart';

class DisplayCubit extends Cubit<DisplayCubitState> {
  DisplayCubit() : super(InitialState());
  Future<void> save(Uint8List imageBytes) async {
    // Replace this with your actual saving logic
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        await ImageGallerySaver.saveImage(imageBytes);
        emit(ThrowSuccessState(message: "Image is Saved"));
        emit(ImageLoaded(imageBytes));
      } else {
        emit(ErrorState("Couldn't save file"));
      }
    } catch (error) {
      print('Error saving image: $error');
      // Handle the error gracefully, e.g., show an error message to the user
    }
  }


  void loadImage(XFile image) async{
    emit(LoadingState());
    final img = await imageToUint8ListFromPath(image);
    emit(ImageLoaded(img));
  }

  // helping funciton
  Future<Uint8List> imageToUint8ListFromPath(XFile image) {
    return image.readAsBytes();
  }

  // mouth drawer

  // draw on mouth
  void drawEllipseOnMouth(
    Uint8List bytesWithCircle,
    Offset leftPoint,
    Offset rightPoint, {
    Color ellipseColor = Colors.green,
    double strokeWidth = 3.0,
  }) async {

    emit(LoadingState());
    final codec = await ui.instantiateImageCodec(bytesWithCircle);
    final frame = await codec.getNextFrame();

    final ui.Image image = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = ellipseColor
      ..style = PaintingStyle.fill
      ..strokeWidth = strokeWidth;

    canvas.drawImage(image, Offset.zero, paint);

    // Calculate center and dimensions of the ellipse
    final centerX = (leftPoint.dx + rightPoint.dx) / 2;
    final centerY = (leftPoint.dy + rightPoint.dy) / 2;
    final width = rightPoint.dx - leftPoint.dx;
    final height = math.max(20.0, width * 0.7); // Ensure a minimum height

    // Adjust width slightly for a more natural shape
    final adjustedWidth = width * 1.2;

    // Draw the ellipse with custom bounds for a smoother shape
    canvas.drawPath(
        Path()
          ..addOval(Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: adjustedWidth,
              height: height)),
        paint);

    final picture = recorder.endRecording();
    final imageBytes =
        await picture.toImage(frame.image.width, frame.image.height);
    final byteData =
        await imageBytes.toByteData(format: ui.ImageByteFormat.png);
    emit(ImageLoaded(byteData!.buffer.asUint8List()));
  }



// draw elipse on eyes
  void drawEllipseOnEye(
    Uint8List bytesWithCircle,
    Offset leftEye,
    Offset rightEye, {
    Color ellipseColor = Colors.green,
    double strokeWidth = 25.0,
  }) async {
    emit(LoadingState());
    final codec = await ui.instantiateImageCodec(bytesWithCircle);
    final frame = await codec.getNextFrame();

    final ui.Image image = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = ellipseColor
      ..style = PaintingStyle.fill
      ..strokeWidth = strokeWidth;

    canvas.drawImage(image, Offset.zero, paint);

    final halfWidth = 50.0; // Half of the desired width (12)
    final halfHeight = 30; // Half of the desired height (7)

    // Draw the ellipse with centered bounds
    canvas.drawPath(
        Path()
          ..addOval(Rect.fromCenter(
              center: leftEye, width: halfWidth * 2, height: halfHeight * 2)),
        paint);
    canvas.drawPath(
        Path()
          ..addOval(Rect.fromCenter(
              center: rightEye, width: halfWidth * 2, height: halfHeight * 2)),
        paint);
    final picture = recorder.endRecording();
    final imageBytes =
        await picture.toImage(frame.image.width, frame.image.height);
    final byteData =
        await imageBytes.toByteData(format: ui.ImageByteFormat.png);
    emit(ImageLoaded(byteData!.buffer.asUint8List()));
  }

}

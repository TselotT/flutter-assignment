import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../core/face_object.dart';

final options = FaceDetectorOptions(enableLandmarks: true);
final faceDetector = FaceDetector(options: options,);

Future<bool> isFacesAretwoOrMoreOrZero(InputImage inputImage) async{ 
  final List<Face> faces = await faceDetector.processImage(inputImage);
  return faces.length > 1 || faces.isEmpty;
}


Future<FaceLandMarkPoint> getFaceLandMarkPoints(InputImage inputImage) async{
  final List<Face> faces = await faceDetector.processImage(inputImage);
  FaceLandMarkPoint faceLandmark = FaceLandMarkPoint();
  //  final Rect boundingBox = faces[0].boundingBox;
  for (Face face in faces) {
  final double? rotX = faces[0].headEulerAngleX; // Head is tilted up and down rotX degrees
  final double? rotY = faces[0].headEulerAngleY; // Head is rotated to the right rotY degrees
  final double? rotZ = faces[0].headEulerAngleZ;

  final FaceLandmark? leftEye = face.landmarks[FaceLandmarkType.leftEye];
  final FaceLandmark? rightEye = face.landmarks[FaceLandmarkType.rightEye];
  final FaceLandmark? leftMouth = face.landmarks[FaceLandmarkType.leftMouth];
  final FaceLandmark? rightMouth = face.landmarks[FaceLandmarkType.rightMouth];

  FaceLandMarkPoint faceLandmark = FaceLandMarkPoint(leftEye: leftEye!.position, rightEye: rightEye!.position, leftmouth: leftMouth!.position,rightmouth: rightMouth!.position);
  return faceLandmark;
  }

  return FaceLandMarkPoint();
}
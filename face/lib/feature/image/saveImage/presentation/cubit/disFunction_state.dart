part of 'disFunction_cubit.dart';

abstract class DisplayCubitState {}

class InitialState extends DisplayCubitState {}

class SavingState extends DisplayCubitState {
  final Uint8List imageBytes; 
  SavingState(this.imageBytes);
}
class ImageLoaded extends DisplayCubitState{
  final Uint8List imageBytes; 
  ImageLoaded(this.imageBytes);
}
class LoadingState extends DisplayCubitState{}
class ThrowSuccessState extends DisplayCubitState {
  final String message;
  ThrowSuccessState({required this.message});
}

class ErrorState extends DisplayCubitState {
  final String message;

  ErrorState(this.message);
}
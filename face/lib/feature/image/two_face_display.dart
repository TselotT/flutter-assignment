import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/appbar.dart';

class DetectTwoFacePage extends StatefulWidget {
  final String imagePath;
  DetectTwoFacePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<DetectTwoFacePage> createState() => _DetectTwoFacePageState();
}

class _DetectTwoFacePageState extends State<DetectTwoFacePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(false, context),
      body: Center(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    width: double.infinity,
                    child:
                        Image.file(File(widget.imagePath), fit: BoxFit.cover)),
                TextButton(
                  onPressed: () {Navigator.pop(context);},
                  child: const Row(
                    children: [
                           Icon(Icons.reply,
                          color: Colors.white),
                      SizedBox(width: 3),
                      Text("다시찍기", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Container(
                  alignment: Alignment.center,
                  height: 70,
                  width: MediaQuery.sizeOf(context).width* 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: const Text(
                      '2개 이상의 얼굴이 감지되었어요!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

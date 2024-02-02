import 'package:flutter/material.dart';

AppBar customAppBar(bool back,context){
  return AppBar(
      leading: back?Container():IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.close)),
      
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
      ],
    );
}

import 'package:flutter/material.dart';
import 'package:database_proj/bottom_sheet.dart';
class Button extends StatelessWidget {
  String text;
  List attributes;
  List <TextEditingController>controllers;
  Function onClick;
  Button({super.key, required this.text, required this.attributes, required this.controllers, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){bottomSheet(text, context, attributes,controllers, onClick);},
      child: Text(text, style: TextStyle(color: Colors.white),),
      style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)
    ),
    );
  }
}

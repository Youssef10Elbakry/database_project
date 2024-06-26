import 'package:flutter/material.dart';

void bottomSheet(String queryType, BuildContext context, List attributes, List<TextEditingController>controllers, Function onClick){

  List<Widget> children = [];
  List<String> values = [];
  for(int i =0; i<attributes.length; i++){
    children.add(TextField(
      controller: controllers[i],
      decoration: InputDecoration(labelText: '${attributes[i]}'),),);
    if(i == 0){
      if(queryType == "Update") {
        children.add(SizedBox(height: 30));
        children.add(Row(
          children: [
            Text("Edit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          ],
        ));
        children.add(SizedBox(height: 15));
      }
    }
  }
  children.add(SizedBox(height: 20.0));
  children.add(ElevatedButton(
    onPressed: () {
      for(int i =0; i<controllers.length; i++){
        values.add(controllers[i].text);
      }
      onClick(queryType, values);
      Navigator.pop(context);
    },
    child: Text(queryType),
  ));

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 20,  right: 20,  left: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children
          ),
        ),
      );
    },
  );
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mysql_connection.dart';

class CoachesTab extends StatefulWidget {
  const CoachesTab({super.key});

  @override
  State<CoachesTab> createState() => _CoachesTabState();
}

class _CoachesTabState extends State<CoachesTab> {
  List Ids = [];
  int i = 0;

  @override
  Widget build(BuildContext context) {
    if(i==0){
      query("SELECT CoachID FROM coaches", "CoachID");
      i++;
    }
    return Row(
          children: [
            SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  Text("ID"),
                  Expanded(
                    child: ListView.builder(
                      itemCount: Ids.length,
                        itemBuilder: (context, int index){
                      return Text("${Ids[index]}", style: TextStyle(color: Colors.black),);
                    }),
                  )
                ],
              ),
            ),
            SizedBox(width: 20),
            Text("Name"),
            SizedBox(width: 20),
            Text("Nationality"),
            SizedBox(width: 20),
            Text("Date of Birth"),
            SizedBox(width: 20),
            Text("Won"),
            SizedBox(width: 20),
            Text("Lost"),
            SizedBox(width: 20),
          ],
        );
  }


  void query(String query, String column)async{
    var conn = await databaseConnection();
    await conn?.connect();
    try {
    var result = await conn?.execute(query);
    for (var col in result!.rows) {
      Ids.add(col.assoc()[column]);
      print(col.assoc()[column]);
    }
    print(Ids);
    } catch (e) {
    print("Error creating coaches table: $e");
    } finally {
    await conn?.close();
    }
}
}

import 'package:database_proj/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mysql_connection.dart';

class CoachesTab extends StatefulWidget {
  const CoachesTab({super.key});

  @override
  State<CoachesTab> createState() => _CoachesTabState();
}

class _CoachesTabState extends State<CoachesTab> {
  List attributes= ["CoachID", "Name", "Nationality", "DateofBirth", "Won", "Lost"];
  List Ids = [];
  List names = [];
  List nationalities = [];
  List dates = [];
  List wins = [];
  List losses = [];
  int i = 0;
  List<DataRow> rows = [];
  List<TextEditingController> coachControllersInsert = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];
  List<TextEditingController> coachControllersUpdate = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];
  List<TextEditingController> coachControllersDelete = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];
  List<TextEditingController> coachControllersFind = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];

  @override
  Widget build(BuildContext context) {
    if(i==0){
      loadDatabase();
      i++;
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(),
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Nationality')),
                  DataColumn(label: Text('Date of Birth')),
                  DataColumn(label: Text('Won')),
                  DataColumn(label: Text('Lost')),
                ],
                rows: rows
              ),
            ),
          Row(children: [
            Spacer(),
            Button(text: "Insert", attributes: attributes,controllers: coachControllersInsert, onClick: distinguisherCoaches),
            Spacer(),
            Button(text: "Update", attributes: attributes,controllers: coachControllersUpdate, onClick: distinguisherCoaches),
            Spacer(),
            Button(text: "Delete", attributes: attributes,controllers: coachControllersDelete, onClick: distinguisherCoaches),
            Spacer(),
            Button(text: "Find", attributes: attributes,controllers: coachControllersFind, onClick: distinguisherCoaches),
            Spacer()
          ],)
        ],
      ),
    );

  }


  query(String query, String column)async{
    // Ids = [];
    // names = [];
    // nationalities = [];
    // dates = [];
    // wins = [];
    // losses = [];
    // rows = [];
    var conn = await databaseConnection();
    await conn?.connect();
    try {
    var result = await conn?.execute(query);
    for (var col in result!.rows) {
      if(column == "CoachID") {Ids.add(col.assoc()[column]);
      print(col.assoc()[column]);}
      else if(column == "Name") names.add(col.assoc()[column]);
      else if(column == "Nationality") nationalities.add(col.assoc()[column]);
      else if(column == "DateOfBirth") dates.add(col.assoc()[column]);
      else if(column == "won") wins.add(col.assoc()[column]);
      else if(column == "lost") losses.add(col.assoc()[column]);
    }
    if(column == "CoachID") print("ids: $Ids");
    else if(column == "Name") print("names: $names");
    else if(column == "Nationality") print("nationalities$nationalities");
    else if(column == "DateOfBirth") print("dates = $dates");
    else if(column == "won") print("wins $wins");
    else if(column == "lost") print("losses $losses");
    } catch (e) {
    print("Error creating coaches table: $e");
    } finally {
    await conn?.close();
    }
}

void loadDatabase()async{

  await query("SELECT CoachID FROM coaches ORDER BY CoachId ASC", "CoachID");
  await query("SELECT Name FROM coaches", "Name");
  await query("SELECT Nationality FROM coaches", "Nationality");
  await query("SELECT DateOfBirth FROM coaches", "DateOfBirth");
  await query("SELECT won FROM coaches", "won");
  await query("SELECT lost FROM coaches", "lost");
  print("ids: $Ids");
  print("names: $names");
  print("nationalities$nationalities");
  print("dates = $dates");
  print("wins $wins");
  print("losses $losses");
  for (int i = 0; i < Ids.length; i++) {
    rows.add(DataRow(
      cells: [
        DataCell(Text(Ids[i])),
        DataCell(Text(names[i])),
        DataCell(Text(nationalities[i])),
        DataCell(Text(dates[i])),
        DataCell(Text(wins[i])),
        DataCell(Text(losses[i])),
      ],
    ));
  }
  setState(() {});
}

void distinguisherCoaches(String queryType, List values){
    if(queryType == "Insert") insertRow(values);
    else if(queryType == "Update") updateRow(values);
    else if(queryType == "Delete") deleteRow(values);
    else if(queryType == "Find") findRow(values);
}

Future<void> insertRow(List values) async {
  var conn = await databaseConnection();
  await conn?.connect();
  try {
    var result = await conn?.execute(
      'INSERT INTO coaches (CoachID, Name, Nationality, DateOfBirth, Won, Lost) VALUES (:id, :name, :nation, :birth, :won, :lost)',
      {
        'id': int.parse(values[0]),
        'name': values[1],
        'nation': values[2],
        'birth': values[3],
        'won': int.parse(values[4]),
        'lost': int.parse(values[5])
      },
    );
  }
  catch(e){
    print(e);
  }
  finally{
    conn?.close();
  }
  reset();
  loadDatabase();
}

Future<void> deleteRow(List values) async {
  var conn = await databaseConnection();
  await conn?.connect();
  try {
    await conn?.execute(
      '''DELETE FROM coaches WHERE CoachID>0
      ${values[0].isNotEmpty?" AND CoachID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Nationality = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND DateOfBirth = '${values[3]}'":""}
      ${values[4].isNotEmpty?" AND Won = '${values[4]}'":""}
      ${values[5].isNotEmpty?" AND CoachID = '${values[5]}'":""}
      '''
    );
  }
  catch(e){
    print("errorsss");
    print(e);
  }
  finally{
    conn?.close();
  }
  reset();
  loadDatabase();
}

Future<void> findRow(List values) async{
  reset();
  var conn = await databaseConnection();
  await conn?.connect();
  try {
    var result = await conn?.execute(
        '''SELECT * FROM coaches WHERE 1=1
      ${values[0].isNotEmpty?" AND CoachID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Nationality = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND DateOfBirth = '${values[3]}'":""}
      ${values[4].isNotEmpty?" AND Won = '${values[4]}'":""}
      ${values[5].isNotEmpty?" AND Lost = '${values[5]}'":""}
      '''
    );
    print(result!.rows.toList()[0].assoc());
    for(var row in result!.rows){
      print(1);
      Ids.add(row.assoc()["CoachID"]);
      names.add(row.assoc()["Name"]);
      nationalities.add(row.assoc()["Nationality"]);
      dates.add(row.assoc()["DateOfBirth"]);
      wins.add(row.assoc()["won"]);
      losses.add(row.assoc()["lost"]);
    }

    for (int i = 0; i < Ids.length; i++) {
      rows.add(DataRow(
        cells: [
          DataCell(Text(Ids[i])),
          DataCell(Text(names[i])),
          DataCell(Text(nationalities[i])),
          DataCell(Text(dates[i])),
          DataCell(Text(wins[i])),
          DataCell(Text(losses[i])),
        ],
      ));
    }
    print("finished");
  }
  catch(e){
    print("errorsss");
    print(e);
  }
  finally{
    conn?.close();
  }
  setState(() {});
}

Future<void> updateRow(List values)async {
  var conn = await databaseConnection();
  await conn?.connect();
  try {
    await conn?.execute(
        '''UPDATE coaches SET
      ${values[0].isNotEmpty?" CoachID = ${values[0]}":""}
      ${values[1].isNotEmpty?", Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?", Nationality = '${values[2]}'":""}
      ${values[3].isNotEmpty?", DateOfBirth = '${values[3]}'":""}
      ${values[4].isNotEmpty?", Won = '${values[4]}'":""}
      ${values[5].isNotEmpty?", lost = '${values[5]}'":""}
      WHERE CoachID = ${values[0]}
      '''
    );
  }
  catch(e){
    print("errorsss");
    print(e);
  }
  finally{
    conn?.close();
  }
  reset();
  loadDatabase();
}

void reset(){
  Ids = [];
  names = [];
  nationalities = [];
  dates = [];
  wins = [];
  losses = [];
  rows = [];
}
}

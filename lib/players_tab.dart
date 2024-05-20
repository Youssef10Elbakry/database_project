import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'button.dart';
import 'mysql_connection.dart';

class PlayersTab extends StatefulWidget {
  const PlayersTab({super.key});

  @override
  State<PlayersTab> createState() => _PlayersTabState();
}

class _PlayersTabState extends State<PlayersTab> {
  List attributes= ["PlayerID", "Name", "Nationality", "DateofBirth", "Position", "goals_scored", "assists"];
  List Ids = [];
  List names = [];
  List nationalities = [];
  List dates = [];
  List positions = [];
  List goals = [];
  List assists = [];
  int i = 0;
  List<DataRow> rows = [];
  List<TextEditingController> playerControllersInsert = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];
  List<TextEditingController> playerControllersUpdate = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];
  List<TextEditingController> playerControllersDelete = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];
  List<TextEditingController> playerControllersFind = [TextEditingController(),
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
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Goals')),
                  DataColumn(label: Text('Assists')),
                ],
                rows: rows
            ),
          ),
          Row(children: [
            Spacer(),
            Button(text: "Insert", attributes: attributes,controllers: playerControllersInsert, onClick: distinguisherPlayers),
            Spacer(),
            Button(text: "Update", attributes: attributes,controllers: playerControllersUpdate, onClick: distinguisherPlayers),
            Spacer(),
            Button(text: "Delete", attributes: attributes,controllers: playerControllersDelete, onClick: distinguisherPlayers),
            Spacer(),
            Button(text: "Find", attributes: attributes,controllers: playerControllersFind, onClick: distinguisherPlayers),
            Spacer()
          ],)
        ],
      ),
    );

  }


  query(String query, String column)async{
    var conn = await databaseConnection();
    await conn?.connect();
    try {
      var result = await conn?.execute(query);
      for (var col in result!.rows) {
        if(column == "PlayerID") {Ids.add(col.assoc()[column]);
        print(col.assoc()[column]);}
        else if(column == "Name") names.add(col.assoc()[column]);
        else if(column == "Nationality") nationalities.add(col.assoc()[column]);
        else if(column == "DateOfBirth") dates.add(col.assoc()[column]);
        else if(column == "Position") positions.add(col.assoc()[column]);
        else if(column == "goals_scored") goals.add(col.assoc()[column]);
        else if(column == "assists") assists.add(col.assoc()[column]);
      }
    } catch (e) {
      print("Error creating players table: $e");
    } finally {
      await conn?.close();
    }
  }

  void loadDatabase()async{

    await query("SELECT PlayerID FROM players ORDER BY PlayerId ASC", "PlayerID");
    await query("SELECT Name FROM players", "Name");
    await query("SELECT Nationality FROM players", "Nationality");
    await query("SELECT DateOfBirth FROM players", "DateOfBirth");
    await query("SELECT Position FROM players", "Position");
    await query("SELECT goals_scored FROM players", "goals_scored");
    await query("SELECT assists FROM players", "assists");
    for (int i = 0; i < Ids.length; i++) {
      rows.add(DataRow(
        cells: [
          DataCell(Text(Ids[i])),
          DataCell(Text(names[i])),
          DataCell(Text(nationalities[i])),
          DataCell(Text(dates[i])),
          DataCell(Text(positions[i])),
          DataCell(Text(goals[i])),
          DataCell(Text(assists[i])),
        ],
      ));
    }
    setState(() {});
  }

  void distinguisherPlayers(String queryType, List values){
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
        'INSERT INTO players (PlayerID, Name, Nationality, DateOfBirth, Position, goals_scored, assists) VALUES (:id, :name, :nation, :birth, :position, :goals_scored, :assists)',
        {
          'id': int.parse(values[0]),
          'name': values[1],
          'nation': values[2],
          'birth': values[3],
          'position': values[4],
          'goals_scored': int.parse(values[5]),
          'assists': int.parse(values[6])
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
          '''DELETE FROM players WHERE PlayerID>0
      ${values[0].isNotEmpty?" AND PlayerID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Nationality = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND DateOfBirth = '${values[3]}'":""}
      ${values[4].isNotEmpty?" AND Position = '${values[4]}'":""}      
      ${values[5].isNotEmpty?" AND goals_scored = '${values[5]}'":""}
      ${values[6].isNotEmpty?" AND assists = '${values[6]}'":""}
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
          '''SELECT * FROM players WHERE 1=1
      ${values[0].isNotEmpty?" AND PlayerID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Nationality = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND DateOfBirth = '${values[3]}'":""}
      ${values[4].isNotEmpty?" AND Position = '${values[4]}'":""}
      ${values[5].isNotEmpty?" AND goals_scored = '${values[5]}'":""}
      ${values[6].isNotEmpty?" AND assists = '${values[6]}'":""}
      '''
      );
      print(result!.rows.toList()[0].assoc());
      for(var row in result!.rows){
        print(1);
        Ids.add(row.assoc()["PlayerID"]);
        names.add(row.assoc()["Name"]);
        nationalities.add(row.assoc()["Nationality"]);
        dates.add(row.assoc()["DateOfBirth"]);
        positions.add(row.assoc()["Position"]);
        goals.add(row.assoc()["goals_scored"]);
        assists.add(row.assoc()["assists"]);
      }

      for (int i = 0; i < Ids.length; i++) {
        rows.add(DataRow(
          cells: [
            DataCell(Text(Ids[i])),
            DataCell(Text(names[i])),
            DataCell(Text(nationalities[i])),
            DataCell(Text(dates[i])),
            DataCell(Text(positions[i])),
            DataCell(Text(goals[i])),
            DataCell(Text(assists[i])),
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
          '''UPDATE players SET
      ${values[0].isNotEmpty?" PlayerID = ${values[0]}":""}
      ${values[1].isNotEmpty?", Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?", Nationality = '${values[2]}'":""}
      ${values[3].isNotEmpty?", DateOfBirth = '${values[3]}'":""}
      ${values[4].isNotEmpty?", Position = '${values[4]}'":""}
      ${values[5].isNotEmpty?", goals_scored = '${values[5]}'":""}
      ${values[6].isNotEmpty?", assists = '${values[6]}'":""}
      WHERE PlayerID = ${values[0]}
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
    goals = [];
    positions = [];
    assists = [];
    rows = [];
  }
}

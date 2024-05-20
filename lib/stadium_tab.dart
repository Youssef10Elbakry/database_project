import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'button.dart';
import 'mysql_connection.dart';

class StadiumsTab extends StatefulWidget {
  const StadiumsTab({super.key});

  @override
  State<StadiumsTab> createState() => _StadiumTabState();
}

class _StadiumTabState extends State<StadiumsTab> {
  List attributes= ["StadiumID", "Name", "Location", "Capacity"];
  List Ids = [];
  List names = [];
  List locations = [];
  List capacities = [];
  int i = 0;
  List<DataRow> rows = [];
  List<TextEditingController> stadiumControllersInsert = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController()];
  List<TextEditingController> stadiumControllersUpdate = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController()];
  List<TextEditingController> stadiumControllersDelete = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController()];
  List<TextEditingController> stadiumControllersFind = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController()];

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
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Capacity')),
                ],
                rows: rows
            ),
          ),
          Row(children: [
            Spacer(),
            Button(text: "Insert", attributes: attributes,controllers: stadiumControllersInsert, onClick: distinguisherStadiums),
            Spacer(),
            Button(text: "Update", attributes: attributes,controllers: stadiumControllersUpdate, onClick: distinguisherStadiums),
            Spacer(),
            Button(text: "Delete", attributes: attributes,controllers: stadiumControllersDelete, onClick: distinguisherStadiums),
            Spacer(),
            Button(text: "Find", attributes: attributes,controllers: stadiumControllersFind, onClick: distinguisherStadiums),
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
        if(column == "StadiumID") Ids.add(col.assoc()[column]);
        else if(column == "Name") names.add(col.assoc()[column]);
        else if(column == "Location") locations.add(col.assoc()[column]);
        else if(column == "Capacity") capacities.add(col.assoc()[column]);
      }
      print("finished stadiums");
    } catch (e) {
      print("Error creating stadiums table: $e");
    } finally {
      await conn?.close();
    }
  }

  void loadDatabase()async{

    await query("SELECT StadiumID FROM stadiums ORDER BY StadiumId ASC", "StadiumID");
    await query("SELECT Name FROM stadiums", "Name");
    await query("SELECT Location FROM stadiums", "Location");
    await query("SELECT Capacity FROM stadiums", "Capacity");
    for (int i = 0; i < Ids.length; i++) {
      rows.add(DataRow(
        cells: [
          DataCell(Text(Ids[i])),
          DataCell(Text(names[i])),
          DataCell(Text(locations[i])),
          DataCell(Text(capacities[i])),
        ],
      ));
    }
    setState(() {});
  }

  void distinguisherStadiums(String queryType, List values){
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
        'INSERT INTO stadiums (StadiumID, Name, Location, Capacity) VALUES (:id, :name, :location, :capacity)',
        {
          'id': int.parse(values[0]),
          'name': values[1],
          'location': values[2],
          'capacity': values[3],
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
          '''DELETE FROM stadiums WHERE StadiumID>0
      ${values[0].isNotEmpty?" AND StadiumID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Location = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND Capacity = '${values[3]}'":""}
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
          '''SELECT * FROM stadiums WHERE 1=1
      ${values[0].isNotEmpty?" AND StadiumID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Location = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND Capacity = '${values[3]}'":""}
      '''
      );
      for(var row in result!.rows){
        print(1);
        Ids.add(row.assoc()["StadiumID"]);
        names.add(row.assoc()["Name"]);
        locations.add(row.assoc()["Location"]);
        capacities.add(row.assoc()["Capacity"]);
      }

      for (int i = 0; i < Ids.length; i++) {
        rows.add(DataRow(
          cells: [
            DataCell(Text(Ids[i].toString())),
            DataCell(Text(names[i].toString())),
            DataCell(Text(locations[i].toString())),
            DataCell(Text(capacities[i].toString())),
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
          '''UPDATE stadiums SET
      ${values[0].isNotEmpty?" StadiumID = ${values[0]}":""}
      ${values[1].isNotEmpty?", Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?", Location = '${values[2]}'":""}
      ${values[3].isNotEmpty?", Capacity = '${values[3]}'":""}
      WHERE StadiumID = ${values[0]}
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
    locations = [];
    capacities = [];
    rows = [];
  }
}

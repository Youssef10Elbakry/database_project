import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'button.dart';
import 'mysql_connection.dart';

class ClubsTab extends StatefulWidget {
  const ClubsTab({super.key});

  @override
  State<ClubsTab> createState() => _ClubsTabState();
}

class _ClubsTabState extends State<ClubsTab> {
  List attributes= ["ClubID", "Name", "Founded", "Number of Points"];
  List Ids = [];
  List names = [];
  List years = [];
  List points = [];
  int i = 0;
  List<DataRow> rows = [];
  List<TextEditingController> clubControllersInsert = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController(),];
  List<TextEditingController> clubControllersUpdate = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController()];
  List<TextEditingController> clubControllersDelete = [TextEditingController(),
    TextEditingController(),TextEditingController(), TextEditingController()];
  List<TextEditingController> clubControllersFind = [TextEditingController(),
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
                  DataColumn(label: Text('Founded')),
                  DataColumn(label: Text('Number of Points')),
                ],
                rows: rows
            ),
          ),
          Row(children: [
            Spacer(),
            Button(text: "Insert", attributes: attributes,controllers: clubControllersInsert, onClick: distinguisherClubs),
            Spacer(),
            Button(text: "Update", attributes: attributes,controllers: clubControllersUpdate, onClick: distinguisherClubs),
            Spacer(),
            Button(text: "Delete", attributes: attributes,controllers: clubControllersDelete, onClick: distinguisherClubs),
            Spacer(),
            Button(text: "Find", attributes: attributes,controllers: clubControllersFind, onClick: distinguisherClubs),
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
        if(column == "ClubID") Ids.add(col.assoc()[column]);
        else if(column == "Name") names.add(col.assoc()[column]);
        else if(column == "Founded") years.add(col.assoc()[column]);
        else if(column == "Number_of_points") points.add(col.assoc()[column]);
      }
    } catch (e) {
      print("Error creating clubs table: $e");
    } finally {
      await conn?.close();
    }
  }

  void loadDatabase()async{

    await query("SELECT ClubID FROM clubs ORDER BY ClubId ASC", "ClubID");
    await query("SELECT Name FROM clubs", "Name");
    await query("SELECT Founded FROM clubs", "Founded");
    await query("SELECT Number_of_points FROM clubs", "Number_of_points");
    for (int i = 0; i < Ids.length; i++) {
      rows.add(DataRow(
        cells: [
          DataCell(Text(Ids[i])),
          DataCell(Text(names[i])),
          DataCell(Text(years[i])),
          DataCell(Text(points[i])),
        ],
      ));
    }
    setState(() {});
  }

  void distinguisherClubs(String queryType, List values){
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
        'INSERT INTO clubs (ClubID, Name, Founded, Number_of_points) VALUES (:id, :name, :founded, :points)',
        {
          'id': int.parse(values[0]),
          'name': values[1],
          'founded': int.parse(values[2]),
          'points': int.parse(values[3]),
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
          '''DELETE FROM clubs WHERE ClubID>0
      ${values[0].isNotEmpty?" AND ClubID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Founded = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND Number_of_points = '${values[3]}'":""}
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
          '''SELECT * FROM clubs WHERE 1=1
      ${values[0].isNotEmpty?" AND ClubID = ${values[0]}":""}
      ${values[1].isNotEmpty?" AND Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?" AND Founded = '${values[2]}'":""}
      ${values[3].isNotEmpty?" AND Number_of_points = '${values[3]}'":""}
      '''
      );
      print(result!.rows.toList()[0].assoc());
      for(var row in result!.rows){
        print(1);
        Ids.add(row.assoc()["CoachID"]);
        names.add(row.assoc()["Name"]);
        years.add(row.assoc()["Founded"]);
        points.add(row.assoc()["Number_of_points"]);
      }

      for (int i = 0; i < Ids.length; i++) {
        rows.add(DataRow(
          cells: [
            DataCell(Text(Ids[i])),
            DataCell(Text(names[i])),
            DataCell(Text(years[i])),
            DataCell(Text(points[i])),
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
          '''UPDATE clubs SET
      ${values[0].isNotEmpty?" ClubID = ${values[0]}":""}
      ${values[1].isNotEmpty?", Name = '${values[1]}'":""}
      ${values[2].isNotEmpty?", Founded = '${values[2]}'":""}
      ${values[3].isNotEmpty?", Number_of_points = '${values[3]}'":""}
      WHERE ClubID = ${values[0]}
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
    years = [];
    points = [];
    rows = [];
  }
}

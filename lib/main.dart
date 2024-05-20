import 'package:database_proj/coaches_tab.dart';
import 'package:flutter/material.dart';
import 'package:database_proj/mysql_connection.dart';
import 'package:mysql1/mysql1.dart';
import 'package:mysql_client/mysql_client.dart';
void main() async{

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Widget> tabs = [CoachesTab()];
  int currIndex = 0;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/back.jpg")
          )
        ),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.purpleAccent,
              centerTitle: true,
              title: Text("Premier League", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            backgroundColor: Colors.transparent,
        bottomNavigationBar: buttomNavBar(),
        body: tabs[currIndex],
      )
      ),
    );
  }

  buttomNavBar()=> Theme(
    data: Theme.of(context).copyWith(canvasColor: Colors.purple),
    child: BottomNavigationBar(
      backgroundColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      onTap: (int index)async{
        currIndex = index;
        var conn = await databaseConnection();
        await conn?.connect();
    try {
      var result = await conn?.execute('''
        select * from clubs
      ''');
      for (var col in result!.rows) {
        print(col.assoc()['Name']);
      }
      print(result.cols.toList()[5].name);
    } catch (e) {
      print("Error creating coaches table: $e");
    } finally {
      await conn?.close();
    }
        setState(() {});
      },
        currentIndex: currIndex,
        items: const[
      BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: "Coaches",),
      BottomNavigationBarItem(
        icon:  Icon(Icons.people),
        label: "Players",),
      BottomNavigationBarItem(
        icon: Icon(Icons.sports_soccer),
        label: "Clubs",),
          BottomNavigationBarItem(
            icon: Icon(Icons.stadium),
            label: "Stadiums",),
      ]),
  );
}





// databaseConnection();
//
// // actually connect to database
//   data
//   try {
//     var result = await conn.execute('''
//       select * from clubs
//     ''');
//     for (var col in result.rows) {
//       print(col.assoc()['Name']);
//     }
//     print(result.cols.toList()[5].name);
//   } catch (e) {
//     print("Error creating coaches table: $e");
//   } finally {
//     await conn.close();
//   }
//
// }
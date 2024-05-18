import 'package:mysql_client/mysql_client.dart';

import 'main.dart';


  Future<MySQLConnection?> databaseConnection() async{
    return await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "root",
      password: "youssef@2003",
      databaseName: "premierleague", // optional
    );
}
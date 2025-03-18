import 'dart:convert';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:http/http.dart' as https;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  //create reusable database instance
  static final DatabaseService instance = DatabaseService._constructor();

  static Database? _db;
  // Table and column names
  final String _outletsTableName = "outlets";
  final String _outletsIdColumnName = "id";
  final String _outletsOutletNameColumnName = "outlet_name";
  final String _outletsImageColumnName = "image";
  final String _outletsLocationColumnName = "location_name";

  //make Database private constructor
  DatabaseService._constructor();

  //Make Singleton getter
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  //Make function responsible for handling what the database does
  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_outletsTableName(
          $_outletsIdColumnName INTEGER PRIMARY KEY,
          $_outletsOutletNameColumnName TEXT NOT NULL,
          $_outletsLocationColumnName TEXT,
          $_outletsImageColumnName TEXT
          )
          ''');
      },
    );
    return database;
  }

  // ===== CRUD METHODS FOR OUTLETS =====

  // get local outlets from the database
  Future<List<Map<String, dynamic>>> getLocalOutlets() async {
    final db = await database;
    final outlets = await db.query(_outletsTableName);

    print('Local outlets in database (${outlets.length} records):');
    for (var outlet in outlets) {
      print(outlet);
    }

    return outlets;
  }

  //Insert new outlets into local database
  Future<void> insertOutlet(Map<String, dynamic> outlet) async {
    final db = await database;
    print('Inserting outlet into local database: $outlet');
    await db.insert(
      _outletsTableName,
      {
        _outletsIdColumnName: outlet["id"],
        _outletsOutletNameColumnName: outlet["outlet_name"],
        _outletsLocationColumnName: outlet["location_name"],
        _outletsImageColumnName: outlet["image"],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Fetch outlets from the backend
  Future<List<Map<String, dynamic>>> fetchOutletsFromApi(String userId) async {
    if (userId.isEmpty) {
      throw Exception("User ID is empty!");
    }

    final String url =
        "https://bookings.flexpay.co.ke/api/merchandizer/outlets";
    final response = await https.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );

    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is Map<String, dynamic> &&
          decodedResponse.containsKey('data')) {
        final List<dynamic> data = decodedResponse['data'];

        // If it's not a list, throw an error to avoid unexpected issues
        if (data is! List) {
          throw Exception('Data field is not a List');
        }

        return data.map((outlet) => outlet as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception(
          'Failed to fetch outlets from Api. Status Code: ${response.statusCode}');
    }
  }
Future<void> syncOutletsFromApi(String userId) async {
  if (userId.isEmpty) {
    print('User ID is empty. Skipping sync.');
    return;
  }

  final apiOutlets = await fetchOutletsFromApi(userId);
  final localOutlets = await getLocalOutlets();
  final localOutletIds =
      localOutlets.map((outlet) => outlet[_outletsIdColumnName]).toSet();

  print('Syncing outlets...');
  for (var outlet in apiOutlets) {
    if (!localOutletIds.contains(outlet['id'])) {
      outlet["image"] = getOutletImage(outlet["outlet_name"]);
      print('New outlet found. Syncing: $outlet');
      await insertOutlet(outlet);
    } else {
      print('Outlet already exists locally. Skipping ID: ${outlet['id']}');
    }
  }

  print('Sync complete.');
}

Future<void> syncOutletsFromApiWithFallback(String userId) async {
  try {
    final apiOutlets = await fetchOutletsFromApi(userId);
    final localOutlets = await getLocalOutlets();
    final localOutletIds =
        localOutlets.map((outlet) => outlet[_outletsIdColumnName]).toSet();

    for (var outlet in apiOutlets) {
      if (!localOutletIds.contains(outlet['id'])) {
        outlet["image"] = getOutletImage(outlet["outlet_name"]);
        await insertOutlet(outlet);
      }
    }
  } catch (e) {
    print('syncOutletsFromApiWithFallback failed: $e');
  }
}


// Same function as you had earlier
  String getOutletImage(String outletName) {
    if (outletName.startsWith("Quickmart")) {
      return "assets/images/dashboardimages/Quickmart.png";
    } else if (outletName.startsWith("Naivas")) {
      return "assets/images/dashboardimages/Naivas.png";
    } else if (outletName.startsWith("Car and General")) {
      return "assets/images/dashboardimages/Car-and-General.png";
    } else {
      return "assets/images/dashboardimages/Default.png";
    }
  }


  Future<void> clearOutlets() async {
    final db = await database;
    await db.delete(_outletsTableName);
    print('Cleared all outlets from local database');
  }

  void debugPrintDatabase() async {
    final localOutlets = await getLocalOutlets();
    print('Current state of local database:');
    for (var outlet in localOutlets) {
      print(outlet);
    }
  }

  
}

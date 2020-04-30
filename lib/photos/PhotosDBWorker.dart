import 'package:sqflite/sqflite.dart';
import 'PhotosModel.dart';

class PhotosDBWorker {

  static final PhotosDBWorker db = PhotosDBWorker._();

  static const String DB_NAME = 'photos.db';
  static const String TBL_NAME = 'photos';
  static const String KEY_ID = 'id';
  static const String KEY_NAME = 'name';
  static const String KEY_PHONE = 'phone';
  static const String KEY_EMAIL = 'email';
  static const String KEY_BIRTHDAY = 'birthday';

  Database _db;

  PhotosDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
                  "$KEY_ID INTEGER PRIMARY KEY,"
                  "$KEY_NAME TEXT,"
                  "$KEY_PHONE TEXT,"
                  "$KEY_EMAIL TEXT,"
                  "$KEY_BIRTHDAY TEXT"
                  ")"
          );
        }
    );
  }

  @override
  Future<int> create(Photo photo) async {
    Database db = await database;
    return await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_NAME, $KEY_PHONE, $KEY_EMAIL, $KEY_BIRTHDAY) "
            "VALUES (?, ?, ?, ?)",
        [photo.name, photo.phone, photo.email, photo.birthday]
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<Photo> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _photoFromMap(values.first);
  }

  @override
  Future<List<Photo>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _photoFromMap(m)).toList() : [];
  }

  @override
  Future<int> update(Photo photo) async {
    Database db = await database;
    return await db.update(TBL_NAME, _photoToMap(photo),
        where: "$KEY_ID = ?", whereArgs: [ photo.id ]);
  }

  Photo _photoFromMap(Map<String, dynamic> map) {
    return Photo()
      ..id = map[KEY_ID]
      ..name = map[KEY_NAME]
      ..phone = map[KEY_PHONE]
      ..email = map[KEY_EMAIL]
      ..birthday = map[KEY_BIRTHDAY];
  }

  Map<String, dynamic> _photoToMap(Photo photo) {
    return Map<String, dynamic>()
      ..[KEY_ID] = photo.id
      ..[KEY_NAME] = photo.name
      ..[KEY_PHONE] = photo.phone
      ..[KEY_EMAIL] = photo.email
      ..[KEY_BIRTHDAY] = photo.birthday;
  }
}
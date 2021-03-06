// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? join(await sqflite.getDatabasesPath(), name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  HistoryDao _historyDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `History` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `content` TEXT, `ord` INTEGER, `isFinished` INTEGER, `createTime` TEXT, `history` INTEGER)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_History_title` ON `History` (`title`)');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  HistoryDao get historyDao {
    return _historyDaoInstance ??= _$HistoryDao(database, changeListener);
  }
}

class _$HistoryDao extends HistoryDao {
  _$HistoryDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _historyInsertionAdapter = InsertionAdapter(
            database,
            'History',
            (History item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'content': item.content,
                  'ord': item.ord,
                  'isFinished': item.isFinished ? 1 : 0,
                  'createTime': item.createTime,
                  'history': item.history
                }),
        _historyUpdateAdapter = UpdateAdapter(
            database,
            'History',
            ['id'],
            (History item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'content': item.content,
                  'ord': item.ord,
                  'isFinished': item.isFinished ? 1 : 0,
                  'createTime': item.createTime,
                  'history': item.history
                }),
        _historyDeletionAdapter = DeletionAdapter(
            database,
            'History',
            ['id'],
            (History item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'content': item.content,
                  'ord': item.ord,
                  'isFinished': item.isFinished ? 1 : 0,
                  'createTime': item.createTime,
                  'history': item.history
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _historyMapper = (Map<String, dynamic> row) => History(
      row['id'] as int,
      row['title'] as String,
      row['content'] as String,
      row['ord'] as int,
      (row['isFinished'] as int) != 0,
      row['createTime'] as String,
      row['history'] as int);

  final InsertionAdapter<History> _historyInsertionAdapter;

  final UpdateAdapter<History> _historyUpdateAdapter;

  final DeletionAdapter<History> _historyDeletionAdapter;

  @override
  Future<History> get(int id) async {
    return _queryAdapter.query('SELECT * FROM History where id = ? limit 1',
        arguments: <dynamic>[id], mapper: _historyMapper);
  }

  @override
  Future<List<History>> getAll() async {
    return _queryAdapter.queryList(
        'SELECT * FROM History where isFinished = 0 order by ord',
        mapper: _historyMapper);
  }

  @override
  Future<List<History>> getHistory() async {
    return _queryAdapter.queryList(
        'SELECT * FROM History where isFinished = 1 order by createTime desc',
        mapper: _historyMapper);
  }

  @override
  Future<History> getFirst() async {
    return _queryAdapter.query(
        'SELECT * FROM History where isFinished = 0 order by ord limit 1',
        mapper: _historyMapper);
  }

  @override
  Future<History> getMaxOrd() async {
    return _queryAdapter.query(
        'SELECT MAX(ord) as ord FROM History where isFinished = 0',
        mapper: _historyMapper);
  }

  @override
  Future<History> updateHistory(int id, int history) async {
    return _queryAdapter.query('update History set history = ? where id = ?',
        arguments: <dynamic>[id, history], mapper: _historyMapper);
  }

  @override
  Future<void> add(History person) async {
    await _historyInsertionAdapter.insert(
        person, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateItem(History item) async {
    await _historyUpdateAdapter.update(item, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateItems(List<History> items) async {
    await _historyUpdateAdapter.updateList(
        items, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> remove(History item) {
    return _historyDeletionAdapter.deleteAndReturnChangedRows(item);
  }
}

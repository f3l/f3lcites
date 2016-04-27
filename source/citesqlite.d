module f3lcites.sqlite;
private import std.array : empty;
public import f3lcites.db;

final class CiteSqlite : DB {
private:
    import d2sqlite3;
    import std.typecons : Nullable;
    import std.exception;
    import std.random : uniform;
    import std.algorithm : map;
    string dbname;
    Database db;
    Statement randomCite;
    Statement getCite;
    Statement addCiteQ;
    Statement modCite1;
    Statement modCite2;
    
    enum string[] prepareDB = ["CREATE TABLE IF NOT EXISTS cites(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
cite TEXT NOT NULL,
added TEXT DEFAULT (date('now')),
addedby TEXT)",
                               "CREATE TABLE IF NOT EXISTS changes(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
citeid INTEGER UNSIGNED,
changed TEXT DEFAULT (date('now')),
changedby TEXT)",
                               "CREATE VIEW IF NOT EXISTS mergecites AS SELECT cites.id, cites.cite, cites.added, cites.addedby, changes.changed, changes.changedby FROM cites LEFT JOIN changes ON cites.id = changes.citeid",
                               "CREATE VIEW IF NOT EXISTS showcites AS SELECT id, cite, added, addedby, MAX(changed), changedby FROM mergecites GROUP BY id"];
    
public:
    this(string dbname=":memory:") {
        this.dbname = dbname;
        this.db = Database(this.dbname, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);
//        scope(exit) this.db.close();
        foreach(prep; prepareDB) {
            this.db.run(prep);
        }
        this.randomCite = db.prepare(
            "SELECT * FROM showcites ORDER BY added DESC LIMIT :offset, 1");
        this.getCite = db.prepare(
            "SELECT * FROM showcites WHERE id==:id");
        this.addCiteQ = db.prepare(
            "INSERT INTO cites (cite, addedby) VALUES (:cite,:addedby)");
        this.modCite1 = db.prepare(
            "INSERT INTO changes (citeid, changedby) VALUES (:citeid, :changedby)");
        this.modCite2 = db.prepare(
            "UPDATE OR IGNORE cites SET cite = :cite WHERE id == :id");
    }
    
    ~this() {
        db.close();
    }
    
    FullCiteData getRandomCite() {
        auto records = this.db.execute("SELECT COUNT(*) FROM cites").oneValue!long;
        long offset = uniform(0, records);
        randomCite.bind(":offset", offset);
        auto resCite = randomCite.execute();
        assert(! resCite.empty());
        Row data = resCite.front();
        FullCiteData cite = toFullCiteData(data);
        randomCite.reset();
        return cite;
    }

    FullCiteData get(long id) {
        return this[id];
    }

    FullCiteData[] getAll() {
        import std.array;
        auto replyAll = this.db.execute("SELECT * FROM showcites ORDER BY id DESC");
        FullCiteData[] cites = map!(a => toFullCiteData(a))(replyAll).array();
        return cites;
    }

    long addCite(string cite, string name) {
        addCiteQ.bind(":cite", cite);
        addCiteQ.bind(":addedby", name);
        addCiteQ.execute();
        long lastid = this.db.lastInsertRowid();
        addCiteQ.reset();
        return lastid;
    }

    long modifyCite(long id, string cite, string name) {
        modCite1.bind(":citeid", id);
        modCite1.bind(":changedby", name);
        modCite2.bind(":cite", cite);
        modCite2.bind(":id", id);
        modCite1.execute();
        modCite2.execute();
        modCite1.reset();
        modCite2.reset();
        return id;
    };
    
    // Needed: opSlice
    
    /**********
     * opIndex
     *
     * Returns the nth Cite within the DB, if it exists
     * Params:
     *    id = long that specifies the ID of the cite to
     *         get
     * Returns:
     *    FullCiteData of the cite with passed id, if it exists.
     *    FullCiteData with id "0" otherwise
     */
    FullCiteData opIndex(long id)
        in {
            assert(id > 0);
        }
    body {
        getCite.bind(":id", id);
        auto resCite = getCite.execute();
        FullCiteData cite;
        if (resCite.empty) {
            cite = FullCiteData(0,"",Date(0),"",Date(0),"");
        } else {
            Row data = resCite.front();
            cite = toFullCiteData(data);
        }
        getCite.reset();
        return cite;
    }
            
private:
    /**********
     * toFullCiteData
     *
     * Parses the output of a Row after querying showcites
     * Params:
     *    data = A Row of such a query.
     * Returns: FullCiteData of the passed object
     * Note:    Will be replaced by cast-operator soon.
     */
    FullCiteData toFullCiteData(Row data) {
        int id = data.peek!int("id");
        string cite = data.peek!string("cite");
        string isostring = data.peek!string("added");
        Date added = Date.fromISOExtString(isostring);
        string addedby = data.peek!string("addedby");
        isostring = data.peek!string("MAX(changed)");
        Date changed;
        if (isostring.empty()) {
            changed = Date(0);
        } else {
            changed = Date.fromISOExtString(isostring);
        }
        string changedby = data.peek!string("changedby");
        FullCiteData result = FullCiteData(id, cite, added, addedby, changed, changedby );
        return result;
    }
}
        

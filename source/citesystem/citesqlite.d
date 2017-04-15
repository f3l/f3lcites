module citesystem.sqlite;
import citesystem.data : FullCiteData;
public import citesystem.db : DB;
import d2sqlite3;

private enum string[] PREPARE_DB = [
        "CREATE TABLE IF NOT EXISTS cites(id INTEGER PRIMARY KEY ASC AUTOINCREMENT, "
        ~ "cite TEXT NOT NULL, added TEXT DEFAULT (date('now')), addedby TEXT)", //
        "CREATE TABLE IF NOT EXISTS changes(id INTEGER PRIMARY KEY ASC AUTOINCREMENT, "
        ~ "citeid INTEGER UNSIGNED, changed TEXT DEFAULT (date('now')), changedby TEXT)", //
        "CREATE VIEW IF NOT EXISTS mergecites AS SELECT cites.id, cites.cite, cites.added, "
        ~ "cites.addedby, changes.changed, changes.changedby FROM cites LEFT JOIN changes "
        ~ "ON cites.id = changes.citeid", //
        "CREATE VIEW IF NOT EXISTS showcites AS SELECT id, cite, added, addedby, MAX(changed), "
        ~ "changedby FROM mergecites GROUP BY id"
    ];

/**
 * Sqlite implementation of the DB interface.
 */
final class CiteSqlite : DB {
private:
    import std.algorithm : map;
    import std.array : empty;
    import std.datetime : Date;
    import std.random : uniform;
    import std.typecons : Nullable;

    string dbname;
    Database db;
    Statement randomCite;
    Statement getCite;
    Statement addCiteQ;
    Statement modCite1;
    Statement modCite2;

public:
    /**
     * Creates a new Sqlite connection, including setup of the database if none exists.
     * Params:
     * dbname = Nameof the database. This defaults to a non-persistent in-memory database.
     */
    this(string dbname = ":memory:") {
        this.dbname = dbname;
        this.db = Database(this.dbname, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);
        //        scope(exit) this.db.close();
        foreach (prep; PREPARE_DB) {
            this.db.run(prep);
        }
        this.randomCite = db.prepare(
                "SELECT * FROM showcites ORDER BY added DESC LIMIT :offset, 1");
        this.getCite = db.prepare("SELECT * FROM showcites WHERE id==:id");
        this.addCiteQ = db.prepare("INSERT INTO cites (cite, addedby) VALUES (:cite,:addedby)");
        this.modCite1 = db.prepare(
                "INSERT INTO changes (citeid, changedby) VALUES (:citeid, :changedby)");
        this.modCite2 = db.prepare("UPDATE OR IGNORE cites SET cite = :cite WHERE id == :id");
    }

    ~this() {
        db.close();
    }

    /**
     * Retrieves and returns a random citation from the Database.
     * Returns:
     * The retrieved citation.
     */
    FullCiteData getRandomCite() {
        auto records = this.db.execute("SELECT COUNT(*) FROM cites").oneValue!long;
        const offset = uniform(0, records);
        randomCite.bind(":offset", offset);
        auto resCite = randomCite.execute();
        assert(!resCite.empty());
        Row data = resCite.front();
        FullCiteData cite = toFullCiteData(data);
        randomCite.reset();
        return cite;
    }

    /**
     * Returns the cite with the given id.
     * Params:
     * id = The numeric id of the citation to retrieve.
     * Returns:
     * The retrieved citation.
     */
    FullCiteData get(long id) {
        return this[id];
    }

    /**
     * Get all Cites from the database.
     * Returns:
     * An array containing all cites stored in the database.
     */
    FullCiteData[] getAll() {
        import std.array : array;

        auto replyAll = this.db.execute("SELECT * FROM showcites ORDER BY id DESC");
        FullCiteData[] cites = map!(a => toFullCiteData(a))(replyAll).array();
        return cites;
    }

    /**
     * Add a citation.
     * Params:
     * cite = The content of the citation.
     * name = Name of the person adding the cite.
     * Returns:
     * The id of the added citation.
     */
    long addCite(string cite, string name) {
        addCiteQ.bind(":cite", cite);
        addCiteQ.bind(":addedby", name);
        addCiteQ.execute();
        const lastid = this.db.lastInsertRowid();
        addCiteQ.reset();
        return lastid;
    }

    /**
     * Changes the data of a citation.
     * Params:
     * id = ID of the cite to modify.
     * cite = New content of the citation.
     * name = Name of the person modifying the citation.
     * Returns:
     * The id of the modified citation.
     */
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
    }

    // TODO: opSlice

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
            cite = FullCiteData(0, "", Date(0), "", Date(0), "");
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
        const id = data.peek!int("id");
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
        FullCiteData result = FullCiteData(id, cite, added, addedby, changed, changedby);
        return result;
    }
}

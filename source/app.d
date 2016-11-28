//module f3lcites;
import vibe.d;
import vibe.data.json;    
import std.conv;
import f3lcites.sqlite;

struct StatusReturn {
    int status;
    string message;
}

final class CiteSystem {
private:
    import std.random: uniform;

    DB db;

public:
    this(ref DB db) {
        this.db = db;
    }
    
    this(string dbKey) {
        this.db = new CiteSqlite(dbKey);
    }

    this() {
        this.db = new CiteSqlite();
    }

    void get() const {
        string title="Index";
        render!("index.dt", title);
    }

    void getIndex() const {
        get();
    }

    void getCite(long id) {
        string title ="Number "~id.to!string;
        FullCiteData cite = this.db.get(id);
        string desc = "Zitat Nr %d".format(id);
        render!("cite.dt", title, cite, desc);
    }

    void getRandomPlain() {
        FullCiteData quote = this.db.getRandomCite();
        render!("random_plain.dt", quote);
    }

    void getRandom() {
        string title = "Zufälliges Zitat";
        string desc = title;
        FullCiteData cite = this.db.getRandomCite();
        render!("cite.dt", title, cite, desc);
    }

    void getAll() {
        string title ="Alle Zitate";
        // Sort with descending key, e.g. newest quote in front
        FullCiteData[] cites = this.db.getAll();
        long llen = cites.length;
        long start = llen;
        render!("all.dt", title, cites, llen, start);
    }

    void getAdd() const {
        string title="Zitat hinzufügen";
        render!("add.dt", title);
    }

    void getModify(long id) {
        FullCiteData cite = this.db.get(id);
        string citetext = cite.cite;
        string title = "Zitat Nr. %d bearbeiten".format(id);
        render!("modify.dt", id, title, citetext);
    }

    void postDoModify(long id, string cite, string changedby) {
        string modifiedCite = this.stripCite(cite);
        long lastId = this.db.modifyCite(id, modifiedCite, changedby);
        redirect("cite?id=%d".format(lastId));
    }

    void postAdded(string cite, string name) {
        string addedCite = this.stripCite(cite);
        long lastId = this.db.addCite(cite, name);
        redirect("cite?id=%s".format(lastId));
    }

    private string stripCite(string cite) {
        // string.replace is broken in gdc without this.
        import std.array: replace;
        // the cite may contain newlines. Those might be "\n", "\r" or "\r\n"…
        string retval = cite
            .replace("\r\n", " – ")
            .replace("\r", " – ")
            .replace("\n", " – ");
        return retval;
    }
}

final class CiteApi {
    DB db;

    this(DB db) {
        this.db = db;
    }

    void getById(HTTPServerRequest req, HTTPServerResponse resp) {
        auto id = req.params["id"].to!long;
        auto contentType = "application/json";
        auto responseString = (id)
            ? this.db.get(id).toJsonString
            : FullCiteData.init.toJsonString;
        resp.writeBody(responseString, contentType);
    }

    void getRandom(HTTPServerRequest req, HTTPServerResponse resp) {
        auto contentType = "application/json";
        auto responseString = this.db.getRandomCite.toJsonString;
        resp.writeBody(responseString, contentType);
    }

    void addCite(HTTPServerRequest req, HTTPServerResponse resp) {
        auto author = req.json["author"].to!string;
        auto cite = req.json["cite"].to!string;
        auto contentType = "application/json";
        // Return Status JSON, write Error JSON!
        if (author == "") {
            resp.statusCode = 400;
            auto responseString = StatusReturn(400, "No author set.").toJsonString;
            resp.writeBody(responseString, contentType);
        }
        if (cite == "") {
            resp.statusCode = 400;
            auto responseString = StatusReturn(400, "No cite set.").toJsonString;
            resp.writeBody(responseString, contentType);
        }
        assert(author.length != 0 && cite.length != 0);
        long addedId = db.addCite(cite, author);
        if (addedId <= 0) {
            resp.statusCode = 500;
            auto responseString = StatusReturn(500, "Cite not added internally").toJsonString;
            resp.writeBody(responseString, contentType);
        } else {
            auto responseString = StatusReturn(200, "Added with ID %s".format(addedId)).toJsonString;
            resp.writeBody(responseString, contentType);
        }
    }
                 
}

shared static this() {
    // Parameter parsing
    auto settings = new HTTPServerSettings;

    ushort port;
    if(readOption("p|port", &port, "Port to run software on")) {
        settings.port = port;
    }

    string address;
    if(readOption("a|address", &address, "Addresses to listen on")) {
        // This is quie ugly. I would prefer something more straight forward.
        settings.bindAddresses =
            address.parseJson().deserializeJson!(string[])();
    }

    string dbPath;
    readOption("d|dbpath", &dbPath, "Path to SQLite DB");

    DB db;
    if (dbPath) {
        db = new CiteSqlite(dbPath);
    } else {
        db = new CiteSqlite();
    }
    
    // Web-Routing
    auto router = new URLRouter;
    auto webInterface = new CiteSystem(db);
    router.registerWebInterface(webInterface);
    auto restInterface = new CiteApi(db);
    router.get("/api/get", &(restInterface.getRandom));
    router.get("/api/get/:id", &(restInterface.getById));
    router.post("/api/add", &(restInterface.addCite));                              
    
    listenHTTP(settings, router);

    logInfo("Please open http://"
            ~ to!string(settings.bindAddresses[0])
            ~ ":"
            ~ to!string(settings.port)
            ~ "/ in your browser.");
}

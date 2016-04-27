//module f3lcites;
import vibe.d;
import std.conv;
import f3lcites.sqlite;

final class CiteSystem {
private:
    import std.random: uniform;

    DB db;

public:
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
        redirect("/cite?id=%d".format(lastId));
    }
    
    void postAdded(string cite, string name) {
        string addedCite = this.stripCite(cite);
        long lastId = this.db.addCite(cite, name);
        redirect("/cite?id=%s".format(lastId));
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

    
    
    // Web-Routing
    auto router = new URLRouter;
    router.registerWebInterface(
        (dbPath)
        ? new CiteSystem(dbPath)
        : new CiteSystem);
    listenHTTP(settings, router);

    logInfo("Please open http://"
            ~ to!string(settings.bindAddresses[0])
            ~ ":"
            ~ to!string(settings.port)
            ~ "/ in your browser.");
}

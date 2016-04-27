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

    void getRandomPlain() {
        FullCiteData quote = this.db.getRandomCite();
        render!("random_plain.dt", quote);
    }

    void getRandom() {
        string title = "Zufälliges Zitat";
        FullCiteData quote = this.db.getRandomCite();
        render!("random.dt", title, quote);
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
    
    void postAdded(string cite, string name) {
        // string.replace is broken in gdc without this.
        import std.array: replace;
        // the cite may contain newlines. Those might be "\n", "\r" or "\r\n"…
        string addedCite = cite
            .replace("\r\n", " – ")
            .replace("\r", " – ")
            .replace("\n", " – ");
        this.db.addCite(cite, name);
        redirect("");
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

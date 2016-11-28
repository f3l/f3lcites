//module f3lcites;
import vibe.d;
import vibe.data.json;    
import std.conv;
import f3lcites.sqlite;
import f3lcites.util;
import f3lcites.citesystem;
import f3lcites.citeapi;

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

module citesystem.app;

import citesystem;
import std.conv : to;
import vibe.core.args : readOption;
import vibe.core.core : runApplication;
import vibe.core.log : logInfo;
import vibe.data.json : deserializeJson, parseJson;
import vibe.http.fileserver : serveStaticFile;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings, listenHTTP;
import vibe.web.web : registerWebInterface;

void main() {
    // Parameter parsing
    auto settings = new HTTPServerSettings;
    
    ushort port;
    if (readOption("p|port", &port, "Port to run software on")) {
        settings.port = port;
    }

    string address;
    if (readOption("a|address", &address, "Addresses to listen on")) {
        // This is quite ugly. I would prefer something more straight forward.
        settings.bindAddresses = address.parseJson().deserializeJson!(string[])();
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

    router.get("/assets/cites.css", serveStaticFile("static/cites.css"));

    listenHTTP(settings, router);

    logInfo("Please open http://" ~ to!string(
            settings.bindAddresses[0]) ~ ":" ~ to!string(settings.port) ~ "/ in your browser.");
    runApplication();
}

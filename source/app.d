import citesystem;

import vibe.http.server : HTTPServerSettings;


void main() {
    import std.conv : to;
    import vibe.core.core : runApplication;
    import vibe.core.log : logInfo;
    import vibe.http.server : listenHTTP;

    auto settings = parseOptions();
    auto db = createDb(settings.dbPath);
    auto router = createRouter(db);
    
    listenHTTP(settings.httpSettings, router);

    logInfo("Please open http://" ~ to!string(
            settings.bindAddresses[0]) ~ ":" ~ to!string(settings.port) ~ "/ in your browser.");
    runApplication();
}

/**
 * Encapsules vibe-d's HTTPServerSettings as well as some other
 * settings needed for this application.
 */
private struct SettingsHolder {
    HTTPServerSettings httpSettings;
    string dbPath;

    alias httpSettings this;
}

/**
 * Parses all options needed to initialize the application.
 * Returns:
 * A SettingsHolder carrying the needed information.
 */
private auto parseOptions() {
    import vibe.core.args : readRequiredOption;

    auto settings = new HTTPServerSettings;
    settings.port = readRequiredOption!(ushort)("p|port", "Port to run software on");
    settings.bindAddresses = readRequiredOption!(string[])("a|address", "Addresses to listen on");

    auto dbPath = readRequiredOption!(string)("d|dbpath", "Path to SQLite DB");

    return SettingsHolder(settings, dbPath);
}

/**
 * Creates the HTTP Web- and Rest-Router.
 * Params:
 * db = The database handler to use for storage
 * Returns
 * A configured URLRouter instance.
 */
private auto createRouter(DB db) {
    import vibe.http.fileserver : serveStaticFile;
    import vibe.http.router : URLRouter;
    import vibe.web.web : registerWebInterface;
    import vibe.web.rest : registerRestInterface;

    auto mainRouter = new URLRouter;
    auto webInterface = new CiteSystem(db);
    mainRouter.registerWebInterface(webInterface);

    auto restInterface = new CiteApi(db);
    mainRouter.registerRestInterface(restInterface);
    // mainRouter;
    // router.get("/api/get", &(restInterface.getRandom));
    // router.get("/api/get/:id", &(restInterface.getById));
    // mainRouter.post("/api/add", &(restInterface.addCite));

    mainRouter.get("/assets/cites.css", serveStaticFile("static/cites.css"));

    return mainRouter;
}

/**
 * Creates the DB Handler necessary to store the quotes.
 * Params:
 * dbPath = The file location.
 * Returns:
 * A DB instance.
 */
private auto createDb(string dbPath) {
    if (dbPath) {
        return new CiteSqlite(dbPath);
    } else {
        return new CiteSqlite;
    }
}
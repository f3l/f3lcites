import citesystem.server;

import vibe.http.server : HTTPServerSettings;
import vibe.http.router : URLRouter;

import poodinis;

public:
// Dependenciy injection container
auto dependencies = new shared DependencyContainer();

static this() {
    dependencies.register!(CiteApiSpecs, CiteApi);
}

void main() {
    import std.conv : to;
    import std.format : format;
    import vibe.core.core : runApplication;
    import vibe.core.log : logInfo;
    import vibe.http.server : listenHTTP;

    auto settings = parseOptions();

    registerDependencies(settings);

    listenHTTP(settings.httpSettings, dependencies.resolve!URLRouter);

    logInfo(format!"Please open http://%1$s:%2$s in your browser"(settings.bindAddresses[0], settings.port));
    runApplication();
}

private:
void registerDependencies(SettingsHolder settings) {
    auto db = createDb(settings.dbPath);

    dependencies.register!(DB, CiteSqlite).existingInstance(cast(Object) db);
    dependencies.register!(CiteSystem);
    dependencies.register!URLRouter.existingInstance(createRouter);
}

/**
 * Encapsules vibe-d's HTTPServerSettings as well as some other
 * settings needed for this application.
 */
struct SettingsHolder {
    HTTPServerSettings httpSettings;
    string dbPath;

    alias httpSettings this;
}

/**
 * Parses all options needed to initialize the application.
 * Returns:
 * A SettingsHolder carrying the needed information.
 */
 SettingsHolder parseOptions() {
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
auto createRouter() {
    import vibe.http.fileserver : serveStaticFile;
    import vibe.http.router : URLRouter;
    import vibe.web.web : registerWebInterface;
    import vibe.web.rest : registerRestInterface;

    auto mainRouter = new URLRouter;

    auto webInterface = dependencies.resolve!CiteSystem;
    mainRouter.registerWebInterface(webInterface);

    auto restInterface = dependencies.resolve!CiteApiSpecs;
    mainRouter.registerRestInterface(restInterface);

    mainRouter.get("/assets/cites.css", serveStaticFile("resources/static/cites.css"));

    return mainRouter;
}

/**
 * Creates the DB Handler necessary to store the quotes.
 * Params:
 * dbPath = The file location.
 * Returns:
 * A DB instance.
 */
DB createDb(string dbPath) {
    if (dbPath) {
        return new CiteSqlite(dbPath);
    } else {
        return new CiteSqlite;
    }
}

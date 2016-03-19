import vibe.d;
import vibe.db.redis.redis;
import std.conv;
import std.string;
import std.algorithm: map;

final class CiteSystem {
    import std.random: uniform;
    import std.conv;

    enum string dbKey = "Cites";
    RedisClient redis;
    RedisDatabase db;

    this() {
        redis = new RedisClient();
        db = redis.getDatabase(0);
    }

    ~this() {
        redis.quit;
    }

    private string chooseCite() {
        size_t llen = db.llen(dbKey);
        if ( llen == 0 ) {
            return "No cites in DB";
        } else {
            size_t ranIndex = uniform(0, llen);
            return db.lindex(dbKey, ranIndex);
        }
    }

    void get()
    {
        string title="Index";
        render!("index.dt", title);
    }

    void getRandomPlain()
    {
        string quote = this.chooseCite();
        render!("random_plain.dt", quote);
    }

    void getRandom()
    {
        string title = "Random Quote";
        string quote = this.chooseCite();
        render!("random.dt", title, quote);
    }

    void getAll()
    {
        string title ="All quotes";
        auto cites = db.lrange(dbKey, 0, -1);
        size_t llen = db.llen(dbKey);
        render!("all.dt", title, cites, llen);
    }

    void getAdd()
    {
        string title="Add new Quote";
        render!("add.dt", title);
    }

    void postAdded(string cite)
    {
        db.lpush(dbKey, cite);
        redirect("");
    }
}

shared static this()
{
    auto router = new URLRouter;
    router.registerWebInterface(new CiteSystem);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8088;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);
    logInfo("Please open http://127.0.0.1:" ~ to!string(settings.port) ~ "/ in your browser.");
}

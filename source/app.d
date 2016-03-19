import vibe.d;
import vibe.db.redis.redis;
import std.conv;
import std.string;
import std.algorithm: map;

final class CiteSystem {
private:
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

    invariant{
    }

    string chooseCite() {
        size_t zlen = db.zcard(dbKey);
        if ( zlen == 0 ) {
            return "No cites in DB";
        } else {
            size_t ranIndex = uniform(0, zlen);
            // zrange has inclusive start/stop
            return db.zrange(dbKey, ranIndex, ranIndex).front.to!string;
        }
    }

public:
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
        // Sort with descending key, e.g. newest quote in front
        auto cites = db.zrevRange(dbKey, 0, -1);
        size_t llen = db.zcard(dbKey);
        render!("all.dt", title, cites, llen);
    }

    void getAdd()
    {
        string title="Add new Quote";
        render!("add.dt", title);
    }

    void postAdded(string cite)
    {
        db.zadd(dbKey, db.zcard(dbKey), cite);
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

import vibe.d;
import vibe.db.redis.redis;
import std.conv;

final class CiteSystem {
private:
    import std.random: uniform;

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

    string chooseCite() {
        size_t zlen = db.zcard(dbKey);
        if ( zlen == 0 ) {
            return "No cites in DB";
        } else {
            size_t ranIndex = uniform(0, zlen);
            // zrange has inclusive start/stop
            auto result = db.zrange(dbKey, ranIndex, ranIndex);
            // We need to make sure that noone altered the DB during
            // generation of our random value!
            if (result.hasNext) {
                return result.front.to!string;
            } else {
                return "No cites in DB";
            }
        }
    }

public:
    void get() const {
        string title="Index";
        render!("index.dt", title);
    }

    void getRandomPlain() {
        string quote = this.chooseCite();
        render!("random_plain.dt", quote);
    }

    void getRandom() {
        string title = "Random Quote";
        string quote = this.chooseCite();
        render!("random.dt", title, quote);
    }

    void getAll() {
        string title ="All quotes";
        // Sort with descending key, e.g. newest quote in front
        auto cites = db.zrevRange(dbKey, 0, -1);
        size_t llen = db.zcard(dbKey);
        render!("all.dt", title, cites, llen);
    }

    void getAdd() const {
        string title="Add new Quote";
        render!("add.dt", title);
    }

    void postAdded(string cite) {
        // string.replace is broken in gdc without this.
        import std.array: replace;
        // the cite may contain newlines. Those might be "\n", "\r" or "\r\n"…
        string addedCite = cite
            .replace("\r\n", " – ")
            .replace("\r", " – ")
            .replace("\n", " – ");
        db.zadd(dbKey, db.zcard(dbKey), addedCite);
        redirect("");
    }
}

shared static this() {
    auto router = new URLRouter;
    router.registerWebInterface(new CiteSystem);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8088;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);
    logInfo("Please open http://127.0.0.1:" ~ to!string(settings.port) ~ "/ in your browser.");
}

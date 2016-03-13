import vibe.d;
import std.conv;
import std.string;

struct Cite
{
    string text;
    
    @property string cite() const
    {
        return to!string(text);
    }

    void toString(scope void delegate(const(char)[]) sink) const
    {
        sink(text);
    }

    void edit(in string text) {
        this.text = text;
    }
}

final class CiteSystem {
    import std.random: uniform;
    import std.conv;
    private Cite[] cites;

    void get(string title="Index")
    {
        render!("index.dt", title);
    }

    void getRandom() // ~ GET random
    {
        string quote = cites[(uniform(0, cites.length))].cite;
        render!("random.dt", quote);
    }

    void getAdd(string title="Add new Quote")
    {
        render!("add.dt", title);
    }

    void postAdded(string cite)
    {
        cites ~= Cite(cite);
        redirect("");
    }
}

shared static this()
{
    auto router = new URLRouter;
    router.registerWebInterface(new CiteSystem);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);
	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}

unittest
{
    auto testcite = Cite("pheerai: That was easy");
    assert(testcite.to!string == "pheerai: That was easy");
}
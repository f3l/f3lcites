import vibe.d;
import f3lcites.cite;

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

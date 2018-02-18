module citesystem.system;

/**
 * Routing instance of the cite system.
 */
final class CiteSystem {
private:
    import citesystem.data : FullCiteData;
    import citesystem.db : DB;
    import citesystem.sqlite : CiteSqlite;
    import std.conv : to;
    import std.random : uniform;
    import std.string : format;
    import vibe.web.web : redirect, render;

    DB db;

public:
    /**
     * Creates a new System instance using the specified database instance.
     */
    this(ref DB db) {
        this.db = db;
    }

    /**
     * Default view.
     */
    void get() const {
        string title = "Index";
        render!("index.dt", title);
    }

    /**
     * Render index.
     */
    void getIndex() const {
        get();
    }

    /**
     * Render cite with given ID.
     * Params:
     * id = The numerical id of the citation to view.
     */
    void getCite(long id) {
        string title = "Number " ~ id.to!string;
        FullCiteData cite = this.db.get(id);
        string desc = "Zitat Nr %d".format(id);
        render!("cite.dt", title, cite, desc);
    }

    /**
     * Renders a random citation.
     */
    void getRandom() {
        string title = "Zufälliges Zitat";
        string desc = title;
        FullCiteData cite = this.db.getRandomCite();
        render!("cite.dt", title, cite, desc);
    }

    /**
     * Renders all citations.
     */
    void getAll() {
        string title = "Alle Zitate";
        // Sort with descending key, e.g. newest quote in front
        FullCiteData[] cites = this.db.getAll();
        const llen = cites.length;
        const start = llen;
        render!("all.dt", title, cites, llen, start);
    }

    void getAdd() const {
        string title = "Zitat hinzufügen";
        render!("add.dt", title);
    }

    /**
     * Params:
     * id = Numerical ID of the citation to modify.
     */
    void getModify(long id) {
        const FullCiteData cite = this.db.get(id);
        string citetext = cite.cite;
        string title = "Zitat Nr. %d bearbeiten".format(id);
        render!("modify.dt", id, title, citetext);
    }

    /**
     * POST-Handler for the modify action.
     * Params:
     * id = ID of the citation to modify.
     * cite = new content of the citation.
     * changedby = name of the modifying user.
     */
    void postDoModify(long id, string cite, string changedby) {
        string modifiedCite = cite;
        const lastId = this.db.modifyCite(id, modifiedCite, changedby);
        redirect("cite?id=%d".format(lastId));
    }

    /**
     * POST-Handler for adding action.
     * Params:
     * cite = Content of the citation to add.
     * name = Name of the adding user.
     */
    void postAdded(string cite, string name) {
        const lastId = this.db.addCite(cite, name);
        redirect("cite?id=%s".format(lastId));
    }
}

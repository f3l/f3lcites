module citesystem.api;

/**
 * Data as return type for several API actions.
 */
private struct StatusReturn {
    /// HTTP return status.
    int status;
    /// Additional status message.
    string message;
}

/**
 * Defines a JSON Restful API for the Citesystem.
 */
final class CiteApi {
    private import citesystem.db : DB;
    private import std.conv : to;
    private import citesystem.util : toJsonString;
    import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

    private DB db;

    /**
     * Creates a new instance using the passed database instance.
     */
    this(DB db) {
        this.db = db;
    }

    /**
     * Provides retrieving a citation by id.
     * Params:
     * req = Server request.
     * resp = Resulting response.
     */
    void getById(HTTPServerRequest req, HTTPServerResponse resp) {
        auto id = req.params["id"].to!long;
        auto contentType = "application/json";
        string responseString;
        if (id) {
            responseString = this.db.get(id).toJsonString;
        } else {
            import citesystem.data : FullCiteData;
            responseString = FullCiteData.init.toJsonString;
        }
        resp.writeBody(responseString, contentType);
    }

    /**
     * Provides a random citation.
     * Params:
     * req = Server request.
     * resp= Resulting response.
     */
    void getRandom(HTTPServerRequest req, HTTPServerResponse resp) {
        auto contentType = "application/json";
        auto responseString = this.db.getRandomCite.toJsonString;
        resp.writeBody(responseString, contentType);
    }

    /**
     * Provides a call to add a citationto the database.
     * Params:
     * req = Server request.
     * resp = Resulting response.
     */
    void addCite(HTTPServerRequest req, HTTPServerResponse resp) {
        auto author = req.json["author"].to!string;
        auto cite = req.json["cite"].to!string;
        auto contentType = "application/json";
        // Return Status JSON, write Error JSON!
        if (author == "" || author == "undefined") {
            resp.statusCode = 400;
            auto responseString = StatusReturn(400, "No author set.").toJsonString;
            resp.writeBody(responseString, contentType);
        }
        if (cite == "" || cite == "undefined") {
            resp.statusCode = 400;
            auto responseString = StatusReturn(400, "No cite set.").toJsonString;
            resp.writeBody(responseString, contentType);
        }
        assert(author.length != 0 && cite.length != 0);
        long addedId = db.addCite(cite, author);
        if (addedId <= 0) {
            resp.statusCode = 500;
            auto responseString = StatusReturn(500, "Cite not added internally").toJsonString;
            resp.writeBody(responseString, contentType);
        } else {
            import std.string : format;
            auto responseString = StatusReturn(200, "Added with ID %s".format(addedId)).toJsonString;
            resp.writeBody(responseString, contentType);
        }
    }
                 
}

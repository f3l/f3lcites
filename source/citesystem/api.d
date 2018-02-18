module citesystem.api;

import citesystem.db;
import citesystem.util;
import std.conv : to;
import std.string : format;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

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
        auto responseString = (id)
            ? this.db.get(id).toJsonString
            : FullCiteData.init.toJsonString;
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
            auto responseString = StatusReturn(200, "Added with ID %s".format(addedId)).toJsonString;
            resp.writeBody(responseString, contentType);
        }
    }
                 
}

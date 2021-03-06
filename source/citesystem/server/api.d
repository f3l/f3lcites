module citesystem.server.api;

import citesystem.rest;

import vibe.data.json : Json;
import vibe.web.rest : path, method;
import vibe.http.common : HTTPMethod;

/**
 * Defines a JSON Restful API for the Citesystem.
 */
final class CiteApi : CiteApiSpecs {
    private import citesystem.server.db : DB;
    private import std.conv : to;
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
    override FullCiteData getById(int id) @safe {
        if (id >= 0) {
            return this.db.get(id);
        } else {
            return FullCiteData.init;
        }
    }

    /**
     * Provides a random citation.
     * Params:
     * req = Server request.
     * resp= Resulting response.
     */
    override FullCiteData getRandom() {
        return this.db.getRandomCite;
    }

    /**
     * Provides a call to add a citationto the database.
     * Params:
     * req = Server request.
     * resp = Resulting response.
     */
    override StatusReturn addCite(string author, string cite) {
        import std.format : format;

        if(author == "" || author == "undefined") {
            return StatusReturn(400, "No author set.");
        }
        if(cite == "" || cite == "undefined") {
            return StatusReturn(400, "No author set.");
        }

        const addedId = this.db.addCite(cite, author);
        if(addedId <= 0) {
            return StatusReturn(500, "Cite not added due to internal problems.");
        }

        return StatusReturn(200, "Added with ID %s".format(addedId));
    }
}

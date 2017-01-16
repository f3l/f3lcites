module f3lcites.citeapi;
import vibe.data.json;
import vibe.http.server;
import std.conv;
import f3lcites.db;
import f3lcites.util;
import std.string : format;

final class CiteApi {
    DB db;

    this(DB db) {
        this.db = db;
    }

    void getById(HTTPServerRequest req, HTTPServerResponse resp) {
        auto id = req.params["id"].to!long;
        auto contentType = "application/json";
        auto responseString = (id)
            ? this.db.get(id).toJsonString
            : FullCiteData.init.toJsonString;
        resp.writeBody(responseString, contentType);
    }

    void getRandom(HTTPServerRequest req, HTTPServerResponse resp) {
        auto contentType = "application/json";
        auto responseString = this.db.getRandomCite.toJsonString;
        resp.writeBody(responseString, contentType);
    }

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

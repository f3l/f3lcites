module citesystem.rest.apispecs;

import vibe.web.rest : path, method;

/**
 * The specification of the Rest API.
 */
@path("/api")
interface CiteApiSpecs {
    private import citesystem.rest.data : FullCiteData;
    private import citesystem.rest.statusreturn : StatusReturn;
    private import vibe.http.common : HTTPMethod;

    /**
     * Fetches a cite by id.
     * Params:
     * _id = The id to search for.
     * Returns:
     * A (possibly empty) instance of FullCiteData.
     */
    @safe
    @path("/get/:id")
    @method(HTTPMethod.GET)
    FullCiteData getById(int _id);

    /**
     * Fetches a random cite from the DB.
     * Returns:
     * A (possibly empty) instance of FullCiteData.
     */
    @safe
    @path("/get")
    @method(HTTPMethod.GET)
    FullCiteData getRandom();
 
    /**
     * Adds a posted cite to the Db.
     * Params:
     * author = The name of the author
     * cite = The actual quote.
     * Returns:
     * A StatusReturn containing the API return value
     * and a message.
     */
    @safe
    @path("/add")
    @method(HTTPMethod.POST)
    StatusReturn addCite(string author, string cite);
}

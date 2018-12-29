module citesystem.server.db;

/**
 * Defines a commoninterface for Database adaptors.
 */
interface DB {
    import citesystem.rest : FullCiteData;
    /// Retrieve a random citation.
    FullCiteData getRandomCite() @safe;
    /// Retrieve a cite by numerical id.
    FullCiteData get(long) @safe;
    /// dito
    FullCiteData opIndex(long);
    /// Retrieve all cites.
    FullCiteData[] getAll();
    /// Retrieve paginated.
    FullCiteData[] getPaginated(size_t pagesize, size_t startcount);
    /// Add a citeation.
    long addCite(string, string) @safe;
    /// Modify a citation.
    long modifyCite(long, string, string);
}

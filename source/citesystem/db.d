module citesystem.db;

/**
 * Defines a commoninterface for Database adaptors.
 */
interface DB {
    import citesystem.data;
    /// Retrieve a random citation.
    FullCiteData getRandomCite();
    /// Retrieve a cite by numerical id.
    FullCiteData get(long);
    /// dito
    FullCiteData opIndex(long);
    /// Retrieve all cites.
    FullCiteData[] getAll();
    /// Add a citeation.
    long addCite(string, string);
    /// Modify a citation.
    long modifyCite(long, string, string);
}

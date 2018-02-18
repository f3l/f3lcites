module citesystem.data;

public import std.datetime : Date;

import vibe.data.json;

/**
 * Data class holding information on a single citation.
 */
struct FullCiteData {
    /// Numeric ID.
    long id;
    /// Citation content.
    string cite;
    /// Date of first entry.
    Date added;
    /// Name of the person who added the citation.
    string addedby;
    /// Date of last 
    Date changed;
    /// Name of person who last modified the citation.
    string changedby;
}

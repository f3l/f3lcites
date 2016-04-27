module f3lcites.citedata;
public import std.datetime;

struct FullCiteData {
    long id;
    string cite;
    Date added;
    string addedby;
    Date changed;
    string changedby;
}

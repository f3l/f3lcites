module f3lcites.citedata;
public import std.datetime;

import vibe.data.json;

struct FullCiteData {
    long id;
    string cite;
    Date added;
    string addedby;
    Date changed;
    string changedby;

}

Json toJson(T)(T input) {
    return input.serializeToJson();
}

string toJsonString(T)(T input) {
    return input.toJson.to!string;
}


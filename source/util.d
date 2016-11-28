module f3lcites.util;
import vibe.data.json;

struct StatusReturn {
    int status;
    string message;
}

Json toJson(T)(T input) {
    return input.serializeToJson();
}

string toJsonString(T)(T input) {
    return input.toJson.to!string;
}

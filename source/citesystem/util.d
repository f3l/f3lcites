module citesystem.util;

/**
 * Convenience function that serializes input to JSON.
 * Params:
 * input = Data to serialize
 * T = type of the data to parse
 * Returns:
 * The JSON representation of input.
 */
auto toJson(T)(T input) {
    import vibe.data.json : serializeToJson;
    return input.serializeToJson();
}

/**
 * Convenience function that creates a JSON-compatible string from an object.
 * Params:
 * T = type of the data to transform.
 * input = object to transfer
 * Returns:
 * The JSON string representation of the input object.
 */
string toJsonString(T)(T input) {
    import vibe.data.json;
    return input.toJson.to!string;
}

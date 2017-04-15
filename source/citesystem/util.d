module citesystem.util;
import vibe.data.json;

/**
 * Convenience function that serializes input to JSON.
 * Params:
 * input = Data to serialize
 * T = type of the data to parse
 * Returns:
 * The JSON representation of input.
 */
Json toJson(T)(T input) {
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
    return input.toJson.to!string;
}

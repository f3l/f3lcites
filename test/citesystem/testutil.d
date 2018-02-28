module test.citesystem.testutil;

import unit_threaded;
import unit_threaded.should;

@("Util.toJsonString")
@safe unittest {
    import citesystem.util : toJsonString;
    1.toJsonString.shouldEqual("1");
    ["1", "2"].toJsonString.shouldEqual(q{["1","2"]});
    "foo".toJsonString.shouldEqual("foo");
}

@("Util.toJson")
@safe unittest {
    import citesystem.util : toJson;
    import vibe.data.json : Json;
    "1".toJson()
        .shouldEqual(Json("1"));
    1.toJson()
        .shouldEqual(Json(1));
    TestStruct(1, "foo", [1,2,3])
        .toJson()
        .shouldEqual(
            Json([
                "i": Json(1),
                "s": Json("foo"),
                "a": Json([
                    Json(1),
                    Json(2),
                    Json(3)
                ])
            ])
        );
}

private struct TestStruct {
    int i;
    string s;
    int[] a;
}

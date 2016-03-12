module f3lcites.cite;

import std.datetime: DateTime;
import std.conv;
import std.string;

struct Cite
{
    string text;
    
    @property string cite() const
    {
        return to!string(text);
    }

    void toString(scope void delegate(const(char)[]) sink) const
    {
        sink(text);
    }

    void edit(in string text) {
        this.text = text;
    }
}

unittest
{
    auto testcite = Cite("pheerai: That was easy");
    assert(testcite.to!string == "pheerai: That was easy");
}

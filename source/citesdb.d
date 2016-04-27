module f3lcites.db;
public import f3lcites.citedata;

interface DB {
    FullCiteData getRandomCite();
    FullCiteData get(size_t);
    FullCiteData opIndex(size_t);
    FullCiteData[] getAll();
    void addCite(string, string);
    void modifyCite(size_t, string, string);
}


module f3lcites.db;
public import f3lcites.citedata;

interface DB {
    FullCiteData getRandomCite();
    FullCiteData get(long);
    FullCiteData opIndex(long);
    FullCiteData[] getAll();
    long addCite(string, string);
    long modifyCite(long, string, string);
}


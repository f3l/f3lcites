module citesystem.server.paginationinfo;

private import diet.dom : Node;

public struct PaginationInfo {
    const size_t pagesize;
    const size_t currentPage;
    const size_t numberOfElements;

    this(size_t page, size_t pagesize,size_t count) {
        this.currentPage = page;
        this.pagesize = pagesize;
        this.numberOfElements = count;
    }

    @property
    size_t lastPage() const {
        auto numberOfFullPages = numberOfElements / pagesize;
        if (numberOfElements % pagesize != 0) {
            return numberOfFullPages + 1;
        } else {
            return numberOfFullPages;
        }
    }

    @property
    size_t[] pagesToShow() const {
        import std.range : iota;
        import std.array : array;

        auto firstPageLabel = firstPageLabel();
        // assert(firstPageLabel > 0);
        auto lastPageLabel = lastPageLabel();
        // assert(lastPageLabel <= lastPage);
        return iota(firstPageLabel, lastPageLabel + 1).array();
    }

    private ulong firstPageLabel() const {
        return (currentPage > 3) ? currentPage - 3 : 1;
    }

    private ulong lastPageLabel() const {
        import std.algorithm.comparison : min;
        return min(currentPage + 3, lastPage);
    }

    @property
    size_t firstCiteOffset() const {
        return (pagesize * (currentPage - 1));
    }

    @property
    size_t lastCite() const {
        import std.algorithm.comparison : min;
        return min(
            pagesize * currentPage,
            numberOfElements
        );
    }

    @property
    Node[] allMarks() const {
        import diet.parser : parseDietRaw, identity;
        import diet.input : InputFile;
        InputFile inputFile = InputFile("pageinationInfo-footer", q{a(href="https://pheerai.de/") HP});

        return parseDietRaw!identity(inputFile);
    }

    @property
    bool needsFrontTruncation() const {
        return firstPageLabel != 1;
    }

    @property
    bool needsBackTruncation() const {
        return lastPageLabel != lastPage;
    }

    @property
    bool needsNextPage() const {
        return currentPage != lastPage;
    }

    @property
    bool needsPreviousPage() const {
        return currentPage != 1;
    }
}

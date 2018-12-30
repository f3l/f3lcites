module citesystem.server.paginationinfo;

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
    const size_t lastPage() {
        auto numberOfFullPages = numberOfElements / pagesize;
        if (numberOfFullPages % pagesize == 0) {
            return numberOfFullPages + 1;
        } else {
            return numberOfFullPages;
        }
    }

    @property
    const size_t[] pagesToShow() {
        import std.algorithm.comparison : min, max;
        import std.range : iota;
        import std.array : array;

        auto firstPageLabel = (currentPage > 3) ? currentPage - 3 : 1;
        // assert(firstPageLabel > 0);
        auto lastPageLabel = min(currentPage + 3, lastPage);
        // assert(lastPageLabel <= lastPage);
        return iota(firstPageLabel, lastPageLabel + 1).array();
    }

    @property
    const size_t firstCiteOffset() {
        return (pagesize * (currentPage - 1));
    }

    @property
    const size_t lastCite() {
        import std.algorithm.comparison : min;
        return min(
            pagesize * currentPage,
            numberOfElements
        );
    }
}

module citesystem.server.paginationinfo;

public struct PaginationInfo {
    const size_t pagesize;
    const size_t currentPage;
    const size_t numberOfElements;

    this(size_t page, size_t pagesize,size_t count) {
        this.currentPage = page;
        this.pagesize = pagesize;
        numberOfElements = count;
    }

    @property
    const size_t lastPage() {
        return (numberOfElements / pagesize) + 1;
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
    const size_t firstCite() {
        return (pagesize * (currentPage - 1)) + 1;
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
@system {
    unittest {
        import std.stdio : writeln;
        import std.format : format;

        auto testPaginationInfo = PaginationInfo(1, 10, 5);
        auto actualLastPage = testPaginationInfo.lastPage;
        auto expectedLastPage = 1;

        assert(actualLastPage == expectedLastPage,
            format!("Got %s for last page, expected %s.")(actualLastPage, expectedLastPage)
        );
    }
    unittest {
        import std.stdio : writeln;
        import std.format : format;

        auto testPaginationInfo = PaginationInfo(1, 10, 105)
        actualLastPage = testPaginationInfo.lastPage;
        expectedLastPage = 11;
        assert(actualLastPage == expectedLastPage,
            format!("Got %s for last page, expected %s.")(actualLastPage, expectedLastPage)
        );
    }
    unittest {
        import std.stdio : writeln;
        import std.format : format;

        auto testPaginationInfo = PaginationInfo(1, 10, 5);
        auto paginationLables = testPaginationInfo.pagesToShow;
        auto paginationLabelNumber = paginationLables.length;
        assert(
            paginationLabelNumber == 1,
            format!("Single page calculates wrong list of labels to print: %s instead of %s.\nLabel list was %s")
                (paginationLabelNumber, 1, paginationLables));
    }

    unittest {
        auto testPaginationInfo = PaginationInfo(4, 10, 105);
        paginationLables = testPaginationInfo.pagesToShow;
        paginationLabelNumber = paginationLables.length;
        assert(
            paginationLabelNumber == 7,
            format!("Single page calculates wrong list of labels to print: %s instead of %s.\nLabel list was %s")
                (paginationLabelNumber, 7, paginationLables));
        assert(
            paginationLables[0] == 1,
            format!("First label to print was %s, should have been %s")(paginationLables[0], 1));
    }
}

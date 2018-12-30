module citesystem.server.pageinationinfo;

public struct PageinationInfo {
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

        auto testPageinationInfo = PageinationInfo();
        testPageinationInfo.pagesize = 10;
        testPageinationInfo.currentPage = 1;
        testPageinationInfo.numberOfElements = 5;

        auto actualLastPage = testPageinationInfo.lastPage;
        auto expectedLastPage = 1;

        assert(actualLastPage == expectedLastPage,
            format!("Got %s for last page, expected %s.")(actualLastPage, expectedLastPage)
        );

        testPageinationInfo.numberOfElements = 105;
        actualLastPage = testPageinationInfo.lastPage;
        expectedLastPage = 11;
        assert(actualLastPage == expectedLastPage,
            format!("Got %s for last page, expected %s.")(actualLastPage, expectedLastPage)
        );
    }
    unittest {
        import std.stdio : writeln;
        import std.format : format;

        auto testPageinationInfo = PageinationInfo();
        testPageinationInfo.pagesize = 10;
        testPageinationInfo.currentPage = 1;
        testPageinationInfo.numberOfElements = 5;

        auto paginationLables = testPageinationInfo.pagesToShow;
        auto pageinationLabelNumber = paginationLables.length;
        assert(
            pageinationLabelNumber == 1,
            format!("Single page calculates wrong list of labels to print: %s instead of %s.\nLabel list was %s")
                (pageinationLabelNumber, 1, paginationLables));

        testPageinationInfo.currentPage = 4;
        testPageinationInfo.numberOfElements = 105;
        paginationLables = testPageinationInfo.pagesToShow;
        pageinationLabelNumber = paginationLables.length;
        assert(
            pageinationLabelNumber == 7,
            format!("Single page calculates wrong list of labels to print: %s instead of %s.\nLabel list was %s")
                (pageinationLabelNumber, 7, paginationLables));
        assert(
            paginationLables[0] == 1,
            format!("First label to print was %s, should have been %s")(paginationLables[0], 1));
    }
}

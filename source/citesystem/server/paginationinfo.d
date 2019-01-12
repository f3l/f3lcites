module citesystem.server.paginationinfo;

private import diet.dom : Node;

/**
 * Provides information necessary to display and perform
 * pagination.
 */
public struct PaginationInfo {
    /// How many elements should be on one page
    const size_t pagesize;
    /// Which page we are currently on
    const size_t currentPage;

    private const size_t numberOfElements;

    /**
     * Initialize using information necessary at page call.
     * Params:
     *     page =   the current page number
     *     pagesize =   elements on one page
     *     numberOfElements =   elements in total
     */
    this(size_t page, size_t pagesize, size_t numberOfElements) {
        this.currentPage = page;
        this.pagesize = pagesize;
        this.numberOfElements = numberOfElements;
    }

    /// The page number of the last page containing at least on item.
    @property
    size_t lastPage() const {
        auto numberOfFullPages = numberOfElements / pagesize;
        if (numberOfElements % pagesize != 0) {
            return numberOfFullPages + 1;
        } else {
            return numberOfFullPages;
        }
    }

    /// The pagenumbers of all pages that should be shown in the pagination section.
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

    /// Pagenumber of the first page to show in the pagination template.
    private ulong firstPageLabel() const {
        return (currentPage > 3) ? currentPage - 3 : 1;
    }

    /// Pagenumber of the last page to include in the pagination template.
    private ulong lastPageLabel() const {
        import std.algorithm.comparison : min;
        return min(currentPage + 3, lastPage);
    }

    /// The element number of the first element to show for the current page.
    @property
    size_t firstCiteOffset() const {
        return (pagesize * (currentPage - 1));
    }

    /**
     * The element number of the last element to show for the current page.
     * This also accounts for "last" pages that are not completely filled.
     */
    @property
    size_t lastCite() const {
        import std.algorithm.comparison : min;
        return min(
            pagesize * currentPage,
            numberOfElements
        );
    }

    /// Return whether front- respectively back-truncation marks are necessary
    @property
    bool needsFrontTruncation() const {
        return firstPageLabel != 1;
    }
    /// ditto
    @property
    bool needsBackTruncation() const {
        return lastPageLabel != lastPage;
    }

    /// Return whether next- respectively previous-page-links are necessary.
    @property
    bool needsNextPage() const {
        return currentPage != lastPage;
    }
    /// ditto
    @property
    bool needsPreviousPage() const {
        return currentPage != 1;
    }
}

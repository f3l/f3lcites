module test.citesystem.testpaginationinfo;

import unit_threaded;
import unit_threaded.should;

private import citesystem.server.paginationinfo : PaginationInfo;

@("Last page calculation, simple case")
@system unittest {
    const testPaginationInfo = PaginationInfo(1, 10, 5);
    const actualLastPage = testPaginationInfo.lastPage;
    const expectedLastPage = 1;

    actualLastPage.shouldEqual(expectedLastPage);
}

@("Last page calculation, harder case")
@system unittest {
    const testPaginationInfo = PaginationInfo(1, 10, 105);
    const actualLastPage = testPaginationInfo.lastPage;
    const expectedLastPage = 11;
    actualLastPage.shouldEqual(expectedLastPage);
}

@("Labels to print, start case")
@system unittest {
    const testPaginationInfo = PaginationInfo(1, 10, 5);
    const paginationLables = testPaginationInfo.pagesToShow;
    const paginationLabelNumber = paginationLables.length;
    paginationLabelNumber.shouldEqual(1);
}

@("Labels to print, middle case")
@system unittest {
    const testPaginationInfo = PaginationInfo(4, 10, 105);
    const paginationLables = testPaginationInfo.pagesToShow;
    const paginationLabelNumber = paginationLables.length;
    paginationLabelNumber.shouldEqual(7);
    paginationLables[0].shouldEqual(1);
}

@("Labels to print, end case")
@system unittest {
    const testPaginationInfo = PaginationInfo(9, 10, 105);
    const paginationLables = testPaginationInfo.pagesToShow;
    const paginationLabelNumber = paginationLables.length;
    paginationLabelNumber.shouldEqual(6);
    paginationLables[0].shouldEqual(6);
}

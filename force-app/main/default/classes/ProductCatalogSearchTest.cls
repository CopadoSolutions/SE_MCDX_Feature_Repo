@IsTest
private class ProductCatalogSearchTest {
    @TestSetup
    static void createProducts() {
        insert new List<Product2>{
            new Product2(
                Name = 'High Capacity Battery',
                ProductCode = 'B-1000',
                Family = 'Batteries',
                Description = 'Stores renewable energy',
                IsActive = true
            ),
            new Product2(
                Name = 'Cirrus Solar Panel',
                ProductCode = 'SP-2000',
                Family = 'Solar Panels',
                Description = 'Residential solar panel',
                IsActive = true
            ),
            new Product2(
                Name = 'Retired Battery',
                ProductCode = 'B-OLD',
                Family = 'Batteries',
                Description = 'No longer available',
                IsActive = false
            )
        };
    }

    @IsTest
    static void exactCodeRanksFirstAndReturnsLiveFields() {
        ProductCatalogSearch.Request request = new ProductCatalogSearch.Request();
        request.searchTerm = 'B-1000';

        Test.startTest();
        List<ProductCatalogSearch.Result> results =
            ProductCatalogSearch.search(new List<ProductCatalogSearch.Request>{ request });
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].found);
        System.assertEquals(1, results[0].products.size());
        System.assertEquals('B-1000', results[0].products[0].productCode);
        System.assertEquals('High Capacity Battery', results[0].products[0].name);
        System.assertEquals('Stores renewable energy', results[0].products[0].productDescription);
        System.assertEquals(results[0].products[0].productId, results[0].topProductId);
    }

    @IsTest
    static void familyFilterAndActiveFilterAreEnforced() {
        ProductCatalogSearch.Request request = new ProductCatalogSearch.Request();
        request.searchTerm = 'battery';
        request.family = 'Solar Panels';

        Test.startTest();
        ProductCatalogSearch.Result result =
            ProductCatalogSearch.search(new List<ProductCatalogSearch.Request>{ request })[0];
        Test.stopTest();

        System.assertEquals(false, result.found);
        System.assertEquals(0, result.products.size());
        System.assertEquals(null, result.topProductId);
    }

    @IsTest
    static void bulkAndBlankRequestsReturnAlignedResults() {
        ProductCatalogSearch.Request solarRequest = new ProductCatalogSearch.Request();
        solarRequest.searchTerm = 'solar';
        ProductCatalogSearch.Request blankRequest = new ProductCatalogSearch.Request();
        blankRequest.searchTerm = ' ';

        Test.startTest();
        List<ProductCatalogSearch.Result> results = ProductCatalogSearch.search(
            new List<ProductCatalogSearch.Request>{ solarRequest, blankRequest, null }
        );
        Test.stopTest();

        System.assertEquals(3, results.size());
        System.assertEquals(true, results[0].found);
        System.assertEquals('SP-2000', results[0].products[0].productCode);
        System.assertEquals(false, results[1].found);
        System.assertEquals(false, results[2].found);
    }
}
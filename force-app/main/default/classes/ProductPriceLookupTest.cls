@IsTest
private class ProductPriceLookupTest {
    @TestSetup
    static void createPricingData() {
        Product2 product = new Product2(
            Name = 'Test Catalog Battery',
            ProductCode = 'TEST-BATTERY',
            Family = 'Batteries',
            IsActive = true
        );
        insert product;

        Id standardPricebookId = Test.getStandardPricebookId();
        update new Pricebook2(
            Id = standardPricebookId,
            IsActive = true
        );
        insert new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = standardPricebookId,
            UnitPrice = 1250,
            IsActive = true
        );

        Pricebook2 employeePricebook = new Pricebook2(
            Name = 'Employee Test Price Book',
            IsActive = true
        );
        insert employeePricebook;
        insert new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = employeePricebook.Id,
            UnitPrice = 1175,
            IsActive = true
        );
    }

    @IsTest
    static void returnsPricesAcrossActivePriceBooks() {
        Product2 product = [
            SELECT Id
            FROM Product2
            WHERE ProductCode = 'TEST-BATTERY'
            LIMIT 1
        ];
        ProductPriceLookup.Request request = new ProductPriceLookup.Request();
        request.productId = product.Id;

        Test.startTest();
        ProductPriceLookup.Result result =
            ProductPriceLookup.lookup(new List<ProductPriceLookup.Request>{ request })[0];
        Test.stopTest();

        System.assertEquals(true, result.found);
        System.assertEquals(2, result.prices.size());
        Boolean foundStandardPrice = false;
        Boolean foundEmployeePrice = false;
        for (ProductPriceLookup.PriceInfo price : result.prices) {
            System.assertEquals('Test Catalog Battery', price.productName);
            System.assertEquals(true, price.active);
            System.assertNotEquals(null, price.priceBookName);
            System.assertNotEquals(null, price.currencyIsoCode);
            foundStandardPrice = foundStandardPrice || price.unitPrice == 1250;
            foundEmployeePrice = foundEmployeePrice || price.unitPrice == 1175;
        }
        System.assertEquals(true, foundStandardPrice);
        System.assertEquals(true, foundEmployeePrice);
    }

    @IsTest
    static void invalidAndNullProductIdsReturnEmptyAlignedResults() {
        ProductPriceLookup.Request invalidRequest = new ProductPriceLookup.Request();
        invalidRequest.productId = 'not-an-id';

        Test.startTest();
        List<ProductPriceLookup.Result> results = ProductPriceLookup.lookup(
            new List<ProductPriceLookup.Request>{ invalidRequest, null }
        );
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assertEquals(false, results[0].found);
        System.assertEquals(0, results[0].prices.size());
        System.assertEquals(false, results[1].found);
        System.assertEquals(0, results[1].prices.size());
    }
}
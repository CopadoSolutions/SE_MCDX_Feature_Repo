public with sharing class ProductPriceLookup {
    public class Request {
        @InvocableVariable(
            label='Product ID'
            description='Salesforce Product2 ID returned by catalog search'
            required=true
        )
        public String productId;
    }

    public class PriceInfo {
        @InvocableVariable(
            label='Product Name'
            description='Name of the priced product'
        )
        public String productName;

        @InvocableVariable(
            label='Price Book Name'
            description='Name of the price book'
        )
        public String priceBookName;

        @InvocableVariable(
            label='Currency ISO Code'
            description='ISO currency code for the price'
        )
        public String currencyIsoCode;

        @InvocableVariable(
            label='Unit Price'
            description='Unit price from the price-book entry'
        )
        public Decimal unitPrice;

        @InvocableVariable(
            label='Active'
            description='Whether the price-book entry is active'
        )
        public Boolean active;
    }

    public class Result {
        @InvocableVariable(
            label='Prices'
            description='Active price-book entries for the selected product'
        )
        public List<PriceInfo> prices;

        @InvocableVariable(
            label='Price Found'
            description='Whether at least one active price-book entry matched'
        )
        public Boolean found;
    }

    @InvocableMethod(
        label='Look Up Product Prices'
        description='Retrieves active prices across active price books for selected products'
    )
    public static List<Result> lookup(List<Request> requests) {
        List<Result> results = new List<Result>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        Set<Id> productIds = new Set<Id>();
        List<Id> requestProductIds = new List<Id>();
        for (Request request : requests) {
            Id productId = parseProductId(request == null ? null : request.productId);
            requestProductIds.add(productId);
            if (productId != null) {
                productIds.add(productId);
            }
        }

        Map<Id, List<PriceInfo>> pricesByProductId = new Map<Id, List<PriceInfo>>();
        if (!productIds.isEmpty()) {
            for (PricebookEntry entry : [
                SELECT Product2Id, Product2.Name, Pricebook2.Name,
                    CurrencyIsoCode, UnitPrice, IsActive
                FROM PricebookEntry
                WHERE Product2Id IN :productIds
                    AND IsActive = true
                    AND Pricebook2.IsActive = true
                WITH USER_MODE
                ORDER BY Pricebook2.Name ASC, CurrencyIsoCode ASC
            ]) {
                if (!pricesByProductId.containsKey(entry.Product2Id)) {
                    pricesByProductId.put(entry.Product2Id, new List<PriceInfo>());
                }
                pricesByProductId.get(entry.Product2Id).add(toPriceInfo(entry));
            }
        }

        for (Id productId : requestProductIds) {
            Result result = new Result();
            result.prices = productId != null && pricesByProductId.containsKey(productId)
                ? pricesByProductId.get(productId)
                : new List<PriceInfo>();
            result.found = !result.prices.isEmpty();
            results.add(result);
        }
        return results;
    }

    private static Id parseProductId(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        try {
            Id candidate = (Id) value.trim();
            return candidate.getSObjectType() == Product2.SObjectType ? candidate : null;
        } catch (Exception ignored) {
            return null;
        }
    }

    private static PriceInfo toPriceInfo(PricebookEntry entry) {
        PriceInfo info = new PriceInfo();
        info.productName = entry.Product2.Name;
        info.priceBookName = entry.Pricebook2.Name;
        info.currencyIsoCode = entry.CurrencyIsoCode;
        info.unitPrice = entry.UnitPrice;
        info.active = entry.IsActive;
        return info;
    }
}
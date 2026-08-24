public with sharing class ProductCatalogSearch {
    private static final Integer MAX_RESULTS_PER_REQUEST = 10;
    private static final Integer MAX_CANDIDATE_PRODUCTS = 2000;

    public class Request {
        @InvocableVariable(
            label='Search Term'
            description='Product name, product code, or description phrase'
            required=true
        )
        public String searchTerm;

        @InvocableVariable(
            label='Product Family'
            description='Optional exact Product2 family'
        )
        public String family;
    }

    public class ProductInfo {
        @InvocableVariable(
            label='Product ID'
            description='Salesforce Product2 ID'
        )
        public String productId;

        @InvocableVariable(
            label='Product Name'
            description='Product name'
        )
        public String name;

        @InvocableVariable(
            label='Product Code'
            description='Product code'
        )
        public String productCode;

        @InvocableVariable(
            label='Product Family'
            description='Product family'
        )
        public String family;

        @InvocableVariable(
            label='Product Description'
            description='Product description'
        )
        public String productDescription;
    }

    public class Result {
        @InvocableVariable(
            label='Products'
            description='Matching active products'
        )
        public List<ProductInfo> products;

        @InvocableVariable(
            label='Top Product ID'
            description='Salesforce ID of the top matching product'
        )
        public String topProductId;

        @InvocableVariable(
            label='Product Found'
            description='Whether at least one active product matched'
        )
        public Boolean found;
    }

    @InvocableMethod(
        label='Search Product Catalog'
        description='Searches active products by name, code, description, and optional family'
    )
    public static List<Result> search(List<Request> requests) {
        List<Result> results = new List<Result>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        List<Product2> candidates = [
            SELECT Id, Name, ProductCode, Family, Description
            FROM Product2
            WHERE IsActive = true
            WITH USER_MODE
            ORDER BY Name ASC
            LIMIT :MAX_CANDIDATE_PRODUCTS
        ];

        for (Request request : requests) {
            Result result = new Result();
            result.products = new List<ProductInfo>();
            result.found = false;

            String normalizedTerm = normalize(request == null ? null : request.searchTerm);
            String normalizedFamily = normalize(request == null ? null : request.family);
            if (String.isBlank(normalizedTerm)) {
                results.add(result);
                continue;
            }

            List<RankedProduct> matches = new List<RankedProduct>();
            for (Product2 product : candidates) {
                if (!String.isBlank(normalizedFamily) &&
                    normalize(product.Family) != normalizedFamily) {
                    continue;
                }

                Integer score = matchScore(product, normalizedTerm);
                if (score != null) {
                    matches.add(new RankedProduct(product, score));
                }
            }
            matches.sort();

            Integer resultCount = Math.min(matches.size(), MAX_RESULTS_PER_REQUEST);
            for (Integer index = 0; index < resultCount; index++) {
                result.products.add(toProductInfo(matches[index].product));
            }

            result.found = !result.products.isEmpty();
            if (result.found) {
                result.topProductId = result.products[0].productId;
            }
            results.add(result);
        }
        return results;
    }

    private static Integer matchScore(Product2 product, String term) {
        String searchText = normalizeSearchText(term);
        String name = normalizeSearchText(product.Name);
        String code = normalizeSearchText(product.ProductCode);
        String productDescription = normalizeSearchText(product.Description);

        if (code == searchText) {
            return 0;
        }
        if (name == searchText) {
            return 1;
        }
        if (code.contains(searchText)) {
            return 2;
        }
        if (name.contains(searchText)) {
            return 3;
        }
        if (containsAllTokens(name, searchText) || containsAllTokens(code, searchText)) {
            return 4;
        }
        if (productDescription.contains(searchText) ||
            containsAllTokens(productDescription, searchText)) {
            return 5;
        }
        return null;
    }

    private static Boolean containsAllTokens(String candidate, String searchText) {
        if (String.isBlank(candidate) || String.isBlank(searchText)) {
            return false;
        }
        for (String token : searchText.split(' ')) {
            if (!String.isBlank(token) && !candidate.contains(token)) {
                return false;
            }
        }
        return true;
    }

    private static ProductInfo toProductInfo(Product2 product) {
        ProductInfo info = new ProductInfo();
        info.productId = product.Id;
        info.name = product.Name;
        info.productCode = product.ProductCode;
        info.family = product.Family;
        info.productDescription = product.Description;
        return info;
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? '' : value.trim().toLowerCase();
    }

    private static String normalizeSearchText(String value) {
        return normalize(value).replaceAll('[^a-z0-9]+', ' ').trim();
    }

    private class RankedProduct implements Comparable {
        private Product2 product;
        private Integer score;

        private RankedProduct(Product2 product, Integer score) {
            this.product = product;
            this.score = score;
        }

        public Integer compareTo(Object value) {
            RankedProduct other = (RankedProduct) value;
            if (score != other.score) {
                return score < other.score ? -1 : 1;
            }
            Integer nameComparison =
                normalize(product.Name).compareTo(normalize(other.product.Name));
            return nameComparison != 0
                ? nameComparison
                : normalize(product.ProductCode).compareTo(normalize(other.product.ProductCode));
        }
    }
}
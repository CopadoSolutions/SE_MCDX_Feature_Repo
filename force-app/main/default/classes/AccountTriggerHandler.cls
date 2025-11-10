public with sharing class AccountTriggerHandler {
    public static void beforeInsert(List<Account> newRecords) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }
        for (Account acc : newRecords) {
            if (acc == null) {
                continue;
            }
            if (String.isBlank(acc.Description)) {
                acc.addError('Description is required.');
            }
        }
    }
}
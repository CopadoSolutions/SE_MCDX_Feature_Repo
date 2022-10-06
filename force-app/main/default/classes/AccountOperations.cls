public with sharing class AccountOperations {
    public AccountOperations() {
        Public static Account setDefaultDescription(Account a){
            If (a.Description != null) return a;
            Else {
                a.Description = 'Default description';
                return a;
            }
        }
    }
}

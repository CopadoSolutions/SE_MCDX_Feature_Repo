@isTest
private class AccountTriggerHandlerTest {
    @isTest
    static void testBeforeInsert_ErrorWhenDescriptionMissing() {
        // Given: an Account with blank Description
        Account a = new Account(Name = 'No Desc');
        // When: insert with partial success allowed
        Database.SaveResult[] results = Database.insert(new List<Account>{ a }, false);
        // Then: assert failure and error message
        System.assertEquals(1, results.size(), 'One result expected');
        System.assertEquals(false, results[0].isSuccess(), 'Insert should fail due to addError');
        System.assertEquals(1, results[0].getErrors().size(), 'One error expected');
        System.assert(results[0].getErrors()[0].getMessage().contains('Description is required.'));
    }

    @isTest
    static void testBeforeInsert_SuccessWhenDescriptionPresent() {
        // Given: an Account with Description
        Account a = new Account(Name = 'With Desc', Description = 'Some description');
        // When
        insert a;
        // Then
        System.assertNotEquals(null, a.Id, 'Account should have been inserted successfully');
        // Verify the stored value
        Account inserted = [SELECT Id, Description FROM Account WHERE Id = :a.Id];
        System.assertEquals('Some description', inserted.Description);
    }
}
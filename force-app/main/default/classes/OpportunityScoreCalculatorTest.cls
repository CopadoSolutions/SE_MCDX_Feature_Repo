@isTest
private class OpportunityScoreCalculatorTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<Opportunity> testOpps = new List<Opportunity>{
            new Opportunity(
                Name = 'High Value Opp',
                AccountId = testAccount.Id,
                Amount = 150000,
                Probability = 75,
                CloseDate = Date.today().addDays(30),
                StageName = 'Prospecting'
            ),
            new Opportunity(
                Name = 'Medium Value Opp',
                AccountId = testAccount.Id,
                Amount = 50000,
                Probability = 50,
                CloseDate = Date.today().addDays(60),
                StageName = 'Prospecting'
            )
        };
        
        insert testOpps;
    }
    
    @isTest
    static void testValidOpportunityScores() {
        List<Opportunity> testOpps = [SELECT Id, Amount, Probability, CreatedDate 
                                    FROM Opportunity];
        
        Test.startTest();
        Map<Id, Decimal> scores = OpportunityScoreCalculator.calculateScores(testOpps);
        Test.stopTest();
        
        System.assertEquals(2, scores.size(), 'Should process both opportunities');
        
        for(Id oppId : scores.keySet()) {
            Decimal score = scores.get(oppId);
            System.assert(score > 0, 'Score should be greater than 0');
            System.assert(score <= 100, 'Score should not exceed 100');
        }
    }
    
    @isTest
    static void testNullValues() {
        Opportunity nullOpp = new Opportunity(
            Name = 'Null Test Opp',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        insert nullOpp;
        
        Test.startTest();
        Map<Id, Decimal> scores = OpportunityScoreCalculator.calculateScores(
            new List<Opportunity>{nullOpp}
        );
        Test.stopTest();
        
        System.assertNotEquals(null, scores.get(nullOpp.Id), 
            'Should handle null values without throwing exceptions');
    }
    
    @isTest
    static void testEdgeCases() {
        // Test empty list
        Map<Id, Decimal> emptyScores = OpportunityScoreCalculator.calculateScores(
            new List<Opportunity>()
        );
        System.assertEquals(0, emptyScores.size(), 'Empty list should return empty map');
        
        // Test null input
        Map<Id, Decimal> nullScores = OpportunityScoreCalculator.calculateScores(null);
        System.assertEquals(0, nullScores.size(), 'Null input should return empty map');
    }
}
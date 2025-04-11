@IsTest
public class OpportunityAutomationsTest {

    @IsTest
    static void testSetDefaultDescription() {
        // Test with null description
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity 1');
        opp1 = OpportunityAutomations.setDefaultDescription(opp1);
        System.assertEquals('Default opportunity description', opp1.Description,
                          'Description should be set to default opportunity description');

        // Test with existing description
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity 2',
                                         Description = 'Custom Description');
        opp2 = OpportunityAutomations.setDefaultDescription(opp2);
        System.assertEquals('Custom Description', opp2.Description,
                          'Existing description should not be changed');
    }

    @IsTest
    static void testSetDefaultStage() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity');
        opp = OpportunityAutomations.setDefaultStage(opp);
        System.assertEquals('Qualification', opp.StageName,
                          'Stage should be set to Qualification');
    }

    @IsTest
    static void testSetDefaultCloseDate() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity');
        opp = OpportunityAutomations.setDefaultCloseDate(opp);
        System.assertEquals(Date.today().addDays(60), opp.CloseDate,
                          'Close date should be set to 60 days from today');
    }

    @IsTest
    static void testSetDefaultProbability() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity');
        opp = OpportunityAutomations.setDefaultProbability(opp);
        System.assertEquals(20, opp.Probability,
                          'Probability should be set to 20');
    }

    @IsTest
    static void testSetDefaultType() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity');
        opp = OpportunityAutomations.setDefaultType(opp);
        System.assertEquals('Existing Customer - Upgrade', opp.Type,
                          'Type should be set to Existing Customer - Upgrade');
    }

    @IsTest
    static void testAllMethodsTogether() {
        // Test all methods in sequence to ensure they work together
        Opportunity opp = new Opportunity(Name = 'Test Opportunity Complete');

        opp = OpportunityAutomations.setDefaultDescription(opp);
        opp = OpportunityAutomations.setDefaultStage(opp);
        opp = OpportunityAutomations.setDefaultCloseDate(opp);
        opp = OpportunityAutomations.setDefaultProbability(opp);
        opp = OpportunityAutomations.setDefaultType(opp);

        // Verify all fields are set correctly
        System.assertEquals('Default opportunity description', opp.Description,
                          'Description should be set to default opportunity description');
        System.assertEquals('Qualification', opp.StageName,
                          'Stage should be set to Qualification');
        System.assertEquals(Date.today().addDays(60), opp.CloseDate,
                          'Close date should be set to 60 days from today');
        System.assertEquals(20, opp.Probability,
                          'Probability should be set to 20');
        System.assertEquals('Existing Customer - Upgrade', opp.Type,
                          'Type should be set to Existing Customer - Upgrade');
    }
}
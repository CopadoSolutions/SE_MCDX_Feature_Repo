@IsTest
public class OpportunityAutomationsTest {
    
    @IsTest
    static void testSetDefaultDescription() {
        // Test with null description
        Opportunity opp1 = new Opportunity(Name = 'Test Opp 1');
        opp1 = OpportunityAutomations.setDefaultDescription(opp1);
        System.assertEquals('Default description', opp1.Description, 'Description should be set to default value');
        
        // Test with existing description
        Opportunity opp2 = new Opportunity(Name = 'Test Opp 2', Description = 'Existing Description');
        opp2 = OpportunityAutomations.setDefaultDescription(opp2);
        System.assertEquals('Existing Description', opp2.Description, 'Existing description should not be changed');
    }
    
    @IsTest
    static void testSetDefaultStage() {
        Opportunity opp = new Opportunity(Name = 'Test Opp');
        opp = OpportunityAutomations.setDefaultStage(opp);
        System.assertEquals('Prospecting', opp.StageName, 'Stage should be set to Prospecting');
    }
    
    @IsTest
    static void testSetDefaultCloseDate() {
        Opportunity opp = new Opportunity(Name = 'Test Opp');
        opp = OpportunityAutomations.setDefaultCloseDate(opp);
        System.assertEquals(Date.today().addDays(30), opp.CloseDate, 'Close date should be set to 30 days from today');
    }
    
    @IsTest
    static void testSetDefaultProbability() {
        Opportunity opp = new Opportunity(Name = 'Test Opp');
        opp = OpportunityAutomations.setDefaultProbability(opp);
        System.assertEquals(10, opp.Probability, 'Probability should be set to 10');
    }
    
    @IsTest
    static void testSetDefaultType() {
        Opportunity opp = new Opportunity(Name = 'Test Opp');
        opp = OpportunityAutomations.setDefaultType(opp);
        System.assertEquals('New Business', opp.Type, 'Type should be set to New Business');
    }
    
    @IsTest
    static void testAllMethodsTogether() {
        // Test all methods in sequence to ensure they work together
        Opportunity opp = new Opportunity(Name = 'Test Opp All Methods');
        
        opp = OpportunityAutomations.setDefaultDescription(opp);
        opp = OpportunityAutomations.setDefaultStage(opp);
        opp = OpportunityAutomations.setDefaultCloseDate(opp);
        opp = OpportunityAutomations.setDefaultProbability(opp);
        opp = OpportunityAutomations.setDefaultType(opp);
        
        // Verify all fields are set correctly
        System.assertEquals('Default description', opp.Description, 'Description should be set to default value');
        System.assertEquals('Prospecting', opp.StageName, 'Stage should be set to Prospecting');
        System.assertEquals(Date.today().addDays(30), opp.CloseDate, 'Close date should be set to 30 days from today');
        System.assertEquals(10, opp.Probability, 'Probability should be set to 10');
        System.assertEquals('New Business', opp.Type, 'Type should be set to New Business');
    }
}
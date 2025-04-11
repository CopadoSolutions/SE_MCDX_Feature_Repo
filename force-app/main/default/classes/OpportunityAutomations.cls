public class OpportunityAutomations {
    public static Opportunity setDefaultDescription(Opportunity opp){
        if (opp.Description != null) return opp;
        else {
            opp.Description = 'Default description';
            return opp;
        }
    }
    
    public static Opportunity setDefaultStage(Opportunity opp){
        opp.StageName = 'Prospecting'; 
        return opp;
    }
    
    public static Opportunity setDefaultCloseDate(Opportunity opp){
        opp.CloseDate = Date.today().addDays(30); 
        return opp;
    }
    
    public static Opportunity setDefaultProbability(Opportunity opp) {
        opp.Probability = 10;
        return opp;
    }
    
    public static Opportunity setDefaultType(Opportunity opp) {
        opp.Type = 'New Business'; 
        return opp;
    }
}
public class OpportunityAutomations {
    public static Opportunity setDefaultDescription(Opportunity opp){
        if (opp.Description != null) return opp;
        else {
            opp.Description = 'Default opportunity description';
            return opp;
        }
    }

    public static Opportunity setDefaultStage(Opportunity opp){
        opp.StageName = 'Qualification'; // Changed from 'Prospecting'
        return opp;
    }

    public static Opportunity setDefaultCloseDate(Opportunity opp){
        opp.CloseDate = Date.today().addDays(60); // Changed from 30 to 60 days
        return opp;
    }

    public static Opportunity setDefaultProbability(Opportunity opp) {
        opp.Probability = 20; // Changed from 10 to 20
        return opp;
    }

    public static Opportunity setDefaultType(Opportunity opp) {
        opp.Type = 'Existing Customer - Upgrade'; // Changed from 'New Business'
        return opp;
    }
}
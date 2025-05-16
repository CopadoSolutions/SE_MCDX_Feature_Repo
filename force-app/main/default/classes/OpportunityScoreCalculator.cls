public class OpportunityScoreCalculator {
    
    private static final Decimal AMOUNT_WEIGHT = 0.4;
    private static final Decimal PROBABILITY_WEIGHT = 0.3;
    private static final Decimal AGE_WEIGHT = 0.3;
    
    public static Map<Id, Decimal> calculateScores(List<Opportunity> opportunities) {
        Map<Id, Decimal> scoreMap = new Map<Id, Decimal>();
        
        if(opportunities == null || opportunities.isEmpty()) {
            return scoreMap;
        }
        
        for(Opportunity opp : opportunities) {
            Decimal score = calculateIndividualScore(opp);
            scoreMap.put(opp.Id, score);
        }
        
        return scoreMap;
    }
    
    private static Decimal calculateIndividualScore(Opportunity opp) {
        // Handle null opportunity
        if(opp == null) return 0;
        
        Decimal amountScore = calculateAmountScore(opp.Amount);
        // Handle null probability
        Decimal probabilityScore = (opp.Probability != null) ? 
            opp.Probability * PROBABILITY_WEIGHT : 0;
        Decimal ageScore = calculateAgeScore(opp.CreatedDate);
        
        return amountScore + probabilityScore + ageScore;
    }
    
    private static Decimal calculateAmountScore(Decimal amount) {
        if(amount == null) return 0;
        
        if(amount >= 100000) return 100 * AMOUNT_WEIGHT;
        if(amount >= 50000) return 75 * AMOUNT_WEIGHT;
        if(amount >= 25000) return 50 * AMOUNT_WEIGHT;
        return 25 * AMOUNT_WEIGHT;
    }
    
    private static Decimal calculateAgeScore(DateTime createdDate) {
        if(createdDate == null) return 0;
        
        Integer daysOld = createdDate.date().daysBetween(Date.today());
        if(daysOld <= 30) return 100 * AGE_WEIGHT;
        if(daysOld <= 60) return 75 * AGE_WEIGHT;
        if(daysOld <= 90) return 50 * AGE_WEIGHT;
        return 25 * AGE_WEIGHT;
    }
}
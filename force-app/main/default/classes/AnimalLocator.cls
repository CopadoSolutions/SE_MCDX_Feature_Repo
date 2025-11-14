public class AnimalLocator {
    
    public static String getAnimalNameById(Integer animalId) {
        // Validate input
        if (animalId == null) {
            return null;
        }
        
        String endpoint = 'https://th-apex-http-callout.herokuapp.com/animals/' + animalId;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(10000); // 10 seconds timeout
        
        try {
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Parse JSON response to extract animal name
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if (responseMap.containsKey('name') && responseMap.get('name') != null) {
                    return String.valueOf(responseMap.get('name'));
                } else {
                    return null;
                }
            } else {
                // Handle non-200 status codes
                System.debug('HTTP Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
                return null;
            }
        } catch (Exception e) {
            // Handle any exceptions during the callout
            System.debug('Exception during HTTP callout: ' + e.getMessage());
            return null;
        }
    }
}
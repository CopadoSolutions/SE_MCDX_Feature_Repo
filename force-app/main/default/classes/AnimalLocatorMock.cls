@isTest
public class AnimalLocatorMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        // Extract animal ID from the endpoint URL
        String endpoint = request.getEndpoint();
        String animalId = endpoint.substring(endpoint.lastIndexOf('/') + 1);
        
        // Set different responses based on the animal ID for comprehensive testing
        if (animalId == '1') {
            response.setBody('{"id": 1, "name": "Lion", "eats": "meat", "says": "roar"}');
            response.setStatusCode(200);
        } else if (animalId == '2') {
            response.setBody('{"id": 2, "name": "Elephant", "eats": "plants", "says": "trumpet"}');
            response.setStatusCode(200);
        } else if (animalId == '999') {
            // Test case for animal not found
            response.setBody('{"error": "Animal not found"}');
            response.setStatusCode(404);
        } else if (animalId == '500') {
            // Test case for server error
            response.setBody('{"error": "Internal server error"}');
            response.setStatusCode(500);
        } else if (animalId == '0') {
            // Test case for response without name property
            response.setBody('{"id": 0, "eats": "unknown", "says": "unknown"}');
            response.setStatusCode(200);
        } else {
            // Default response for other IDs
            response.setBody('{"id": ' + animalId + ', "name": "Unknown Animal", "eats": "unknown", "says": "unknown"}');
            response.setStatusCode(200);
        }
        
        return response;
    }
}
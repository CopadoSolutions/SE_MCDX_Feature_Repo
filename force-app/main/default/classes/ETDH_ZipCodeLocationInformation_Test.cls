@IsTest(SeeAllData=true)
private class ETDH_ZipCodeLocationInformation_Test {
	@isTest
	static void testGetZipCodeInfoSuccess() {
		// Set up mock callout response
		String mockResponse = '{"zip_code":"94105","latitude":37.7864,"longitude":-122.3892,"city":"San Francisco","state":"CA","county":"San Francisco"}';
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockResponse));

		// Set Data
		//  I'm deleting data since I am doing SeeAllData=true (required to test prompts) but there is no data when creating the unmanaged package
		delete [SELECT Id FROM Case];
		delete [SELECT Id FROM Property__c];
		delete [SELECT Id FROM Broker__c];
		delete [SELECT Id FROM Contact];
		// Now create the property for the test
		Property__c property = new Property__c(Name = 'Test Property ', Price__c = 100000);
		insert property;

		// Gind location information
		List<ETDH_ZipCodeLocationInformation.AgentRequest> requests = new List<ETDH_ZipCodeLocationInformation.AgentRequest>();
		ETDH_ZipCodeLocationInformation.AgentRequest request = new ETDH_ZipCodeLocationInformation.AgentRequest();
		request.propertyID = property.Id;
		request.interest = 'everything';
		// request.interest = 'Schools';
		// request.interest = 'General Information';
		requests.add(request);

		// Call the method to test
		Test.startTest();
		List<ETDH_ZipCodeLocationInformation.AgentResult> results = ETDH_ZipCodeLocationInformation.getZipCodeInfo(requests);
		Test.stopTest();

		// Verify results
		System.assertEquals(1, results.size(), 'Should return one result');
		System.assertEquals(null, results[0].error, 'Error should be null for successful response');
		System.assertNotEquals(null, results[0].zipCodeInfo, 'Should return any text');
	}

	// @isTest
	// static void testGetZipCodeInfoMultipleRequests() {
	//     // Set up test data for multiple requests
	//     List<ETDH_ZipCodeLocationInformation.AgentRequest> requests = new List<ETDH_ZipCodeLocationInformation.AgentRequest>();

	//     ETDH_ZipCodeLocationInformation.AgentRequest request1 = new ETDH_ZipCodeLocationInformation.AgentRequest();
	//     request1.ZipCode = '94105';
	//     requests.add(request1);

	//     ETDH_ZipCodeLocationInformation.AgentRequest request2 = new ETDH_ZipCodeLocationInformation.AgentRequest();
	//     request2.ZipCode = '10001';
	//     requests.add(request2);

	//     // Set up mock callout response
	//     String mockResponse = '{"zip_code":"00000","city":"Test City","state":"TS"}';
	//     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockResponse));

	//     // Call the method to test
	//     Test.startTest();
	//     List<ETDH_ZipCodeLocationInformation.AgentResult> results = ETDH_ZipCodeLocationInformation.getZipCodeInfo(requests);
	//     Test.stopTest();

	//     // Verify results
	//     System.assertEquals(2, results.size(), 'Should return two results');
	//     for (ETDH_ZipCodeLocationInformation.AgentResult result : results) {
	//         System.assertEquals(null, result.error, 'Error should be null for successful responses');
	//         System.assertEquals(mockResponse, result.zipCodeInfo, 'Should return the mock response body');
	//     }
	// }

	// Mock HTTP Response implementation
	private class MockHttpResponse implements HttpCalloutMock {
		private Integer statusCode;
		private String body;

		public MockHttpResponse(Integer statusCode, String body) {
			this.statusCode = statusCode;
			this.body = body;
		}

		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setStatusCode(statusCode);
			response.setBody(body);
			return response;
		}
	}
}
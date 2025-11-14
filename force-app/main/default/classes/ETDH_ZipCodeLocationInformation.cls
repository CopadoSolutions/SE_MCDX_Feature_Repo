public with sharing class ETDH_ZipCodeLocationInformation {
	@InvocableMethod(
		label='ETDH: Zipcode Location Information'
		description='Retrieves location information near the property . You must provide either the Property ID.'
	)
	public static List<AgentResult> getZipCodeInfo(List<AgentRequest> requests) {
		List<AgentResult> results = new List<AgentResult>();

		for (AgentRequest request : requests) {
			results.add(getZipCodeInfo(request));
		}
		return results;
	}

	private static AgentResult getZipCodeInfo(AgentRequest request) {
		AgentResult result = new AgentResult();

		try {
			result.error = null;
			Property__c property = [SELECT Id, Name, Address__c, City__c, State__c, Zip__c FROM Property__c WHERE Id = :request.propertyID];
			String zipCode = property.Zip__c;
			HttpRequest req = new HttpRequest();
			req.setEndpoint('callout:ETDH_ZipCode_Location_Information_NC/zip/' + zipCode);
			req.setMethod('GET');
			req.setTimeout(120000);

			try {
				Http http = new Http();
				HTTPResponse res = http.send(req);

				if (res.getStatusCode() == 200) {
					// result.zipCodeInfo = res.getBody();
					   result.zipCodeInfo = ETDH_ZipCodeLocationFormatter.format(res.getBody(), request, property);
				} else {
					// Log the error and return null.  Important for debugging.
					result.error = ('Error: Zip Code API call failed with status code: ' + res.getStatusCode() + ', body: ' + res.getBody());
				}
			} catch (Exception e) {
				// Handle any exceptions (e.g., network errors, timeouts).
				result.error = ('Exception occurred during Zip Code API call: ' + e.getMessage());
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
			result.error = 'An error has occurred' + e.getMessage() + '\n' + e.getStackTraceString() + '\n' + e.getLineNumber();
		}
		return result;
	}

	public class AgentRequest {
		@InvocableVariable(
			required=true
			description='What specific does the user want to find near this property? Or does he want general information?'
		)
		public String interest;

		@InvocableVariable(
			required=true
			description='Property ID (18 characters record Id) for which we are trying to find the location information for.'
		)
		public String propertyID;
	}

	public class AgentResult {
		@InvocableVariable(required=false description='Location Information')
		public String zipCodeInfo;
		@InvocableVariable(required=false description='Error message')
		public String error;
	}
}
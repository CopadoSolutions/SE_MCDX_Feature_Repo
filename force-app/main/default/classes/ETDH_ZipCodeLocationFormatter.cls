public with sharing class ETDH_ZipCodeLocationFormatter {
	public static String format(String zipCodeInfo, ETDH_ZipCodeLocationInformation.AgentRequest request, Property__c property) {

		// Create Prompt Input Parameter Variables
		Map<String, String> propertyId = new Map<String, String>{ 'id' => property.Id };
		Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
		addValue(inputParams, 'Input:ZipCode_Data', zipCodeInfo);
		addValue(inputParams, 'Input:Interest', request.interest);
		addValue(inputParams, 'Input:Property', propertyId);

		// Configure Einstein LLM Service
		ConnectApi.EinsteinPromptTemplateGenerationsInput promptTemplateService = setPromptTemplateService(inputParams);

		// Generate Response with LLM
		ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
			'ETDH_Analyze_ZipCode_information',
			promptTemplateService
		);

		// Extract and Return HTML
		ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
		return ETAI_Helpers.extractHtml(response.text);
	}

	private static ConnectApi.EinsteinPromptTemplateGenerationsInput setPromptTemplateService(Map<String, ConnectApi.WrappedValue> inputParams) {
        ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        promptGenerationsInput.inputParams = inputParams;
        promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        promptGenerationsInput.additionalConfig.numGenerations = 1;
        promptGenerationsInput.additionalConfig.enablePiiMasking = true;
        promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';
        promptGenerationsInput.isPreview = false;
        return promptGenerationsInput;
    }

	private static ConnectApi.WrappedValue addValue(Map<String, ConnectApi.WrappedValue> inputParams, String name, Object value) {
		ConnectApi.WrappedValue inputValue = new ConnectApi.WrappedValue();
		inputValue.value = value;
		inputParams.put(name, inputValue);
		return inputValue;
	}
}
public inherited sharing class ETAI_Helpers {
	public static void debugStringInChunks(String action, String longString, Integer chunkSize) {
		// Default to 50 if chunkSize is not provided or invalid
		if (chunkSize == null || chunkSize <= 0) {
			chunkSize = 50;
		}

		// Handle null or empty strings
		if (String.isBlank(longString)) {
			System.debug('Input string is empty or null');
			return;
		}

		longString = longString.replaceAll('\n', '<NEW_LINE>');
		Integer stringLength = longString.length();
		Double totalChunks = Math.ceil(stringLength / (Double) chunkSize);

		System.debug('*** *** BEGIN *** *** ' + action + ' *** ***');
		System.debug('Total string length: ' + stringLength);
		System.debug('Splitting into ' + totalChunks + ' chunks of ' + chunkSize + ' characters');
		// System.debug(longString);

		for (Integer i = 0; i < stringLength; i += chunkSize) {
			// Calculate the end index, making sure not to exceed string length
			Integer endIndex = Math.min(i + chunkSize, stringLength);

			// Extract the chunk
			String chunk = longString.substring(i, endIndex);

			// Debug the chunk with its position information
			System.debug(
				'Chunk ' +
					padNumber((i / chunkSize + 1), 3) +
					' of ' +
					padNumber((totalChunks), 3) +
					' (chars ' +
					padNumber((i + 1), 5) +
					'-' +
					padNumber(endIndex, 5) +
					'): ' +
					chunk
			);
		}
		System.debug('*** *** END *** *** ' + action + ' *** ***');
	}

	public static String extractHtml(String input) {
		debugStringInChunks('extractHtml(): Input', input, 100);

		// Process
		String output = input; // .replaceAll('\n', '');
		Integer startIndex = output.indexOf('<');
		Integer endIndex = output.lastIndexOf('>');

		if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
			System.debug('Not an HTML, returning original input');
			return input;
		} else {
			// Process HTML
			output = output.substring(startIndex, endIndex + 1);
			// Clean it twice just in case :-)
			output = cleanHtml(output);
			output = cleanHtml(output);
			debugStringInChunks('extractHtml(): Output', output, 100);
			return output;
		}
	}

	public static String extractJson(String input) {
		debugStringInChunks('extractJson(): Input', input, 100);

		// Process
		String output = input;
		Integer startIndex = output.indexOf('{');
		Integer endIndex = output.lastIndexOf('}');

		if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
			System.debug('Not JSON, returning original input');
			return input;
		} else {
			// Process JSON
			output = output.substring(startIndex, endIndex + 1);
			debugStringInChunks('extractJSON(): Output', output, 100);
			return output;
		}
	}

	private static String cleanHtml(String htmlContent) {
		String cleanedHtml = htmlContent;
		// Step 1: Replace multiple spaces with a single space
		cleanedHtml = cleanedHtml.replaceAll(' {2,}', ' ');

		// Step 2: Replace consecutive newlines with a single newline
		cleanedHtml = cleanedHtml.replaceAll('\\n{2,}', '\n');

		// Step 3: Replace spaces around newlines with just newlines
		cleanedHtml = cleanedHtml.replaceAll(' \\n ', '\n').replaceAll(' \\n', '\n').replaceAll('\\n ', '\n');

		// Step 4: Replace '>\n' with '>'
		cleanedHtml = cleanedHtml.replaceAll('>\\n', '>');

		// Step 5: Replace '\n<' with '<'
		cleanedHtml = cleanedHtml.replaceAll('\\n<', '<');

		// Step 6: Replace '> <' with '><'
		cleanedHtml = cleanedHtml.replaceAll('> <', '><');

		// Step 7: Handle tabs if present in the HTML
		cleanedHtml = cleanedHtml.replaceAll('\\t+', ' ');

		// Final cleanup pass to catch any patterns that might have been created
		cleanedHtml = cleanedHtml.replaceAll(' {2,}', ' ').replaceAll('>\\n', '>').replaceAll('\\n<', '<').replaceAll('> <', '><');

		return cleanedHtml;
	}

	public static String padNumber(Decimal value, Integer length) {
		return padNumber(Integer.valueOf(value), length);
	}

	public static String padNumber(Integer value, Integer length) {
		return String.valueOf(value).leftPad(length, '0');
	}

	public static String getSObjectMetadata(String sObjectName) {
		Map<String, Object> jsonOutput = new Map<String, Object>();
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult describeResult = globalDescribe.get(sObjectName).getDescribe();

		// Add general object metadata
		Map<String, Object> objectMetadata = new Map<String, Object>{
			'apiName' => describeResult.getName(),
			'label' => describeResult.getLabel(),
			'labelPlural' => describeResult.getLabelPlural()
		};
		jsonOutput.put('objectMetadata', objectMetadata);

		// Process field information
		Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
		List<Map<String, Object>> fieldsList = new List<Map<String, Object>>();
		for (String fieldName : fieldMap.keySet()) {
			Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
			Map<String, Object> fieldInfo = new Map<String, Object>{
				'apiName' => field.getName(),
				'label' => field.getLabel(),
				'type' => String.valueOf(field.getType())
			};

			// For reference fields, include referenced objects
			if (field.getType() == Schema.DisplayType.REFERENCE) {
				List<String> references = new List<String>();
				for (Schema.SObjectType reference : field.getReferenceTo()) {
					references.add(reference.getDescribe().getName());
				}
				fieldInfo.put('referenceTo', references);
				fieldInfo.put('relationshipName', field.getRelationshipName());
			}

			fieldsList.add(fieldInfo);
		}
		jsonOutput.put('fields', fieldsList);

		// Get child relationships
		List<Map<String, Object>> childRelationships = new List<Map<String, Object>>();
		for (Schema.ChildRelationship cr : describeResult.getChildRelationships()) {
			if (cr.getRelationshipName() != null) {
				childRelationships.add(
					new Map<String, Object>{
						// 'isCascadeDelete' => cr.isCascadeDelete()
						'relationshipName' => cr.getRelationshipName(),
						'childObject' => cr.getChildSObject().getDescribe().getName(),
						'field' => cr.getField().getDescribe().getName()
					}
				);
			}
		}
		jsonOutput.put('childRelationships', childRelationships);

		// Convert to JSON and output
		String jsonString = JSON.serializePretty(jsonOutput);
		return jsonString;
	}
}
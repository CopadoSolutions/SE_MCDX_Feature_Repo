import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import importSampleData from "@salesforce/apex/SampleDataController.importSampleData";

export default class SampleDataImporter extends LightningElement {
	buttonDisabled = false;

	handleImportSampleData() {
		this.buttonDisabled = true;
		setTimeout(() => {
			importSampleData()
				.then(() => {
					const evt = new ShowToastEvent({
						title: "Success",
						message: "Sample data successfully imported",
						variant: "success"
					});
					this.dispatchEvent(evt);
					this.buttonDisabled = false;
				})
				.catch((e) => {
					const evt = new ShowToastEvent({
						title: "Error while importing data",
						message: e.message,
						variant: "error"
					});
					this.dispatchEvent(evt);
					this.buttonDisabled = false;
				});
		}, 1e2);
	}
}
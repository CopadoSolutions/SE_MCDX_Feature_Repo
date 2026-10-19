import { LightningElement } from 'lwc';
export default class DemoComponent extends LightningElement {
    connectedCallback() {
        // Intentional no-console finding; no data access or side effects.
        console.log('Analyzer fixture');
    }
}

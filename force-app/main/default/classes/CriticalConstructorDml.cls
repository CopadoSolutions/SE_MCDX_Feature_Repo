/**
 * Deliberately unsafe analyzer fixture. Never instantiate or deploy to production.
 * Constructor DML triggers PMD ApexCSRF at its native Critical severity.
 */
public with sharing class CriticalConstructorDml {
    public CriticalConstructorDml() {
        insert new Account(Name = 'Analyzer fixture - never execute');
    }
}

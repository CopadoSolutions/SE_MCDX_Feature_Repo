@isTest
public class AnimalLocatorTest {
    
    @isTest
    static void testGetAnimalNameById_Success() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        
        Test.startTest();
        String animalName = AnimalLocator.getAnimalNameById(1);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Lion', animalName, 'Expected animal name to be Lion');
    }
    
    @isTest
    static void testGetAnimalNameById_DifferentAnimal() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        
        Test.startTest();
        String animalName = AnimalLocator.getAnimalNameById(2);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Elephant', animalName, 'Expected animal name to be Elephant');
    }
    
    @isTest
    static void testGetAnimalNameById_NullInput() {
        Test.startTest();
        String animalName = AnimalLocator.getAnimalNameById(null);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(null, animalName, 'Expected null for null input');
    }
    
    @isTest
    static void testGetAnimalNameById_NotFound() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        
        Test.startTest();
        String animalName = AnimalLocator.getAnimalNameById(999);
        Test.stopTest();
        
        // Verify the result (404 response should return null)
        System.assertEquals(null, animalName, 'Expected null for animal not found');
    }
    
    @isTest
    static void testGetAnimalNameById_ServerError() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        
        Test.startTest();
        String animalName = AnimalLocator.getAnimalNameById(500);
        Test.stopTest();
        
        // Verify the result (500 response should return null)
        System.assertEquals(null, animalName, 'Expected null for server error');
    }
    
    @isTest
    static void testGetAnimalNameById_NoNameProperty() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        
        Test.startTest();
        String animalName = AnimalLocator.getAnimalNameById(0);
        Test.stopTest();
        
        // Verify the result (response without name property should return null)
        System.assertEquals(null, animalName, 'Expected null when name property is missing');
    }
    
    @isTest
    static void testGetAnimalNameById_GenericAnimal() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        
        Test.startTest();
        String animalName = AnimalLocator.getAnimalNameById(100);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Unknown Animal', animalName, 'Expected default animal name');
    }
}
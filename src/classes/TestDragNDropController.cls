/**
 * Test DML operations for each method of the Apex class.
 *
 * @author Emiliano Gonzalez <emiliano.gonzalez@modelit.xyz>
 * @since 2018-12
 */
@isTest
private class TestDragNDropController {

    /**
     * Create common test contacts.
     */
    @testSetup static void setup() {
        insert new Contact(LastName = 'Test');
    }
    /**
     * Test upload a file, positive case.
     */
    @isTest static void testSaveFile() {
        String parentId = [SELECT Id FROM Contact WHERE LastName = 'Test'].Id;

        Test.startTest();
        DragNDropController.saveFile(parentId, 'example.jpg', 'Hello World', 'image/jpeg');
        Test.stopTest();

        List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId
                ];

        System.assert(cdl.size() > 0);
    }

    /**
     * Test upload a file, dml exception.
     */
    @isTest static void testSaveFileException() {
        String errorMessage;

        Test.startTest();
        try {
            DragNDropController.saveFile('0032U0000025ifGQAQ', 'example.jpg', 'Hello World', 'image/jpeg');
        } catch (AuraHandledException e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Script-thrown exception', errorMessage);
    }

    /**
     * Test file associated with ContentDocumentId from Content Version, positive case.
     */
    @isTest static void testGetProfilePicture() {
        String parentId = [SELECT Id FROM Contact WHERE LastName = 'Test'].Id;
        ContentVersion contentVersionInsert;
        Id contentDocumentId = TestDataFactory.createTestContentVersion();
        TestDataFactory.createTestContentLink(parentId, contentDocumentId);

        Test.startTest();
        contentVersionInsert = DragNDropController.getProfilePicture(parentId);
        Test.stopTest();

        System.assertEquals(contentVersionInsert.IsLatest, true, 'Image found');
    }

    /**
     * Test file associated with ContentDocumentId from Content Version, QueryException.
     */
    @isTest static void testGetProfilePictureException() {
        String errorMessage;

        Test.startTest();
        try {
            ContentVersion contentVersionInsert;
            contentVersionInsert = DragNDropController.getProfilePicture(null);
        } catch (AuraHandledException e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Script-thrown exception', errorMessage);
    }

    /**
     * Test ContentDocument deletion, positive case.
     */
    @isTest static void testDeleteFile() {
        String parentId = [SELECT Id FROM Contact WHERE LastName = 'Test'].Id;
        Id contentDocumentId = TestDataFactory.createTestContentVersion();
        TestDataFactory.createTestContentLink(parentId, contentDocumentId);

        Test.startTest();
        DragNDropController.deleteFile(parentId);
        Test.stopTest();

        List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId
                ];

        System.assert(cdl.size() == 0);
    }
}
/**
 * Test DML operations for each method of the Apex class.
 *
 * @author Emiliano Gonzalez <emiliano.gonzalez@modelit.xyz>
 * @since 2018-12
 */
@isTest
private class TestDragNDropController {

    /**
     * Test upload a file, positive case.
     */
    @isTest static void testSaveFile() {
        Contact testContact = new Contact(LastName = 'hola');
        insert testContact;
        String parentId =  testContact.Id;
        String fileName = 'example.jpg';
        String base64Data = 'Hello World';
        String contentType = 'image/jpeg';
        Test.startTest();
        DragNDropController.saveFile(parentId, fileName, base64Data, contentType);
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
        DragNDropController.CustomExceptionData saveException = new DragNDropController.CustomExceptionData(
            'error',
            'error'
            );

        String errorMessage = 'Script-thrown exception';
        Test.startTest();
        try {
            DragNDropController.saveFile('0032U0000025ifGQAQ', 'example.jpg', 'Hello World', 'image/jpeg');
        } catch (AuraHandledException e) {
            saveException.message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(errorMessage, saveException.message);
    }

    /**
     * Test file associated with ContentDocumentId from Content Version, positive case.
     */
    @isTest static void testGetProfilePicture() {
        Contact testContact = new Contact(LastName = 'hola');
        insert testContact;
        String parentId =  testContact.Id;
        ContentVersion contentVersionInsert = new ContentVersion();
        contentVersionInsert.ContentDocumentId = null;
        contentVersionInsert.VersionData = EncodingUtil.base64Decode('Test');
        contentVersionInsert.Title = 'Test';
        contentVersionInsert.PathOnClient = 'Test.jpg';
        insert contentVersionInsert;

        ContentDocumentLink contentDocumentInsert = new ContentDocumentLink();

        contentDocumentInsert.ContentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id =: contentVersionInsert.Id
            ].ContentDocumentId;

        contentDocumentInsert.LinkedEntityId = parentId;
        contentDocumentInsert.ShareType = 'V';
        insert contentDocumentInsert;

        Test.startTest();
        contentVersionInsert = DragNDropController.getProfilePicture(parentId);
        Test.stopTest();

        System.assertEquals(true, contentVersionInsert.IsLatest, 'Image found');
    }

    /**
     * Test file associated with ContentDocumentId from Content Version, QueryException.
     */
    @isTest static void testGetProfilePictureException() {
        DragNDropController.CustomExceptionData getException = new DragNDropController.CustomExceptionData(
            'error',
            'error'
            );

        String errorMessage = 'Script-thrown exception';
        Test.startTest();
        try {
            ContentVersion contentVersionInsert;
            contentVersionInsert = DragNDropController.getProfilePicture(null);
        } catch (AuraHandledException e) {
            getException.message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(errorMessage, getException.message);
    }

    /**
     * Test ContentDocument deletion, positive case.
     */
    @isTest static void testDeleteFile() {
        Contact testContact = new Contact(LastName = 'hola');
        insert testContact;
        String parentId =  testContact.Id;
        ContentVersion contentVersionInsert = new ContentVersion();
        contentVersionInsert.ContentDocumentId = null;
        contentVersionInsert.VersionData = EncodingUtil.base64Decode('Test');
        contentVersionInsert.Title = 'Test';
        contentVersionInsert.PathOnClient = 'Test.jpg';
        insert contentVersionInsert;

        ContentDocumentLink contentDocumentInsert = new ContentDocumentLink();

        contentDocumentInsert.ContentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id =: contentVersionInsert.Id
            ].ContentDocumentId;

        contentDocumentInsert.LinkedEntityId = parentId;
        contentDocumentInsert.ShareType = 'V';
        insert contentDocumentInsert;

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
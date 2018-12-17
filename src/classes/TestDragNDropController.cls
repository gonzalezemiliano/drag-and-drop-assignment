/**
 * TestDragNDropController
 * Test DML operations for each method of the Apex class
 *
 * @author Emiliano Gonzalez <emiliano.gonzalez@modelit.xyz>
 * @since 2018-12
 */
@isTest
private class TestDragNDropController {
	
	/**
     * Test upload a file, positive case.
     */
	@isTest static void testSaveTheFile() {
		String parentId =  'a011U000004LcCvQAK';
		String fileName = 'example.jpg';
		String base64Data = 'Hello World';
		String contentType = 'image/jpeg';
		Test.startTest();
                DragNDropController.saveTheFile(parentId, fileName, base64Data, contentType);
		Test.stopTest();

		List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId 
                ];

		System.assert(cdl.size()>0);
	}

	/**
     * Test upload a file, dml exception.
     */
	@isTest static void testSaveTheFileException() {
		
		DragNDropController.CustomExceptionData saveException = new DragNDropController.CustomExceptionData(
			'error',
			'There was an error trying to create a Content Version'
			);

		String errorMessage = 'Script-thrown exception';

		Test.startTest();
		try {
			DragNDropController.saveTheFile('a015U000004LcCvQAK', 'example.jpg', 'Hello World', 'image/jpeg');
		} catch(AuraHandledException e) {
			saveException.message = e.getMessage();
		}
		Test.stopTest();

        System.assertEquals(errorMessage, saveException.message);
	}

	/**
     * Test file associated with ContentDocumentId from Content Version, positive case.
     */
	@isTest static void testGetProfilePicture() {
		
		// Test SELECT
		String parentId =  'a011U000004LcCvQAK';
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

		String errorMessage = 'Unable to Access Page';
		ContentVersion contentVersionInsert;
		Test.startTest();
		try {
			contentVersionInsert = DragNDropController.getProfilePicture('hola');
		} catch(AuraHandledException e) {
			getException.message = e.getMessage();
		}
		Test.stopTest();

        System.assertEquals(errorMessage, getException.message);
	}

	/**
     * Test ContentDocument deletion, positive case.
     */
	@isTest static void testDeleteTheFile() {
		String parentId =  'a011U000004LcCvQAK';
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
			DragNDropController.deleteTheFile(parentId);
		Test.stopTest();

		List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId 
                ];

		System.assert(cdl.size() == 0);
	}

	/**
     * Test ContentDocument deletion, DML Exception.
     */
	@isTest (seeAllData=true) static void testDeleteTheFileException() {
		
		DragNDropController.CustomExceptionData getException = new DragNDropController.CustomExceptionData(
			'error',
			'There was an error trying to create a Content Version'
			);

		String errorMessage = 'Unable to Access Page';

		Test.startTest();
		try {
			DragNDropController.deleteTheFile('hola');
		} catch(AuraHandledException e) {
			getException.message = e.getMessage();
		}
		Test.stopTest();

        System.assertEquals(errorMessage, getException.message);
	}
}

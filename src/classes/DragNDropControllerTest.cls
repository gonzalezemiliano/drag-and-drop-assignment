/**
 * DragNDropControllerTest
 * Test DML operations for each method of the Apex class
 *
 * @author Emiliano Gonzalez <emiliano.gonzalez@modelit.xyz>
 * @since 2018-12
 */
@isTest
private class DragNDropControllerTest {
	
	@isTest static void testSaveTheFile() {
        
		// Test INSERT
		Id parentId =  'a011U000004LcCvQAK';
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

	@isTest static void testGetProfilePicture() {
		
		// Test SELECT
		Id parentId =  'a011U000004LcCvQAK';
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

	@isTest static void testDeleteTheFile() {
		
		// Test DELETE
		Id parentId =  'a011U000004LcCvQAK';
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
}

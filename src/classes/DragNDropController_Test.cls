@isTest
private class DragNDropController_Test {
	
	@isTest static void testSaveTheFile() {
		
		// Test INSERT
		Id parentId =  'a011U000004LcCvQAK';
		String fileName = 'example.jpg';
		String base64Data = 'Hello World';
		String contentType = 'image/jpeg';
        String testing = '';
        Test.startTest();
        	testing = DragNDropController.saveTheFile(parentId, fileName, base64Data, contentType);
        Test.stopTest();
        System.assertEquals('Inserted', testing, 'Image inserted');
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
        contentDocumentInsert.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion 
        										   WHERE Id =: contentVersionInsert.Id].ContentDocumentId;
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
		String testing = '';
		ContentVersion contentVersionInsert = new ContentVersion();
        contentVersionInsert.ContentDocumentId = null;
        contentVersionInsert.VersionData = EncodingUtil.base64Decode('Test');
        contentVersionInsert.Title = 'Test';
        contentVersionInsert.PathOnClient = 'Test.jpg';
        insert contentVersionInsert;

        ContentDocumentLink contentDocumentInsert = new ContentDocumentLink();
        contentDocumentInsert.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion 
        										   WHERE Id =: contentVersionInsert.Id].ContentDocumentId;
        contentDocumentInsert.LinkedEntityId = parentId;
        contentDocumentInsert.ShareType = 'V';
        insert contentDocumentInsert;

        Test.startTest();
        	testing = DragNDropController.deleteTheFile(parentId);
        Test.stopTest();
        System.assertEquals('Deleted', testing, 'Image deleted');
	}
}
public with sharing class DragNDropController {
      
  	@AuraEnabled
	public static ContentVersion getProfilePicture(Id parentId){
		
        Id contentDocumentId = null;

        List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink 
                                        WHERE LinkedEntityId = :parentId LIMIT 1];
        if (!cdl.isEmpty()) {
            contentDocumentId=cdl[0].contentDocumentId;
        }


        ContentVersion toReturn = [SELECT VersionData, IsLatest FROM ContentVersion 
        WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true];

        if (toReturn == NULL){
            return NULL;
		}else{   
			return toReturn;
		}
	}

  	@AuraEnabled
    public static String saveTheFile(Id parentId, String fileName, String base64Data, String contentType) { 
                
        Id contentDocumentId = null;
        String insertMsg = 'Inserted';
        List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink 
                                        WHERE LinkedEntityId = :parentId LIMIT 1];
        if (!cdl.isEmpty()) {
            contentDocumentId=cdl[0].contentDocumentId;
        }

        try{
	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.ContentDocumentId = contentDocumentId;
	        cv.VersionData = EncodingUtil.base64Decode(base64Data);
	        cv.Title = fileName;
	        cv.PathOnClient = filename;
	        
	        insert cv;
	    }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            insertMsg = e.getMessage();
        }

        if(contentDocumentId == null){            
            //Create ContentDocumentLink
            ContentDocumentLink newLink = new ContentDocumentLink();
            newLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            newLink.LinkedEntityId = parentId;
            newLink.ShareType = 'V';
            insert newLink;
        }

        return insertMsg;
    }

    @AuraEnabled
    public static String deleteTheFile(Id parentId){
    	
    	String deleteMsg = 'Deleted';
    	List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink 
                                        WHERE LinkedEntityId = :parentId];
        List<ContentDocument> cd = [SELECT Id FROM ContentDocument 
                                   WHERE Id =:cdl[0].ContentDocumentId];
        try{
            delete cdl;
            delete cd;
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            deleteMsg = e.getMessage();
        }

        return deleteMsg;
    }

}
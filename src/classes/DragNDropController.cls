/**
 * DragNDropController
 * Performs DML operations to upload, show and delete images inside the Component Document 
 *
 * @author Emiliano Gonzalez <emiliano.gonzalez@modelit.xyz>
 * @since 2018-12
 */
public with sharing class DragNDropController {

    // Wrapper class for my custom exception data
    public class CustomExceptionData {
        public String name;
        public String message;

        public CustomExceptionData(String name, String message) {
            this.name = name;
            this.message = message;
        }
    }

    @AuraEnabled
    public static ContentVersion getProfilePicture(Id parentId) {
        ContentVersion contentVersion;

        try {
            List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId 
                LIMIT 1
                ];
            
            if (!cdl.isEmpty()) {
                Id contentDocumentId = cdl[0].contentDocumentId;

                contentVersion = [
                    SELECT VersionData, IsLatest
                    FROM ContentVersion 
                    WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true
                    ];
            }
        } catch(QueryException e) {
            // Throw an AuraHandledException with custom data
            CustomExceptionData data = new CustomExceptionData('There was an error trying to get the Content Version', e.getMessage());
            throw new AuraHandledException(JSON.serialize(data));
        }

        return contentVersion;
    }

    @AuraEnabled
    public static void saveTheFile(Id parentId, String fileName, String base64Data,String contentType) { 
        Id contentDocumentId = null;
        
        List<ContentDocumentLink> cdl = [
            SELECT Id, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :parentId
            LIMIT 1
            ];
        
        if (!cdl.isEmpty()) {
            contentDocumentId=cdl.get(0).contentDocumentId;
        }

        try {
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.ContentDocumentId = contentDocumentId;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.Title = fileName;
            cv.PathOnClient = filename;
            insert cv;

            if (contentDocumentId == null) {            

                    ContentDocumentLink newLink = new ContentDocumentLink();

                    newLink.ContentDocumentId = [
                        SELECT Id, ContentDocumentId 
                        FROM ContentVersion 
                        WHERE Id =: cv.Id
                        ].ContentDocumentId;

                    newLink.LinkedEntityId = parentId;
                    newLink.ShareType = 'V';
                    insert newLink;
            }
        } catch (DmlException e) {
            // Throw an AuraHandledException with custom data
            CustomExceptionData data = new CustomExceptionData('There was an error trying to create a Content Version', e.getMessage());
            throw new AuraHandledException(JSON.serialize(data));
        }

    }

    @AuraEnabled
    public static void deleteTheFile(Id parentId) {
        
        try {

            List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :parentId
                ];

            List<ContentDocument> cd = [SELECT Id FROM ContentDocument WHERE Id =:cdl[0].ContentDocumentId];
        
            delete cdl;
            delete cd;
        } catch (DmlException e) {
            // Throw an AuraHandledException with custom data
            CustomExceptionData data = new CustomExceptionData('There was an error trying to delete Content Document', e.getMessage());
            throw new AuraHandledException(JSON.serialize(data));
        }
    }
}
/**
 * Performs DML operations to upload, show and delete images inside the Component Document.
 *
 * @author Emiliano Gonzalez <emiliano.gonzalez@modelit.xyz>
 * @since 2018-12
 */
public with sharing class DragNDropController {

    // Wrapper class for my custom exception data.
    public class CustomExceptionData {
        public String name;
        public String message;

        public CustomExceptionData(String name, String message) {
            this.name = name;
            this.message = message;
        }
    }

    /**
     * Checks whether is a ContentDocumentId linked with parentId and gets a Content Version record.
     *
     * @param parentId The record ID
     * @return ContentVersion object record with blob image inside VersionData record
     */
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
        } catch (QueryException e) {
            // Throw an AuraHandledException with custom data.
            CustomExceptionData data = new CustomExceptionData(
                'There was an error trying to get the Content Version',
                e.getMessage()
                );
            throw new AuraHandledException(JSON.serialize(data));
        }

        return contentVersion;
    }

    /**
     * Create Content Version record in order to upload the image and associate the record with the parentId.
     *
     * @param parentId The record ID.
     * @param fileName The file name.
     * @param base64Data The blob image.
     * @param contentType The file type/extension.
     */
    @AuraEnabled
    public static void saveFile(Id parentId, String fileName, String base64Data, String contentType) {
        Id contentDocumentId;
        Savepoint sp;

        try {
            List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId
                LIMIT 1
                ];

            if (!cdl.isEmpty()) {
                contentDocumentId = cdl.get(0).contentDocumentId;
            }

            sp = Database.setSavepoint();

            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.ContentDocumentId = contentDocumentId;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.Title = fileName;
            cv.PathOnClient = filename;
            insert cv;

            if (contentDocumentId == null) {
                ContentDocumentLink newLink = new ContentDocumentLink(LinkedEntityId = parentId, ShareType = 'V');

                newLink.ContentDocumentId = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :cv.Id
                    ].ContentDocumentId;

                insert newLink;
            }
        } catch (QueryException e) {
            // Throw an AuraHandledException with custom data.
            CustomExceptionData data = new CustomExceptionData(
                'There was an error trying to get Content Document Link', 
                e.getMessage()
                );

            throw new AuraHandledException(JSON.serialize(data));
        } catch (DmlException e) {
            Database.rollback(sp);
            // Throw an AuraHandledException with custom data.
            CustomExceptionData data = new CustomExceptionData(
                'There was an error trying to create Content Version', 
                e.getMessage()
                );

            throw new AuraHandledException(JSON.serialize(data));
        }
    }

    /**
     * Checks whether is a ContentDocumentId linked with parentId and deletes the Content Version record.
     *
     * @param parentId The record ID.
     */
    @AuraEnabled
    public static void deleteFile(String parentId) {
        try {
            List<ContentDocumentLink> cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId
                ];

            if (!cdl.isEmpty()) {
                delete [SELECT Id FROM ContentDocument WHERE Id = :cdl[0].ContentDocumentId];
            }
        } catch (QueryException e) {
            // Throw an AuraHandledException with custom data.
            CustomExceptionData data = new CustomExceptionData(
                'There was an error trying to get the Content Document',
                e.getMessage()
                );

            throw new AuraHandledException(JSON.serialize(data));
        } catch (DmlException e) {
            // Throw an AuraHandledException with custom data.
            CustomExceptionData data = new CustomExceptionData(
                'There was an error trying to delete Content Document', 
                e.getMessage()
                );

            throw new AuraHandledException(JSON.serialize(data));
        }
    }
}
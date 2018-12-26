/**
 * Create Content Version and Content Document Link Test Records to use them in TestDragNDropController
 *
 * @author Emiliano Gonzalez <emiliano.gonzalez@modelit.xyz>
 * @since 2018-12
 */
@isTest
public class TestDataFactory {

    /**
     * Create common test Content Version records.
     */
    public static Id createContentVersion() {
        ContentVersion contentVersionInsert = new ContentVersion();
        contentVersionInsert.ContentDocumentId = null;
        contentVersionInsert.VersionData = EncodingUtil.base64Decode('Test');
        contentVersionInsert.Title = 'Test';
        contentVersionInsert.PathOnClient = 'Test.jpg';
        insert contentVersionInsert;
        return contentVersionInsert.Id;
    }

    /**
     * Create common test Content Document Link records.
     */
    public static void createContentLink(Id parentId, Id contentDocumentId) {
        ContentDocumentLink contentDocumentInsert = new ContentDocumentLink();

        contentDocumentInsert.ContentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id =: contentDocumentId
            ].ContentDocumentId;

        contentDocumentInsert.LinkedEntityId = parentId;
        contentDocumentInsert.ShareType = 'V';
        insert contentDocumentInsert;
    }
    
}
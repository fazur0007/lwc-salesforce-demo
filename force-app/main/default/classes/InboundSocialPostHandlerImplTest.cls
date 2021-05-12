@isTest
public class InboundSocialPostHandlerImplTest {
    
    static Map<String, Object> sampleSocialData;
    static Social.InboundSocialPostHandlerImpl handler;
    static InboundSocialPostHandlerImpl inbSocialPost;
    static {
        handler = new Social.InboundSocialPostHandlerImpl();
        inbSocialPost = new InboundSocialPostHandlerImpl();
        sampleSocialData = getSampleSocialData('1');
    }
    
    static testMethod void verifyNewRecordCreation() {
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);  
        
        test.startTest();
        inbSocialPost.handleInboundSocialPost(post, persona, sampleSocialData);
        inbSocialPost.findParentCaseFromPersona(post, persona);
        inbSocialPost.findParentCaseOfChatFromPersonaAndRecipient(post,persona);
        inbSocialPost.findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
        inbSocialPost.findReplyToBasedOnReplyToId(post);
        inbSocialPost.getPostTags(post);
        inbSocialPost.isSocialPostRecipientSameAsPersona(post,persona);
        inbSocialPost.hasPostTagsThatCreateCase(post);
        InboundSocialPostHandlerImpl.PostAttachment pstAttachList = new InboundSocialPostHandlerImpl.PostAttachment('Facebook','https://www.xyz.com');
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Account createdAccount = [SELECT Id FROM Account];
        Case createdCase = [SELECT Id, AccountId FROM Case];
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.AccountId, createdAccount.Id, 'Contact is not linked to the Case.');
    }
    static testMethod void verifyNewRecordCreationMethod() {
        SocialPost post = getSocialPostOne(sampleSocialData);
        SocialPersona persona = getSocialPersonaOne(sampleSocialData);  
        
        test.startTest();
        inbSocialPost.handleInboundSocialPost(post, persona, sampleSocialData);
        inbSocialPost.findParentCaseFromPersona(post, persona);
        inbSocialPost.findParentCaseOfChatFromPersonaAndRecipient(post,persona);
        inbSocialPost.findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
        inbSocialPost.findReplyToBasedOnReplyToId(post);
        InboundSocialPostHandlerImpl.PostAttachment pstAttachList = new InboundSocialPostHandlerImpl.PostAttachment('Facebook','https://www.xyz.com');
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Account createdAccount = [SELECT Id FROM Account];
        Case createdCase = [SELECT Id, AccountId FROM Case];
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.AccountId, createdAccount.Id, 'Contact is not linked to the Case.');
    }
    
    static testMethod void matchSocialPostRecord() {
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.R6PostId = existingPost.R6PostId;
        SocialPersona persona = getSocialPersona(sampleSocialData);
        
        test.startTest();
        inbSocialPost.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM SocialPost].size(), 'There should be only 1 post');
    }
    
    static testMethod void matchSocialPersonaRecord() {
        
        Account existingAccount = new Account(Name = 'LastName');
        insert existingAccount;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingAccount.Id;
        insert existingPersona;
        
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        persona.ExternalId = existingPersona.ExternalId;
        
        test.startTest();
        inbSocialPost.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Account createdAccount = [SELECT Id FROM Account];
        Case createdCase = [SELECT Id, AccountId FROM Case];
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Account');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.AccountId, createdAccount.Id, 'Account is not linked to the Case.');
    }
    
    static testMethod void matchCaseRecord() {
        
        Account existingAccount = new Account(Name = 'LastName');
        insert existingAccount;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingAccount.Id;
        insert existingPersona;
        Case existingCase = new Case(AccountId = existingAccount.Id, Subject = 'Test Case');
        insert existingCase;
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingAccount.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        
        test.startTest();
        inbSocialPost.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingAccount.Id, createdPost.WhoId, 'Post is not linked to the Account');
        System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
    }
    
    static testMethod void reopenClosedCase() {
        
        Account existingAccount = new Account(Name = 'LastName');
        insert existingAccount;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingAccount.Id;
        insert existingPersona;
        Case existingCase = new Case(AccountId = existingAccount.Id, Subject = 'Test Case', Status = 'Closed');
        insert existingCase;
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingAccount.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        
        test.startTest();
        inbSocialPost.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingAccount.Id, createdPost.WhoId, 'Post is not linked to the Account');
        System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
        System.assertEquals(false, [SELECT Id, IsClosed FROM Case WHERE Id = :existingCase.Id].IsClosed, 'Case should be open.');
    }
    
    static SocialPost getSocialPost(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
        post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.PostTags = String.valueOf(socialData.get('postTags'));
        post.Recipient = String.valueOf(socialData.get('recipient'));
        post.ReviewScore = Integer.valueOf(socialData.get('reviewScore'));
        post.ReviewScale = Integer.valueOf(socialData.get('reviewScale'));
        post.ResponseContextExternalId = string.valueOf(socialData.get('responseContextExternalId'));
        post.TopicProfileName = string.valueOf(socialData.get('topicProfileName'));
        
        return post;
    }
    static SocialPost getSocialPostOne(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
        post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider1'));
        post.MessageType = String.valueOf(socialData.get('messageType1'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.PostTags = String.valueOf(socialData.get('postTags'));
        post.Recipient = String.valueOf(socialData.get('recipient'));
        post.ReviewScore = Integer.valueOf(socialData.get('reviewScore'));
        post.ReviewScale = Integer.valueOf(socialData.get('reviewScale'));
        post.ResponseContextExternalId = string.valueOf(socialData.get('responseContextExternalId'));
        post.TopicProfileName = string.valueOf(socialData.get('topicProfileName'));
        return post;
    }
    
    static SocialPersona getSocialPersona(Map<String, Object> socialData) {
        SocialPersona persona = new SocialPersona();
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider'));
        persona.ExternalId = String.valueOf(socialData.get('externalUserId'));        
        return persona;
    }
    static SocialPersona getSocialPersonaOne(Map<String, Object> socialData) {
        SocialPersona persona = new SocialPersona();
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider2'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider2'));
        persona.ExternalId = String.valueOf(socialData.get('externalUserId'));        
        return persona;
    }
    
    static Map<String, Object> getSampleSocialData(String suffix) {
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postTags', 'A,B');
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        socialData.put('content', 'Content' + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('replyTo', 'ReplyTo');
        socialData.put('reviewScore', 5);
        socialData.put('messageType1', 'Private');
        socialData.put('reviewScale',5);
        socialData.put('recipient', 'Recipient');
        socialData.put('responseContextExternalId','ResponseContextExternalId');
        socialData.put('topicProfileName','scstest');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('mediaProvider1', 'Facebook');
        socialData.put('mediaProvider2', 'Other');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Tweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        return socialData;
    }
}
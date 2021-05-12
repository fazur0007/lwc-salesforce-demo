global virtual class InboundSocialPostHandlerImpl implements Social.InboundSocialPostHandler
{
    final static Integer CONTENT_MAX_LENGTH = SocialPost.Content.getDescribe().getLength();
    final static Integer SUBJECT_MAX_LENGTH = Case.Subject.getDescribe().getLength();
    Boolean isNewCaseCreated = false;
    // Reopen case if it has not been closed for more than this number
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {
        return 5;
    }
    // Create a case if one of these post tags are on the SocialPost, regardless of the
    //skipCreateCase indicator.
    global virtual Set<String> getPostTagsThatCreateCase(){
        return new Set<String>();
    }
    // If true, use the active case assignment rule if one is found
    global virtual Boolean getUsingCaseAssignmentRule(){
        return false;
    }
    global virtual String getDefaultAccountId() {
        return null;
    }
    global virtual String getCaseSubject(SocialPost post) {
        String caseSubject = post.Name;
        if (hasReview(post)) {
            String ratingsStr = getRatingString(post);
            caseSubject = ratingsStr + ' • ' + caseSubject;
        }
        return caseSubject;
    }
    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post,
                                                                  SocialPersona persona, Map<String, Object> rawData) {
                                                                      Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
                                                                      result.setSuccess(true);
                                                                      matchPost(post);
                                                                      matchPersona(persona);
                                                                      if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
                                                                          post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
                                                                      }
                                                                      if (post.Id != null) {
                                                                          handleExistingPost(post, persona);
                                                                          return result;
                                                                      }
                                                                      setReplyTo(post, persona);
                                                                      /* Changes for BEC-4901 W-000258 to pass Post Object with Persona.
                                                                         From Post Object, the currency will be identified through Profile Name*/
                                                                      buildPersona(persona,post);
                                                                      Case parentCase = buildParentCase(post, persona, rawData);
                                                                      setRelationshipsOnPost(post, persona, parentCase);
                                                                      setModeration(post, rawData);
                                                                      upsert post;
                                                                      if(isNewCaseCreated){
                                                                          updateCaseSource(post, parentCase);
                                                                      }
                                                                      handlePostAttachments(post, rawData);
                                                                      
                                                                      
                                                                      return result;
                                                                  }
    private void setModeration(SocialPost post, Map<String, Object> rawData){
        //if we don't automatically create a case, we should flag the post as requiring
        //moderator review.
        if(post.parentId == null && !isUnsentParent(rawData))
            post.reviewedStatus = 'Needed';
    }
    @testVisible
    private void updateCaseSource(SocialPost post, Case parentCase){
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
        }
    }
    private void handleExistingPost(SocialPost post, SocialPersona persona) {
        List<SocialPost> existingPosts = [Select Recipient, IsOutbound from SocialPost where
                                          id = :post.Id limit 1];
        // for any existing outbound post, we don't overwrite its recipient field
        if (!existingPosts.isEmpty() && existingPosts[0].IsOutBound == true &&
            String.isNotBlank(existingPosts[0].Recipient)) {
                post.Recipient = existingPosts[0].Recipient;
            }
        update post;
        if (persona.id != null)
            updatePersona(persona);
    }
    private void setReplyTo(SocialPost post, SocialPersona persona) {
        SocialPost replyTo = findReplyTo(post, persona);
        if(replyTo.id != null) {
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }
    private SocialPersona buildPersona(SocialPersona persona,  socialpost post) {
        if (persona.Id == null)
            createPersona(persona,post);
        else
            updatePersona(persona);
        return persona;
    }
    private void updatePersona(SocialPersona persona) {
        try{
            update persona;
        }catch(Exception e) {
            System.debug('Error updating social persona: ' + e.getMessage());
        }
    }
    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object>
                                 rawData){
                                     if(!isUnsentParent(rawData)) {
                                         Case parentCase = findParentCase(post, persona);
                                         if (parentCase != null) {
                                             if (!parentCase.IsClosed) {
                                                 return parentCase;
                                             }
                                             else if (caseShouldBeReopened(parentCase)) {
                                                 reopenCase(parentCase);
                                                 return parentCase;
                                             }
                                         }
                                         if(shouldCreateCase(post, rawData)){
                                             isNewCaseCreated = true;
                                             return createCase(post, persona);
                                         }
                                     }
                                     return null;
                                 }
    private boolean caseShouldBeReopened(Case c){
        return c.id != null && c.isClosed && System.now() <
            c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());
    }
    private void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona,
                                        Case parentCase) {
                                            if (persona.Id != null) {
                                                postToUpdate.PersonaId = persona.Id;
                                                if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                                                    postToUpdate.WhoId = persona.ParentId;
                                                }
                                            }
                                            if(parentCase != null) {
                                                postToUpdate.ParentId = parentCase.Id;
                                            }
                                        }
    private Boolean hasReview(SocialPost post) {
        return post.ReviewScore != null;
    }
    private String getRatingString(SocialPost post) {
        Integer maxNumberOfStars = 5;
        Double reviewScore = post.ReviewScore;
        Double reviewScale = post.ReviewScale;
        if (reviewScore == null) {
            reviewScore = 0;
        }
        if (reviewScale == null) {
            reviewScale = maxNumberOfStars;
        }
        Integer numberOfStars = Math.floor((reviewScore / reviewScale) *
                                           maxNumberOfStars).intValue();
        return numberOfStars.format() + '-Star';
    }
    private Case createCase(SocialPost post, SocialPersona persona) {
        String caseSubject = getCaseSubject(post).abbreviate(SUBJECT_MAX_LENGTH);
        /* Changes for BEC-4901 W-000258 to trigger assignment rules for the case.
           Also queried the meta data to fetch currency and country based on the topic profile */
        string country;
        //Fetching the assignment rules on case
        AssignmentRule assRule = new AssignmentRule();
        assRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        List<Social_Metadata__mdt> socialMetadataList = [SELECT Currency__c,Id,Network_Type__c,Topic_Profile_Name__c, Country__c FROM Social_Metadata__mdt WHERE Topic_Profile_Name__c = :post.TopicProfileName AND Network_Type__c = :persona.MediaType];
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= assRule.id; 
        Case newCase = new Case(subject = caseSubject);
        newCase.setOptions(dmlOpts);
        if (persona != null && persona.ParentId != null) {
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                newCase.ContactId = persona.ParentId;
            } else if (persona.ParentId.getSObjectType() == Account.sObjectType) {
                newCase.AccountId = persona.ParentId;
            }
        }
        /* Changes for BEC-4901 W-000258 for assigning Origin and Sub Origin and Country*/
        if (post != null && post.Provider != null) {
            newCase.Origin = 'Social';
        }
        if (post != null && post.Provider != null) {
            newCase.Case_Sub__c = post.Provider;
        }
        /* Changes for BEC-4901 W-000258 to autopopulate the user’s initial message into the description section of a SF case */
         if (post != null && post.Provider != null) {
            newCase.Description = post.Content;
        }
        
        if (post != null && post.TopicProfileName != null) {
            if(socialMetadataList != null && socialMetadataList.size() > 0) {
                if(socialMetadataList[0].Country__c != null) {
                    newCase.Country__c = socialMetadataList[0].Country__c;
                }
                if(socialMetadataList[0].Currency__c != null) {
                	newCase.CurrencyIsoCode = socialMetadataList[0].Currency__c;
                }
            } 
            else {
                country      =   'USA'; 
                newCase.Country__c = country;
            }
            
        }
        
        insert newCase;
        return newCase;
    }
    private Case findParentCase(SocialPost post, SocialPersona persona) {
        Case parentCase = null;
        if (!isChat(post) && (isReplyingToOutboundPost(post) &&
                              isSocialPostRecipientSameAsPersona(post.ReplyTo, persona)) ||
            (!isReplyingToOutboundPost(post) && isReplyingToSelf(post,persona))) {
                parentCase = findParentCaseFromPostReply(post);
                if (isParentCaseValid(parentCase)) {
                    return parentCase;
                }
            }
        parentCase = findParentCaseFromPersonaAndRecipient(post, persona);
        if (parentCase == null && isChat(post)) {
            parentCase = findParentCaseOfChatFromPersonaAndRecipient(post, persona);
        }
        return parentCase;
    }
    private boolean isChat(SocialPost post) {
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }
    private boolean isParentCaseValid(Case parentCase) {
        return parentCase != null && (!parentCase.IsClosed ||
                                      caseShouldBeReopened(parentCase));
    }
    private Case findParentCaseFromPostReply(SocialPost post) {
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE
                                Id = :post.ReplyTo.ParentId LIMIT 1];    
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    // reply to outbound post
    private boolean isReplyingToOutboundPost(SocialPost post) {
        return (post != null && post.ReplyTo != null && post.ReplyTo.IsOutbound);
    }
    // replyTo.recipient == inboundSocialPost.persona.externalId
  @testVisible
    private boolean isSocialPostRecipientSameAsPersona(SocialPost postWithRecipient,
                                                       SocialPersona persona) {
                                                           return (postWithRecipient != null && postWithRecipient.Recipient ==
                                                                   persona.ExternalId);
                                                       }
    // is replying to self
    private boolean isReplyingToSelf(SocialPost post, SocialPersona persona) {
        return (post != null &&
                persona != null &&
                String.isNotBlank(persona.Id) &&
                post.ReplyTo != null &&
                String.isNotBlank(post.ReplyTo.PersonaId) &&
                post.ReplyTo.PersonaId == persona.id);
    }
    @testVisible
    private Case findParentCaseFromPersona(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersona =
            findLatestInboundPostBasedOnPersona(post, persona);
        if (lastestInboundPostWithSamePersona != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE
                                id = :lastestInboundPostWithSamePersona.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    private Case findParentCaseFromPersonaAndRecipient(SocialPost post, SocialPersona
                                                       persona) {
                                                           SocialPost lastestInboundPostWithSamePersonaAndRecipient =
                                                               findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
                                                           if (lastestInboundPostWithSamePersonaAndRecipient != null) {
                                                               List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE
                                                                                   id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
                                                               if(!cases.isEmpty()) {
                                                                   return cases[0];
                                                               }
                                                           }
                                                           return null;
                                                    }
     @testVisible  
    private Case findParentCaseOfChatFromPersonaAndRecipient(SocialPost post, SocialPersona
                                                             persona) {
                                                                 SocialPost lastestReplyToPost =
                                                                     findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(post, persona);
                                                                 if (lastestReplyToPost != null) {
                                                                     List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE
                                                                                         id = :lastestReplyToPost.parentId LIMIT 1];
                                                                     if(!cases.isEmpty()) {
                                                                         return cases[0];
                                                                     }
                                                                 }
                                                                 return null;
                                                             }
    private void reopenCase(Case parentCase) {
        SObject[] status = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND
                            IsDefault = true];
        parentCase.Status = ((CaseStatus)status[0]).MasterLabel;
        update parentCase;
    }
    private void matchPost(SocialPost post) {
        if (post.Id != null) return;
        performR6PostIdCheck(post);
        if (post.Id == null){
            performExternalPostIdCheck(post);
        }
    }
    private void performR6PostIdCheck(SocialPost post){
        if(post.R6PostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE R6PostId =
                                     :post.R6PostId LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    private void performExternalPostIdCheck(SocialPost post) {
        if (post.provider == 'Facebook' && post.messageType == 'Private') return;
        if (post.provider == null || post.externalPostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId =
                                     :post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    private SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        if(post.replyToId != null && post.replyTo == null)
            return findReplyToBasedOnReplyToId(post);
        if(post.responseContextExternalId != null){
            if((post.provider == 'Facebook' && post.messageType == 'Private') ||
               (post.provider == 'Twitter' && post.messageType == 'Direct')) {
                   SocialPost replyTo =
                       findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                   if(replyTo.id != null)
                       return replyTo;
               }
            return findReplyToBasedOnExternalPostIdAndProvider(post);
        }
        return new SocialPost();
    }
    @testVisible
    private SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient
                                  FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    private SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient
                                  FROM SocialPost WHERE Provider = :post.provider AND ExternalPostId =
                                  :post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    @testVisible
    private SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost
                                                                                  post){
                                                                                      List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost
                                                                                                                WHERE Provider = :post.provider AND Recipient = :post.Recipient AND
                                                                                                                responseContextExternalId = :post.responseContextExternalId ORDER BY posted DESC NULLS
                                                                                                                LAST LIMIT 1];
                                                                                      if(posts.isEmpty())
                                                                                          return new SocialPost();
                                                                                      return posts[0];
                                                                                  }
    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post,
                                                                       SocialPersona persona) {
                                                                           if (persona != null && String.isNotBlank(persona.Id) && post != null &&
                                                                               String.isNotBlank(post.Recipient)) {
                                                                                   List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider
                                                                                                             = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound
                                                                                                             = false ORDER BY CreatedDate DESC LIMIT 1];
                                                                                   if (!posts.isEmpty()) {
                                                                                       return posts[0];
                                                                                   }
                                                                               }
                                                                           return null;
                                                                       }
    private SocialPost findLatestInboundPostBasedOnPersona(SocialPost post, SocialPersona
                                                           persona) {
                                                               if (persona != null && String.isNotBlank(persona.Id) && post != null) {
                                                                   List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider
                                                                                             = :post.provider AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate
                                                                                             DESC LIMIT 1];
                                                                   if (!posts.isEmpty()) {
                                                                       return posts[0];
                                                                   }
                                                               }
                                                               return null;
                                                           }
    private SocialPost findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(SocialPost
                                                                               post, SocialPersona persona) {
                                                                                   if (persona != null && String.isNotBlank(persona.Id) && post != null) {
                                                                                       List<ExternalSocialAccount> accounts = [SELECT Id FROM ExternalSocialAccount
                                                                                                                               WHERE ExternalAccountId = :post.Recipient];
                                                                                       if (!accounts.isEmpty()) {
                                                                                           ExternalSocialAccount account = accounts[0];
                                                                                           List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider
                                                                                                                     = :post.provider AND Recipient = :persona.ExternalId AND OutboundSocialAccountId =
                                                                                                                     :account.Id AND IsOutbound = true ORDER BY CreatedDate DESC LIMIT 1];
                                                                                           if (!posts.isEmpty()) {
                                                                                               return posts[0];
                                                                                           }
                                                                                       }
                                                                                   }
                                                                                   return null;
                                                                               }
    private void matchPersona(SocialPersona persona) {
        if (persona != null) {
            List<SocialPersona> personaList = new List<SocialPersona>();
            if (persona.Provider != 'Other') {
                if (String.isNotBlank(persona.ExternalId)) {
                    personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                                   Provider = :persona.Provider AND
                                   ExternalId = :persona.ExternalId LIMIT 1];
                }
                else if (String.isNotBlank(persona.Name)) {
                    //this is a best-effort attempt to match: persona.Name is not guaranteed to be unique for all networks
                    
                    personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                                   Provider = :persona.Provider AND
                                   Name = :persona.Name LIMIT 1];
                }
            }
            else if(persona.Provider == 'Other' && String.isNotBlank(persona.ExternalId)
                    && String.isNotBlank(persona.MediaProvider)) {
                        personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                                       MediaProvider = :persona.MediaProvider AND
                                       ExternalId = :persona.ExternalId LIMIT 1];
                    } else if(persona.Provider == 'Other' && String.isNotBlank(persona.Name) &&
                              String.isNotBlank(persona.MediaProvider)) {
                                  personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                                                 MediaProvider = :persona.MediaProvider AND
                                                 Name = :persona.Name LIMIT 1];
                              }
            if (!personaList.isEmpty()) {
                persona.Id = personaList[0].Id;
                persona.ParentId = personaList[0].ParentId;
            }
        }
    }
    private void createPersona(SocialPersona persona, socialpost post) {
        if (persona == null || String.isNotBlank(persona.Id) ||
            !isThereEnoughInformationToCreatePersona(persona))
            return;
        SObject parent = createPersonaParent(persona, post);
        persona.ParentId = parent.Id;
        insert persona;
    }
    private boolean isThereEnoughInformationToCreatePersona(SocialPersona persona) {
        return String.isNotBlank(persona.Name) &&
            String.isNotBlank(persona.Provider) &&
            String.isNotBlank(persona.MediaProvider);
    }
    private boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) {
        return !isUnsentParent(rawData) && (!hasSkipCreateCaseIndicator(rawData) ||
                                            hasPostTagsThatCreateCase(post));
    }
    private boolean isUnsentParent(Map<String, Object> rawData) {
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }
    private boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null &&
            'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }
    @testVisible
    private boolean hasPostTagsThatCreateCase(SocialPost post){
        Set<String> postTags = getPostTags(post);
        postTags.retainAll(getPostTagsThatCreateCase());
        
        return !postTags.isEmpty();
    }
    @testVisible
    private Set<String> getPostTags(SocialPost post){
        Set<String> postTags = new Set<String>();
        if(post.postTags != null)
            postTags.addAll(post.postTags.split(',', 0));
        return postTags;
    }
    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }
    global String getPersonaLastName(SocialPersona persona) {
        String name = getPersonaName(persona);
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }
    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }
    global virtual SObject createPersonaParent(SocialPersona persona, socialpost post) {
        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);
        string mediaType= persona.MediaType;
        /* Changes for BEC-4901 W-000258 to query meta data to assign currency on the account*/
        List<Social_Metadata__mdt> socialMetadataList = [SELECT Currency__c,Id,Network_Type__c,Topic_Profile_Name__c, Country__c 
                                                            FROM Social_Metadata__mdt 
                                                        WHERE Topic_Profile_Name__c = :post.TopicProfileName 
                                                        AND Network_Type__c = :persona.MediaType];

        string curr;
        if(socialMetadataList != null && socialMetadataList.size() > 0 && socialMetadataList[0].Currency__c != null) {
            
            curr      =   socialMetadataList[0].Currency__c;
        } 
        else {
            curr      =   'USD';  
        }
        Account acct = new Account (LastName = lastName, FirstName = firstName,  CurrencyIsoCode= curr, AccountSource= 'Social');
        insert acct;
        
        return acct;
    }
    private void handlePostAttachments(SocialPost post, Map<String, Object> rawData) {
        
        String attachmentRawData = JSON.serialize(rawData.get('mediaUrls'));
        if (String.isNotBlank(attachmentRawData)) {
            List<PostAttachment> attachments = (List<PostAttachment>)
                JSON.deserialize(attachmentRawData, List<PostAttachment>.class);
            if (attachments != null && !attachments.isEmpty()) {
                createAttachments(post, attachments);
            }
        }
    }
    private void createAttachments(SocialPost post, List<PostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(PostAttachment attachment : attachments) {
            /* Changes for BEC-4901 W-000258. Added mediaType condition to ignore the UNKNOWN media type attachment. */
            if (String.isNotBlank(attachment.mediaUrl) && attachment.mediaUrl != null &&
                attachment.mediaUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength() && attachment.mediaType != 'UNKNOWN') {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.contentUrl = attachment.mediaUrl;
                    contentVersion.contentLocation = 'L';
                    contentVersions.add(contentVersion);
                }
        }
        if (!contentVersions.isEmpty()) {
            insert(contentVersions);
            createLinksForAttachmentsToSocialPost(post, contentVersions);
        }
    }
    
    private void createLinksForAttachmentsToSocialPost(SocialPost post, List<ContentVersion>
                                                       contentVersions) {
                                                           List<Id> versionIds = new List<Id>(new Map<Id,
                                                                                              ContentVersion>(contentVersions).keySet());
                                                           List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE
                                                                                                     LatestPublishedVersionId IN :versionIds];
                                                           List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                                                           for(ContentDocument contentDocument : contentDocuments) {
                                                               ContentDocumentLink contentDocLink = new ContentDocumentLink();
                                                               contentDocLink.contentDocumentId = contentDocument.Id;
                                                               contentDocLink.linkedEntityId = post.Id;
                                                               contentDocLink.shareType = 'I';
                                                               contentDocLink.visibility = 'AllUsers';
                                                               contentDocumentLinks.add(contentDocLink);
                                                           }
                                                           if (!contentDocumentLinks.isEmpty()) {
                                                               insert(contentDocumentLinks);
                                                           }
                                                       }
    public class PostAttachment {
        public String mediaType;
        public String mediaUrl;
        public PostAttachment(String mediaType, String mediaUrl) {
            this.mediaType = mediaType;
            this.mediaUrl = mediaUrl;
        }
    }
}
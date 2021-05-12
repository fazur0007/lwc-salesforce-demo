public with sharing class SlackUtility {
    
    public static void postToSlack(String action, SlackPost post) {
        System.enqueueJob(new qCallOut(action, post));
    }
    
    private static String getHookURL(String action) {
        String result = '';
        List<SlackWebHook__mdt> hooks = [SELECT DeveloperName, Id, Label, Language, MasterLabel, WebhookURL__c 
                                      FROM SlackWebHook__mdt
                                      WHERE DeveloperName = :action];
        if (hooks.size() > 0) {
            result = hooks[0].WebhookURL__c;
        }
        return result;
    }
    
    public class SlackPost {
        public String fallback;
        public String text;
        public String pretext;
        public String icon_emoji;
        public String color;
        public List<SlackField> fields;
        private Boolean overrideIcon;
        public Boolean isSuccess {
            get; 
            public set {
                this.isSuccess = value;
                if (this.overrideIcon != null && this.overrideIcon) {
                    this.icon_emoji = this.isSuccess ? ':heavy_check_mark:' : ':x:';
                }
                this.color = this.isSuccess ? 'good' : 'danger';
            }
        }
        
        public SlackPost() {
            this.isSuccess = true;
            this.overrideIcon = false;
        }
        
        public SlackPost(Boolean overrideIcon) {
            this();
            this.overrideIcon = overrideIcon;
        }
        
        public String getJSON() {
            return JSON.serialize(this, true);
        }
    }
    
    public class SlackField {
        public String title;
        public String value;
        public SlackField(String title, String value) {
            this.title = title;
            this.value = value;
        }
    }
    
    public class qCallOut implements System.Queueable, Database.AllowsCallouts {
         
        private final String action;
        private final SlackPost post;
         
        public qCallOut(String action, SlackPost post) {
            this.action = action;
            this.post = post;
        }
         
        public void execute(System.QueueableContext ctx) {
            
            String url = getHookURL(action);
        
            if (String.isBlank(url)) {
                ErrorLog.LogErrorActivity('', 'Unable to find the web hook URL', 'Slack Post', true, 'Error');
                return;
            }
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setBody(post.getJSON());
            req.setTimeout(120000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() != 200) {
                ErrorLog.LogErrorActivity('', res.getBody(), 'Slack Post', true, 'Error');
            }
        }
    }
}
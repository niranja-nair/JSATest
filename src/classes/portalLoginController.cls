public with sharing class portalLoginController 
{
    public string userName {get; set;}
    public string pw {get; set;}
    
    public String ssoLoginURL
    {
        get
        {
            string urlBase = 'https://login.salesforce.com/services/auth/sso/00D4000000091qUEAQ/MyJSA';
            string siteParam = 'startURL=%2Fapex%2FJSAProfile';
            
            return urlBase+'?'+siteParam;
        }
    }
    
    public pageReference portalLogin() 
    {
        return Site.login(userName,pw,'/apex/JSAhome');
    }
}
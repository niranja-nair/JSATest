public class FacebookAuthProvider implements Auth.RegistrationHandler {
	
    public User createUser(Id portalId, Auth.UserData userData) {
        User user;

        List<User> users = [SELECT Id FROM User WHERE UserName = :userData.email];
        
        if (users.size() > 0) {
            user = users[0];
            user.Email = userData.email;
            user.LastName = userData.lastName;
            user.FirstName = userData.firstName;
            update user;
        } else {
            // Portal users need an associated contact, which, in turn,
            // needs to be associated with an account.
            // these should be owned by the site user to keep from role problems
            User myJSASiteUser = [SELECT Id FROM User WHERE Name = 'Micah Perry' and UserRole.Name = 'Campus Director'];
          
            Account account = new Account();
            account.Name = userData.firstName + ' ' + userData.lastName;
            insert account;
            
            Contact contact = new Contact();
            contact.AccountId = account.Id;
            contact.Email = userData.email;
            contact.FirstName = userData.firstName;
            contact.LastName = userData.lastName;
            contact.OwnerId = myJSASiteUser.id;
            insert contact;

			Profile profile = [SELECT Id FROM Profile WHERE Name = 'JSA Community User'];

            user = new User();
            user.UserName = userData.email;
            user.Email = userData.email;
            user.FirstName = userData.firstName;
            user.LastName = userData.lastName;
            user.Alias = (userData.username != null) ? userData.username : userData.identifier;
            
            if (user.Alias.length() > 8) {
                user.Alias = user.Alias.substring(0, 8);
            }
            
            user.Languagelocalekey = UserInfo.getLocale();
            user.Localesidkey = UserInfo.getLocale();
            user.EmailEncodingKey = 'UTF-8';
            user.TimeZoneSidKey = 'America/Los_Angeles';
            user.ProfileId = profile.Id;
            user.ContactId = contact.Id;
        }

        return user;
    }

    public void updateUser(Id userId, Id portalId, Auth.UserData userData) {
        User user = new User(Id=userId);
        user.UserName = userData.email;
        user.Email = userData.email;
        user.FirstName = userData.firstName;
        user.LastName = userData.lastName;
        user.Alias = userData.username;
        
        if (user.Alias.length() > 8) {
            user.Alias = user.Alias.substring(0, 8);
        }
        
        update user;
    }

}
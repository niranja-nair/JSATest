@isTest
private class FacebookAuthProviderTest {

    static testMethod void testCreateUserNew() {
    	String email = 'test' + System.currentTimeMillis() + '@test.com';
    	
        Auth.UserData userData = new Auth.UserData('testId', 'First', 'Last',
            'First Last', email, null, 'username', 'en_US', 'facebook',
            null, new Map<String, String>{});
        
        FacebookAuthProvider facebookAuthProvider = new FacebookAuthProvider();
        User user = facebookAuthProvider.createUser(null, userData);

        System.assertEquals(email, user.UserName);
        System.assertEquals(email, user.Email);
        System.assertEquals('Last', user.LastName);
        System.assertEquals('First', user.firstName);
        System.assertEquals('username', user.alias);

    }
    
    static testMethod void testUpdateUser() {
        Account acc = testUtils.createAccounts(1,'hsAcc','aa-aaa')[0];
        insert acc;
        
        Contact ct = testUtils.createContacts(1,'bort',acc.id)[0];
        insert ct;
        
        User u = testUtils.createPortalUser('bort@bort.com.bort',ct.id);
        system.runAs(testUtils.sysadmin)
        {
            insert(u);
        }
        
        FacebookAuthProvider handler = new FacebookAuthProvider();
        
        Auth.UserData sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
            'testNewFirst testNewLast', 'testnewuser@myjsa123.org', null, 'testnewuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{});
           
        test.startTest();
            //this is required to prevent Mixed DML
            system.runAs(testUtils.sysadmin)
            {
                handler.updateUser(u.id, null, sampleData);
            }
        test.stopTest();
        
        User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:u.id];
        
        System.assertEquals('testnewuser@myjsa123.org', updatedUser.userName);
        System.assertEquals('testnewuser@myjsa123.org', updatedUser.email);
        System.assertEquals('testNewLast', updatedUser.lastName);
        System.assertEquals('testNewFirst', updatedUser.firstName);
        System.assertEquals('testnewu', updatedUser.alias);
    }

}
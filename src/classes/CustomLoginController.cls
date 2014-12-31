global with sharing class CustomLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global CustomLoginController () {}
    global PageReference login() {
        return Site.login(username, password, null); 
    } 
}
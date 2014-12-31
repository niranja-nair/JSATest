global with sharing class myJSAprofileController {

	public Contact contact {get; set;}
	public String highSchoolState {get; set;}
	public String highSchoolName {get; set;}
	public Boolean showEvents {get;set;}

	public void initPage() {
		Id contactId = [select ContactId from User where Id = :UserInfo.getUserId()].ContactId;
		contact = [select FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
						  Account.BillingCountry, Account.BillingState, Account.Countries__c, Account.US_States__c, AccountId,
		                  MobilePhone, Phone, Gender__c, High_School_Graduation_Year__c, Birthdate, Parent_Guardian_First_Name__c,
		                  Parent_Guardian_Last_Name__c, Parent_or_Guardian_s_Email__c, High_School__c , Category__c, JSA_Role__c, High_School_Text__c
		           from Contact
		           where Id = :contactId];
		
		showEvents = portalServices.showEvents();
		
		if (contact.High_School__c != null) {
			High_School__c hs = [select Name, State__c from High_School__c where Id = :contact.High_School__c];
			highSchoolState = hs.State__c;
			highSchoolName = hs.Name;
			contact.High_School_Text__c = highSchoolName;
		}
		
	}
	
	public void save() {
		Account updatedAccount = new Account(Id=contact.AccountId);
		updatedAccount.Countries__c = contact.Account.Countries__c;
		updatedAccount.US_States__c = contact.Account.US_States__c;
		updatedAccount.BillingCountry = contact.Account.Countries__c;
		updatedAccount.BillingState = contact.Account.US_States__c;
		contact.MailingCountry = contact.Account.Countries__c;
		contact.MailingState = contact.Account.US_States__c;
		update updatedAccount;
		update contact;
	}

	
	
	public List<SelectOption> genderOptions {
		get {
			if (genderOptions == null) {
				genderOptions = new List<SelectOption>();
				genderOptions.add(new SelectOption('Female', 'Female'));
				genderOptions.add(new SelectOption('Male', 'Male'));
			}
			
			return genderOptions;
		}
		
		private set;
	}
	
	
	
	public List<SelectOption> highSchoolStateOptions {
		get {
			if (highSchoolStateOptions == null) {
				highSchoolStateOptions = new List<SelectOption>();
				
				Set<String> states = new Set<String>();
				
				for (High_School__c highSchool : [select State__c from High_School__c where State__c != null]) {
					states.add(highSchool.State__c);
				}
				
				List<String> stateList = new List<String>();
				stateList.addAll(states);
				stateList.sort();
				
				for (String state : stateList) {
					highSchoolStateOptions.add(new SelectOption(state, state));
				}
			}

			return highSchoolStateOptions;
		}
		
		private set;
	}
	
	@remoteAction
	global static List<Map<String,String>> findSchools(String searchTerm, String highSchoolState){
		//send back the json that jquery autocomplete expects
		List<Map<String,String>> schools = new  List<Map<String,String>> {};
		//wrap the search term in wildcard characters for most flexible search
		searchTerm = '%' + searchTerm + '%';
		//SOQL in a for loop for maximum rows returned
		for(High_School__c school : [select Id, Name from High_School__c where Name like : searchTerm and State__c =: highSchoolState order by Name]){
			//using literal syntax to add anonymous maps to the list
			schools.add(new Map<String,String>{'label' => school.Name, 'value' => school.Id});
		}
		//list of maps turns to JSON by itself with JSR
		return schools;
	}

}
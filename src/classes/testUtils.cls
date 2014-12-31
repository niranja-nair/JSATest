public with sharing class testUtils 
{
	public static User sysadmin 	
	{
		get
		{
			if(sysadmin == null)
			{
				sysadmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
			}
			
			return sysadmin;
		}
		set;
	}
	
	public static User createPortalUser(string uname,Id contactId)
	{
		User u = new User();
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'Event Registration Portal User'].id;
		
		u.Username = System.currentTimeMillis() + uname;
		u.alias = 'port'; 
    	u.email = System.currentTimeMillis() + uname;
        u.emailencodingkey = 'UTF-8'; 
        u.lastname = 'nothingmuch';
        u.languagelocalekey = 'en_US'; 
        u.localesidkey = 'en_US';
        u.profileid = profileId; 
        u.contactId = contactId;
        u.timezonesidkey = 'America/Los_Angeles';
		
		return u;
	}

	public static list<opportunity> createOpportunities(integer size,string name,string stagename,date closedate)
	{
		List<Opportunity> opps = new List<Opportunity>();
		
		for(integer i=0;i<size;++i)
		{
			Opportunity opp = new Opportunity();
			opp.name = name;
			opp.stagename=  stagename;
			opp.closeDate= closeDate;
			opps.add(opp);
		}
		
		return opps;
	}
	
	public static list<Account> createAccounts(integer size,string Name, string Zone)
	{
		List<Account> accs = new List<Account>();
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		UserRole role =  [select Id from UserRole where name = 'Campus Director' limit 1];
		User u = [select Id from user where userRoleId != null limit 1];
		
		for(integer i=0;i<size;++i)
		{
			Account acc = new Account();
			acc.name = name;
			acc.OwnerId = u.id;
			acc.Zone__c = zone;
			accs.add(acc);
		}
		
		return accs;
	}
	
	
	public static list<Contact> createContacts(integer size,string LastName,Id accId)
	{
		List<Contact> cs = new List<Contact>();
		
		for(integer i=0;i<size;++i)
		{
			Contact c = new Contact();
			c.LastName = LastName;
			c.AccountId = accId;
			cs.add(c);
		}
		
		return cs;
	}
	
	public static list<Conventions__c> createConventions(List<date> startDates,string conType)
	{
		list<Conventions__c> cons = new List<Conventions__c>();
		
		for(Date startDate : startDates)
		{
			Conventions__c con = new Conventions__c();
			con.name = 'convention at ' + startDate.format();
			con.active__c = true;
			con.open_date__c = startDate;
			con.Type__c = conType;
			con.Start_Date__c = startDate;
			con.End_Date__c = startDate +5;
			con.Registration_Close_Date__c = startDate - 1;
			con.JSA_State__c = 'NC';
			cons.add(con); 
		}
		
		return cons;
	}
	
	public static list<Zone_Pricebook_Mapping__c> createZoneMappings(map<string,string> zoneToPbid)
	{
		list<Zone_Pricebook_Mapping__c> maps = new list<Zone_Pricebook_Mapping__c>();
		
		for(string zone : zoneToPbid.keySet())
		{
			Zone_Pricebook_Mapping__c mapping = new Zone_Pricebook_Mapping__c();
			mapping.Name = zone;
			mapping.pricebookId__c = zoneToPbid.get(zone);
			
			maps.add(mapping);
		}
		
		return maps;
	}
	
	public static list<PricebookEntry> createPricebookEntries(list<Product2> products,Id priceBookId)
	{	
		list<PricebookEntry> pbes = new list<PricebookEntry>();
		
		for(Product2 prod : products)
		{
			PricebookEntry pbe = new PricebookEntry();
			pbe.Product2Id = prod.id;
			pbe.Pricebook2Id = priceBookId;
			pbe.UnitPrice = 1;
			pbe.IsActive = true;
			pbe.UseStandardPrice = false;

			pbes.add(pbe);
		}
		
		return pbes;
	}
	
	public static Product2 createProduct(string Name)
	{
		Product2 prod = new Product2();
		prod.name = Name;
		prod.IsActive = true;
		return prod;
	}
	
	public static High_School__c createHighSchool(String Name, Account acc )
	{
		High_School__c hs = new High_School__c();
		hs.name = Name;
		hs.Account__c = acc.id;
		return hs;
	}
	
	public static list<Application__c> createApplications(integer size,Opportunity opp, Contact con,Product2 prod)
	{
		list<Application__c> apps = new list<Application__c>();
		for(integer i=0;i<size;++i)
		{
			Application__c app = new Application__c();
			app.Contact__c = con.id;
			app.Opportunity__c = opp.id;
			app.Product2__c = prod.id;
			apps.add(app);
		}
		
		return apps;
	}
	
	public static state_region_mapping__c createStateRegionMapping(string name,string regionName)
	{
		state_region_mapping__c mapping = new state_region_mapping__c(name=name,region_name__c = regionName);
		return mapping;
	}
	
	public static List<HotelRoom__c> createHotelRooms(integer size,Opportunity op)
	{
		List<HotelRoom__c> rooms = new List<HotelRoom__c>();
		
		for(integer i=0;i<size;++i)
		{
			HotelRoom__c rm = new HotelRoom__c();
			rm.Opportunity__c = op.id;
			rooms.add(rm);
		}
		
		return rooms;
	} 
}
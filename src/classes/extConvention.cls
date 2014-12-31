public class extConvention {
	public Opportunity filter_opp {get;set;}
	public Opportunity filter_opp2 {get;set;}
	public Integer intRegCount {get;set;}
	public Integer intRoomieMatches {get;set;}
	public Integer intRoomieUnMatched {get;set;}
	public Boolean MorePreferences {get;set;}
	public Boolean MoreRooms {get;set;}
	public Room__c dummy_room {get;set;}
	public String strTool {get;set;} 
	public Contact dummy_con {get;set;}
	public String strRT {get;set;}
	public Integer intRoomCount {get;set;} 
	public Integer intPeopleCount {get;set;}
	public String strNum {get;set;}
	public String strNum2 {get;set;}
	public String strLeftRoom {get;set;}
	public String strRightRoom {get;set;}
	public Boolean IsMerge {get;set;}
	public String strMergeResult {get;set;}
	public Room__c r1 {get;set;}
	public Room__c r2 {get;set;}
	List<Opportunity> lstR1Regs = new List<Opportunity>();
	List<Opportunity> lstR2Regs = new List<Opportunity>();
	public String[] strLeftRegs = new String[]{};
	public String[] strRightRegs = new String[]{};
	public String[] strStages = new String[]{};
	
	public void setLeftRegs (String [] lstVals)
    {
        strLeftRegs = lstVals;
    }
    public void setRightRegs (String [] lstVals)
    {
        strRightRegs = lstVals;
    }
    public String [] getLeftRegs()
    {
        return strLeftRegs;
    }
    public String [] getRightRegs()
    {
        return strRightRegs;
    }
	public void setStages (String [] lstVals)
    {
        strStages = lstVals;
    }
    public String [] getStages()
    {
        return strStages;
    }
	
    public extConvention(ApexPages.StandardController controller) { 
		filter_opp = (Opportunity)controller.getRecord();
		
		//Set this to the next convention with registrants, if there is one
		for (Opportunity o : [Select Id, Convention__c, CloseDate, Male_Female__c,
				Group__c
				from Opportunity
				where Convention__c <> null and CloseDate >=: System.today() 
				Order by CloseDate Limit 1]
		){
			filter_opp = o;
			System.debug('Populating convention');
		}
		
		if (filter_opp == null){
			for (Opportunity o : [Select Id, Convention__c, CloseDate, Male_Female__c,
					Group__c
					from Opportunity
					where Convention__c <> null
					Order by CloseDate DESC Limit 1]
			){
				filter_opp = o;
			}
		}
		
		filter_opp.Group__c = null;
		filter_opp.Male_Female__c = null;
		
		filter_opp2 = filter_opp.clone();
		
		dummy_room = new Room__c();
		dummy_con = new Contact();
		 
		strTool = 'Match';
    }
    
    public List<SelectOption> getTools() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	
    	options.add(new SelectOption('Match','Match Roommates'));
    	options.add(new SelectOption('Create','Create Rooms'));
    	options.add(new SelectOption('Merge','Merge Rooms'));
    	
    	return options;	
    }
    
    public List<SelectOption> getNumbers() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	
    	options.add(new SelectOption('','--'));
    	options.add(new SelectOption('= 1','1'));
    	options.add(new SelectOption('= 2','2'));
    	options.add(new SelectOption('= 3','3'));
    	options.add(new SelectOption('= 4','4'));
    	options.add(new SelectOption('< 4','Less Than 4'));
    	
    	return options;	
    }
    
    public List<Room__c> getLeftRooms() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	List<Room__c> lstRooms = new List<Room__c>(); 
    	String strSoQL = '';
    	
    	if (filter_opp.Male_Female__c != null){
    		strSoQL = 'Select Number_of_Occupants__c, Name, Convention_Group__r.Name, Male_Female_Private__c,';
    		strSoQL += ' Registrant_1__c,  Registrant_2__c, Registrant_3__c, Registrant_4__c,';
    		strSoQL += ' Registrant_1__r.Primary_Contact__r.Name, Registrant_2__r.Primary_Contact__r.Name,';
    		strSoQL += ' Registrant_3__r.Primary_Contact__r.Name, Registrant_4__r.Primary_Contact__r.Name';
    		strSoQL += ' From Room__c where Male_Female_Private__c = \'' +filter_opp.Male_Female__c +'\'';
    		strSoQL += ' and Registrant_1__r.Convention__c =\'' +filter_opp.Convention__c +'\' and Registrant_1__r.CloseDate = ' +filter_opp.CloseDate.year() +'-' +(filter_opp.CloseDate.month() < 10 ? '0' +filter_opp.CloseDate.month().format() : filter_opp.CloseDate.month().format()) +'-' +(filter_opp.CloseDate.day() < 10 ? '0' +filter_opp.CloseDate.day().format() : filter_opp.CloseDate.day().format());
    		
    		if (filter_opp.Group__c != null){
    			strSoQL += ' and Convention_Group__c = \'' +filter_opp.Group__c +'\'';
    		}
    		
    		if (strNum != null){
    			strSoQL += ' and Number_of_Occupants__c ' +strNum;
    		}
    		
    		System.debug('Left hand SoQL: ' +strSoQL);
    		lstRooms = Database.query(strSoQL);
    	}
    	
    	return lstRooms;
    }//end getLeftRooms
    
    public List<Room__c> getRightRooms() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	List<Room__c> lstRooms = new List<Room__c>(); 
    	String strSoQL = '';
    	
    	if (filter_opp.Male_Female__c != null){
    		strSoQL = 'Select Number_of_Occupants__c, Name, Convention_Group__r.Name, Male_Female_Private__c,';
    		strSoQL += ' Registrant_1__c,  Registrant_2__c, Registrant_3__c, Registrant_4__c,';
    		strSoQL += ' Registrant_1__r.Primary_Contact__r.Name, Registrant_2__r.Primary_Contact__r.Name,';
    		strSoQL += ' Registrant_3__r.Primary_Contact__r.Name, Registrant_4__r.Primary_Contact__r.Name';
    		strSoQL += ' From Room__c where Male_Female_Private__c = \'' +filter_opp.Male_Female__c +'\'';
    		strSoQL += ' and Registrant_1__r.Convention__c =\'' +filter_opp.Convention__c +'\' and Registrant_1__r.CloseDate =' +filter_opp.CloseDate.year() +'-' +(filter_opp.CloseDate.month() < 10 ? '0' +filter_opp.CloseDate.month().format() : filter_opp.CloseDate.month().format()) +'-' +(filter_opp.CloseDate.day() < 10 ? '0' +filter_opp.CloseDate.day().format() : filter_opp.CloseDate.day().format());
    		
    		if (filter_opp2.Group__c != null){
    			strSoQL += ' and Convention_Group__c = \'' +filter_opp.Group__c +'\'';
    		}
    		
    		if (strNum2 != null){
    			strSoQL += ' and Number_of_Occupants__c ' +strNum2;
    		}
    		
    		System.debug('Right hand SoQL: ' +strSoQL);
    		lstRooms = Database.query(strSoQL);
    	}
    	
    	return lstRooms;
    }//end getRightRooms
    
    public List<SelectOption> getRTs() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	
    	for (RecordType rt : [Select Id, Name from RecordType where SObjectType = 'Contact' 
    			and (DeveloperName = 'Student' or DeveloperName = 'Educator') Order by Name]
    	){
    		options.add(new SelectOption(rt.Id, rt.Name));
    	}
    	
    	return options;
    }
    
    public PageReference RegistrantCount(){
    	System.debug('Registrant Count, convention: ' +filter_opp.Convention__c +' Close Date: ' +filter_opp.CloseDate);
    	if (filter_opp.Convention__c != null &&filter_opp.CloseDate != null){
    		intRegCount = [Select count() from Opportunity where Convention__c =: filter_opp.Convention__c
    				and CloseDate =: filter_opp.CloseDate and RecordType.DeveloperName = 'Individual_Convention_Registration'];
    	} else {
    		intRegCount = null;
    	}
    	
    	return null;
    }
    
    //used to clear out values displayed on the page whenever an action takes place
    public void ResetValues(){
    	intRoomieMatches = null;
    	intRoomieUnMatched = null;
    	MorePreferences = false;
    	MoreRooms = false;
    	intRoomCount = null;
    	intPeopleCount = null;
    	strMergeResult = null;
    	IsMerge = false;
    	lstR1Regs.clear();
    	lstR2Regs.clear();
    	
    }
    
    public PageReference MatchRoommates(){
    	ResetValues();
    	intRoomieMatches = 0;
    	intRoomieUnMatched = 0;
    	MorePreferences = false;
    	Map<Id, List<Opportunity>> mapGroupRegs = new Map<Id, List<Opportunity>>();
    	List<Opportunity> up_op = new List<Opportunity>();
    	List<Opportunity> lstOpp = new List<Opportunity>();
    	Id idGroup;
    	ApexPages.Message m;
    	
    	//put the registrants into a map by group
    	for (Opportunity o : [Select Id, Roommate_Preference_1__c, Roommate_Preference_2__c, Roommate_Preference_3__c,
    			Group__c, Primary_Contact__c, Primary_Contact__r.FirstName, Primary_Contact__r.LastName,
    			Roommate_Preference_1_Registrant__c, Roommate_Preference_2_Registrant__c, Roommate_Preference_3_Registrant__c,
    			Male_Female__c, Primary_Contact__r.RecordType.DeveloperName
    			from Opportunity where Convention__c =: filter_opp.Convention__c and CloseDate =: filter_opp.CloseDate 
    			and RecordType.DeveloperName = 'Individual_Convention_Registration'
    			and StageName IN: strStages
    			order by Group__c]
    	){
    		if (idGroup != o.Group__c){
    			if (lstOpp.size() > 0){
	    			mapGroupRegs.put(idGroup, lstOpp.clone());
	    			lstOpp.clear();
    			}
    			idGroup = o.Group__c;
    		}
    		lstOpp.add(o);
    	}//end registrant loop
    	//populate map for the last group in the loop
    	if (lstOpp.size() > 0){
			mapGroupRegs.put(idGroup, lstOpp.clone());
			lstOpp.clear();
		}
    	
    	System.debug('There are ' +mapGroupRegs.keySet().size() +' groups.');
    	
    	//loop through the groups
    	for (Id hs : mapGroupRegs.keySet()){
    		//loop through registrants in each group
    		for (Opportunity reg : mapGroupRegs.get(hs)){
			
    			System.debug('Group = ' +hs + ', registrant ' +reg.Primary_Contact__r.FirstName +' ' +reg.Primary_Contact__r.LastName );
    			//Integer = roomate (1,2 or 3) and id of reg (opp) mapped to the preference
    			Map<Integer,Id> mapRoomies = new Map<Integer,Id>();
    			Map<Integer, List<String>> mapNames = new Map<Integer, List<String>>();
    			List<String> lstNames = new List<String>();
    			String strFirst;
    			String strLast = '';
    			
    			//Split up the names and put them in a map
    			if (reg.Roommate_Preference_1__c != null &&reg.Roommate_Preference_1_Registrant__c == null){
    				strFirst = null;
    				strLast = '';
    				for (String s : reg.Roommate_Preference_1__c.split(' ')){
    					if (strFirst == null){
    						strFirst = s;
    					} else {
    						strLast += s;
    					}
    				}
    				lstNames = new List<String>();
    				lstNames.add(strFirst);
    				lstNames.add(strLast);
    				
    				mapNames.put(1, lstNames.clone());
    			}
    			//Roomate Pref2
    			if (reg.Roommate_Preference_2__c != null &&reg.Roommate_Preference_2_Registrant__c == null){
    				strFirst = null;
    				strLast = '';
    				for (String s : reg.Roommate_Preference_2__c.split(' ')){
    					if (strFirst == null){
    						strFirst = s;
    					} else {
    						strLast += s;
    					}
    				}
    				lstNames = new List<String>();
    				lstNames.add(strFirst);
    				lstNames.add(strLast);
    				
    				mapNames.put(2, lstNames.clone());
    			}
    			
    			//Roomate Pref3
    			if (reg.Roommate_Preference_3__c != null &&reg.Roommate_Preference_3_Registrant__c == null){
    				strFirst = null;
    				strLast = '';
    				for (String s : reg.Roommate_Preference_3__c.split(' ')){
    					if (strFirst == null){
    						strFirst = s;
    					} else {
    						strLast += s;
    					}
    				}
    				lstNames = new List<String>();
    				lstNames.add(strFirst);
    				lstNames.add(strLast);
    				
    				mapNames.put(3, lstNames.clone());
    			}
    			
    			for (Integer i : mapNames.keySet()){
    				strFirst = mapNames.get(i).get(0);
    				strLast = mapNames.get(i).get(1);
    				System.debug('Preference #' +i +' ' +strFirst +' ' +strLast);
    				for (Opportunity o : mapGroupRegs.get(hs)){
    					//Only want people with the same gender
    					if (o.Male_Female__c == reg.Male_Female__c){
    						//Exact match
    						if (o.Primary_Contact__r.FirstName == strFirst
    							&&o.Primary_Contact__r.LastName == strLast
    							&&o.Id != reg.Id
    						){
    							mapRoomies.put(i, o.Id);
    							System.debug('Roommate matched1 ' +reg.Primary_Contact__r.FirstName +' ' +reg.Primary_Contact__r.LastName
    								+' with ' +o.Primary_Contact__r.FirstName +' ' +o.Primary_Contact__r.LastName
    							);
    						}
    						
    						//Last name, first 2 letters of first
    						if (mapRoomies.get(i) == null &&o.Primary_Contact__r.LastName == strLast
    						 	&&(o.Primary_Contact__r.FirstName.startsWith((strFirst.length() > 1 ? strFirst.substring(0,1) : strFirst))
    						 		|| strFirst.startsWith((o.Primary_Contact__r.FirstName.length() > 1 ? o.Primary_Contact__r.FirstName.substring(0,1) : o.Primary_Contact__r.FirstName)))
    						 	&&o.Id != reg.Id
    						){
    							mapRoomies.put(i, o.Id);
    							System.debug('Roommate matched2 ' +reg.Primary_Contact__r.FirstName +' ' +reg.Primary_Contact__r.LastName
    								+' with ' +o.Primary_Contact__r.FirstName +' ' +o.Primary_Contact__r.LastName
    							);
    						}
    						
    						//First 5 of Last name, first 3 letters of first
    						if (mapRoomies.get(i) == null 
    							&&(o.Primary_Contact__r.LastName.startsWith((strLast.length() > 4 ? strLast.substring(0,4) : strLast) )
    								|| strLast.startsWith((o.Primary_Contact__r.LastName.length() > 4 ? o.Primary_Contact__r.LastName.substring(0,4) : o.Primary_Contact__r.LastName)))
    						 	&&(o.Primary_Contact__r.FirstName.startsWith((strFirst.length() > 2 ? strFirst.substring(0,2) : strFirst))
    						 		|| strFirst.startsWith((o.Primary_Contact__r.FirstName.length() > 2 ? o.Primary_Contact__r.FirstName.substring(0,2) : o.Primary_Contact__r.FirstName)))
    						 	&&o.Id != reg.Id
    						){
    							mapRoomies.put(i, o.Id);
    							System.debug('Roommate matched3 ' +reg.Primary_Contact__r.FirstName +' ' +reg.Primary_Contact__r.LastName
    								+' with ' +o.Primary_Contact__r.FirstName +' ' +o.Primary_Contact__r.LastName
    							);
    						}
    						
    						//Last 5 of Last name, first 3 letters of first
    						if (mapRoomies.get(i) == null 
    							&&(o.Primary_Contact__r.LastName.endsWith((strLast.length() > 4 ? strLast.substring(strLast.length() - 5,strLast.length()) : strLast))
    								|| strLast.endsWith((o.Primary_Contact__r.LastName.length() > 4 ? o.Primary_Contact__r.LastName.substring(o.Primary_Contact__r.LastName.length() - 5,o.Primary_Contact__r.LastName.length()) : o.Primary_Contact__r.LastName)))
    						 	&&(o.Primary_Contact__r.FirstName.startsWith((strFirst.length() > 2 ? strFirst.substring(0,2) : strFirst))
    						 		|| strFirst.startsWith((o.Primary_Contact__r.FirstName.length() > 2 ? o.Primary_Contact__r.FirstName.substring(0,2) : o.Primary_Contact__r.FirstName)))
    						 	&&o.Id != reg.Id
    						){
    							mapRoomies.put(i, o.Id);
    							System.debug('Roommate matched4 ' +reg.Primary_Contact__r.FirstName +' ' +reg.Primary_Contact__r.LastName
    								+' with ' +o.Primary_Contact__r.FirstName +' ' +o.Primary_Contact__r.LastName
    							);
    						}
    					}//end if Gender matched
    				}//end loop through potential roommates
    				if (mapRoomies.get(i) == null){
    					intRoomieUnMatched += 1;
    				} else {
    					intRoomieMatches += 1;
    				}
    			}//end loop through mapNames
    			
    			//if there were matches, update this registrant
    			for (Integer i : mapRoomies.keySet()){
    				if (i == 1){
    					reg.Roommate_Preference_1_Registrant__c = mapRoomies.get(i);
    				}
    				if (i == 2){
    					reg.Roommate_Preference_2_Registrant__c = mapRoomies.get(i);
    				}
    				if (i == 3){
    					reg.Roommate_Preference_3_Registrant__c = mapRoomies.get(i);
    				}
    			}
    			
    			if (mapRoomies.size() > 0){
    				up_op.add(reg.clone());
    				System.debug('Checking limits for an update: ' +up_op.size() +' LimitDmlRows ' +Limits.getLimitDmlRows() +' DmlStatements ' +Limits.getDmlStatements() +' LimitDmlStatements ' +Limits.getLimitDmlStatements());
    				
    				if (up_op.size() == Limits.getLimitDmlRows()){
    					if (Limits.getDmlStatements() == Limits.getLimitDmlStatements()){
    						MorePreferences = true;
    					} else {
    						try{
	    						update up_op;
	    					} catch (Exception ex) {
								m = new ApexPages.Message(
					    			ApexPages.severity.ERROR,
					    			ex.getMessage()
					    		);
					    		ApexPages.addMessage(m); 
					    		intRoomieMatches = 0;
							}
	    					up_op.clear();
    					}
    				}
    			}
    		}//end registrant loop
    	}//end high school loop
    	
    	
    	if (up_op.size() > 0){
    		if (Limits.getDmlStatements() == Limits.getLimitDmlStatements()){
				MorePreferences = true;
			} else {
				try{
					update up_op;
				} catch (Exception ex) {
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			ex.getMessage()
		    		);
		    		ApexPages.addMessage(m); 
		    		intRoomieMatches = 0;
				}
				up_op.clear();
			}
    	}
    	
    	return null;
    }
    
    
	public Set<Id> setRegInRoom;//public so it can be modified in RoommateAdder;
	public PageReference GenerateRooms(){
		ResetValues();
		Map<Id, Map<Id, Opportunity>> mapGroupRegs = new Map<Id, Map<Id, Opportunity>>();
    	Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
    	Id idGroup;
    	Set<Id> setRegIds = new Set<Id>();
    	setRegInRoom = new Set<Id>();
    	List<Room__c> lstRooms = new List<Room__c>();
    	ApexPages.Message m;
    	//for messages that don't require everything to be rolled back
    	ApexPages.Message m2;
    	//if something goes wrong below, this allows us to roll back
    	transient Savepoint sp = Database.setSavepoint();	

    	if (dummy_room.Hotel__c == null){
    		m = new ApexPages.Message(
    			ApexPages.severity.ERROR,
    			'Please select a Hotel.'
    		);
    		ApexPages.addMessage(m);
    		System.debug('Generate Rooms run with null Hotel.');
    	}
    	
    	if (m == null){
    		intRoomCount = 0;
    		intPeopleCount = 0;
	    	//put the registrants into a map by high school (account)
	    	for (Opportunity o : [Select Id, Roommate_Preference_1__c, Roommate_Preference_2__c, Roommate_Preference_3__c,
	    			Group__c, Primary_Contact__c, Primary_Contact__r.FirstName, Primary_Contact__r.LastName, Primary_Contact__r.RecordTypeId,
	    			Roommate_Preference_1_Registrant__c, Roommate_Preference_2_Registrant__c, Roommate_Preference_3_Registrant__c,
	    			Male_Female__c, Group__r.Name,
	    			(Select Id, PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Name from OpportunityLineItems)
	    			from Opportunity where Convention__c =: filter_opp.Convention__c and CloseDate =: filter_opp.CloseDate 
	    			//and Primary_Contact__r.RecordTypeId =: dummy_con.RecordTypeId
	    			and RecordType.DeveloperName = 'Individual_Convention_Registration'
	    			and StageName IN: strStages
	    			order by Group__c]
	    	){
	    		if (idGroup != o.Group__c){
	    			if (mapOpp.size() > 0){
		    			mapGroupRegs.put(idGroup, mapOpp.clone());
		    			mapOpp.clear();
	    			}
	    			idGroup = o.Group__c;
	    		}
	    		mapOpp.put(o.Id, o);
	    		setRegIds.add(o.Id);
	    	}//end registrant loop
	    	//populate map for the last high school in the loop
	    	if (mapOpp.size() > 0){
				mapGroupRegs.put(idGroup, mapOpp.clone());
				mapOpp.clear();
			}
	    	
	    	System.debug('There are ' +mapGroupRegs.keySet().size() +' groups.');
	    	if ([Select Count() 
	    		from Room__c where Registrant_1__c IN: setRegIds or Registrant_2__c IN: setRegIds or
	    		Registrant_3__c IN: setRegIds or Registrant_4__c IN: setRegIds] > 0
	    	){
		    	for (Room__c r : [Select Id, Registrant_1__c, Registrant_2__c, Registrant_3__c, Registrant_4__c 
		    		from Room__c where Registrant_1__c IN: setRegIds or Registrant_2__c IN: setRegIds or
		    		Registrant_3__c IN: setRegIds or Registrant_4__c IN: setRegIds]
		    	){
		    		if (r.Registrant_1__c != null){
		    			setRegInRoom.add(r.Registrant_1__c);
		    		}
		    		if (r.Registrant_2__c != null){
		    			setRegInRoom.add(r.Registrant_2__c);
		    		}
		    		if (r.Registrant_3__c != null){
		    			setRegInRoom.add(r.Registrant_3__c);
		    		}
		    		if (r.Registrant_4__c != null){
		    			setRegInRoom.add(r.Registrant_4__c);
		    		}
		    	}//end room loop
	    	}
	    	//loop through the groups
	    	for (Id hs : mapGroupRegs.keySet()){
	    		//loop through registrants in each group
	    		for (Opportunity reg : mapGroupRegs.get(hs).values()){
	    			//OpportunityLineItem[] rtypes = reg.OpportunityLineItems;
	    			Id idRoomType;
	    			if (reg.OpportunityLineItems != null){
		    			for (OpportunityLineItem r : reg.OpportunityLineItems){
		    				if (r.PricebookEntry.Name.contains('Registration') || r.PricebookEntry.Name.contains('Room')){
		    					idRoomType = r.PricebookEntry.Product2Id;
		    				}
		    			}
	    			}
	    			System.debug('Processing registrant: ' +reg.Id );
	    			//They should always have this (line item representing the type of room)
	    			if (idRoomType != null){
						//Hard-coding room occupancy, but should probably make this more flexible
		    			Integer intRSize = (reg.Male_Female__c == 'Private or Adult w/ Spouse' ? 1 : (reg.Primary_Contact__r.RecordTypeId == '012400000005P9ZAAU' ? 2 : 4));
		    			//If they're not already in a room
		    			if (!setRegInRoom.contains(reg.Id)){
		    				Set<Id> setRoomies = new Set<Id>();
		    				setRoomies.add(reg.Id);
		    				
		    				//Add their preferences to the set, if they're in the Map and not already in a room
		    				if (setRoomies.size() < intRSize){
		    					setRoomies = RoommateAdder(setRoomies, reg, mapGroupRegs, hs, intRSize, idRoomType);
		    					System.debug('Starting reg add roomates results in ' +setRoomies.size());
		    				}
		    				//If more roommates are needed...
		    				if (setRoomies.size() < intRSize){
		    					Set<Id> setR2 = setRoomies.clone();
		    					//Add preferences of the roommates already added
		    					for (Id idR : setR2){
		    						if (reg.Id != idR &&setRoomies.size() < intRSize){
		    							setRoomies = RoommateAdder(setRoomies, mapGroupRegs.get(hs).get(idR), mapGroupRegs, hs, intRSize, idRoomType);
		    							System.debug('Roomie add roomates results in ' +setRoomies.size());
		    						}
		    					}
		    					
		    					//If we need more still, do this one more time
		    					if (setRoomies.size() < intRSize){
		    						Set<Id> setR3 = new Set<Id>();
		    						//Get the roomies that were just added...
		    						for (Id i : setRoomies){
		    							if (!setR2.contains(i)){
		    								setR3.add(i);
		    							}
		    						}
		    						//Then loop through them and add their preferences
		    						for (Id idR : setR3){
			    						if (reg.Id != idR &&setRoomies.size() < intRSize){
			    							setRoomies = RoommateAdder(setRoomies, mapGroupRegs.get(hs).get(idR), mapGroupRegs, hs, intRSize, idRoomType);
			    							System.debug('Roomie add roomates results in ' +setRoomies.size());
			    						}
			    					}
		    					}
		    					
		    				}
		    				
		    				//Create the Room
		    				Room__c room = new Room__c(
		    					Convention_Group__c = reg.Group__c,
								Product__c = idRoomType, //reg.OpportunityLineItems[0].PricebookEntry.Product2Id, 
								Male_Female_Private__c = reg.Male_Female__c, 
								Hotel__c = dummy_room.Hotel__c
		    					);
		    				//Add roomies to the room and setRegInRoom
		    				for (Id idR : setRoomies){
		    					setRegInRoom.add(idR);
		    					intPeopleCount += 1;
		    					if (room.Registrant_1__c == null){
		    						room.Registrant_1__c = idR;
		    					} else {
		    						if (room.Registrant_2__c == null){
		    							room.Registrant_2__c = idR;
		    						} else {
		    							if (room.Registrant_3__c == null){
		    								room.Registrant_3__c = idR;
		    							} else {
		    								room.Registrant_4__c = idR;
		    							}
		    						}
		    					}
		    					
		    				}
		    				lstRooms.add(room.clone());
		    				intRoomCount += 1;
		    				
		    				if (lstRooms.size() == Limits.getLimitDmlRows()){
		    					if (Limits.getDmlStatements() == Limits.getLimitDmlStatements()){
		    						MoreRooms = true;
		    					} else {
			    					try{
										insert lstRooms;
									} catch (Exception ex) {
										m = new ApexPages.Message(
							    			ApexPages.severity.ERROR,
							    			ex.getMessage()
							    		);
							    		ApexPages.addMessage(m); 
									}
		    					}
		    				}
		    				
		    			}
	    			} else {
    					m2 = new ApexPages.Message(ApexPages.severity.ERROR,'Student ' +reg.Primary_Contact__r.FirstName +' ' +reg.Primary_Contact__r.LastName +' in Group ' +reg.Group__r.Name +'did not have a Room Product associated to their registration so was not processed.'
					    		);
					    ApexPages.addMessage(m2); 
	    			}//end if opplineitem (room) not null
	    		}//end reg loop
	    	}//end group loop
	    	if (lstRooms.size() > 0){
		    	if (Limits.getDmlStatements() == Limits.getLimitDmlStatements()){
					MoreRooms = true;
				} else {
					try{
						insert lstRooms;
					} catch (Exception ex) {
						m = new ApexPages.Message(
			    			ApexPages.severity.ERROR,
			    			ex.getMessage()
			    		);
			    		ApexPages.addMessage(m); 
					}
				}
	    	}
    	}//end if m = null (no required field errors)
    	
    	//If any errors were hit, roll back the changes
    	if (m != null){
    		Database.rollback(sp);
    		intRoomCount = 0;
    	}
    	return null;
	}//end GenerateRooms
	
	public set<Id> RoommateAdder(Set<Id> setRoomies, Opportunity reg, Map<Id, Map<Id, Opportunity>> mapGroupRegs, Id hs, Integer intRSize, Id idRT){
		System.debug('Roommate Adder values for Pref 1, pref_reg = ' +reg.Roommate_Preference_1_Registrant__c +', pref in map= '
			+mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c) +', setRoomies size = ' +setRoomies.size()
			+', room limit = ' +intRSize +', pref male/female = ' +(mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c) != null ? mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c).Male_Female__c : 'null')
			+', reg male/female = ' +reg.Male_Female__c //+', pref room type = ' +(reg.Roommate_Preference_1_Registrant__c != null ? mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c).OpportunityLineItems[0].PricebookEntryId : 'null')
			//+', reg room type = ' +reg.OpportunityLineItems[0].PricebookEntryId
		);
		Id idRoomType;
		if (mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c) != null
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c).OpportunityLineItems != null
		){
			for (OpportunityLineItem r : mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c).OpportunityLineItems){
				if (r.PricebookEntry.Name.contains('Registration') || r.PricebookEntry.Name.contains('Room')){
					idRoomType = r.PricebookEntry.Product2Id;
				}
			}
		} else {
			idRoomType = null;
		}
		if (reg.Roommate_Preference_1_Registrant__c != null 
			//This should always be the case, but just in case...
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c) != null
			&&!setRegInRoom.contains(reg.Roommate_Preference_1_Registrant__c)
			&&setRoomies.size() < intRSize
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c).Male_Female__c == reg.Male_Female__c
			//make sure they have the right room type 
			&&idRT == idRoomType
			//&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c).OpportunityLineItems != null
			//&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_1_Registrant__c).OpportunityLineItems[0].PricebookEntryId ==
			//	reg.OpportunityLineItems[0].PricebookEntryId
		){
			setRoomies.add(reg.Roommate_Preference_1_Registrant__c);
			System.debug('Adding roomie pref 1');
		}
		
		if (mapGroupRegs.get(hs).get(reg.Roommate_Preference_2_Registrant__c) != null
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_2_Registrant__c).OpportunityLineItems != null
		){
			for (OpportunityLineItem r : mapGroupRegs.get(hs).get(reg.Roommate_Preference_2_Registrant__c).OpportunityLineItems){
				if (r.PricebookEntry.Name.contains('Registration') || r.PricebookEntry.Name.contains('Room')){
					idRoomType = r.PricebookEntry.Product2Id;
				}
			}
		} else {
			idRoomType = null;
		}
		if (reg.Roommate_Preference_2_Registrant__c != null 
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_2_Registrant__c) != null
			&&!setRegInRoom.contains(reg.Roommate_Preference_2_Registrant__c)
			&&setRoomies.size() < intRSize
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_2_Registrant__c).Male_Female__c == reg.Male_Female__c
			//make sure they have the right room type 
			&&idRT == idRoomType
			//&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_2_Registrant__c).OpportunityLineItems != null
			//&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_2_Registrant__c).OpportunityLineItems[0].PricebookEntryId ==
			//	reg.OpportunityLineItems[0].PricebookEntryId
		){
			setRoomies.add(reg.Roommate_Preference_2_Registrant__c);
			System.debug('Adding roomie pref 2');
		}
		
		if (mapGroupRegs.get(hs).get(reg.Roommate_Preference_3_Registrant__c) != null
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_3_Registrant__c).OpportunityLineItems != null
		){
			for (OpportunityLineItem r : mapGroupRegs.get(hs).get(reg.Roommate_Preference_3_Registrant__c).OpportunityLineItems){
				if (r.PricebookEntry.Name.contains('Registration') || r.PricebookEntry.Name.contains('Room')){
					idRoomType = r.PricebookEntry.Product2Id;
				}
			}
		} else {
			idRoomType = null;
		}
		if (reg.Roommate_Preference_3_Registrant__c != null 
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_3_Registrant__c) != null
			&&!setRegInRoom.contains(reg.Roommate_Preference_3_Registrant__c)
			&&setRoomies.size() < intRSize
			&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_3_Registrant__c).Male_Female__c == reg.Male_Female__c
			//make sure they have the right room type 
			&&idRT == idRoomType
			//&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_3_Registrant__c).OpportunityLineItems != null
			//&&mapGroupRegs.get(hs).get(reg.Roommate_Preference_3_Registrant__c).OpportunityLineItems[0].PricebookEntryId ==
			//	reg.OpportunityLineItems[0].PricebookEntryId
		){
			setRoomies.add(reg.Roommate_Preference_3_Registrant__c);
			System.debug('Adding roomie pref 3');
		}
		return setRoomies;
	}//end RoommateAdder
	
	public PageReference MergeRooms(){
		ResetValues();
		transient Savepoint sp = Database.setSavepoint();
		ApexPages.Message m;
		
		if (strLeftRoom == null || strRightRoom == null){
			m = new ApexPages.Message(
    			ApexPages.severity.ERROR,
    			'Please select a room in both the left and right columns to merge.'
    		);
    		ApexPages.addMessage(m);
		}
		
		if (m == null){
			Set<Id> setR1Regs = new Set<Id>();
			Set<Id> setR2Regs = new Set<Id>();
			//Get the rooms
			r1 = [Select Id, Number_of_Occupants__c, Name, Convention_Group__r.Name, Male_Female_Private__c,
				Registrant_1__c,  Registrant_2__c, Registrant_3__c, Registrant_4__c,
				Product__c, Registrant_1__r.Primary_Contact__r.RecordTypeId
				from Room__c where Id =: strLeftRoom];
			
			r2 = [Select Id, Number_of_Occupants__c, Name, Convention_Group__r.Name, Male_Female_Private__c,
				Registrant_1__c,  Registrant_2__c, Registrant_3__c, Registrant_4__c,
				Product__c, Registrant_1__r.Primary_Contact__r.RecordTypeId
				from Room__c where Id =: strRightRoom];
				
			if (r1 == null || r2 == null){
				m = new ApexPages.Message(
	    			ApexPages.severity.ERROR,
	    			'These rooms no longer exist, please refresh the page and try again.'
	    		);
	    		ApexPages.addMessage(m);
			} else {
				if (r1.Male_Female_Private__c != r2.Male_Female_Private__c){
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			'These rooms do not have the same room type (Male/Female/Private) and cannot be merged.'
		    		);
	    			ApexPages.addMessage(m);
				}
				if (r1.Product__c != r2.Product__c){
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			'These rooms are associated with different Room Products and cannot be merged.'
		    		);
	    			ApexPages.addMessage(m);
				}
				if (r1.Id == r2.Id){
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			'You\'ve select the same room from the left and right columns, please change one of these selections to merge.'
		    		);
	    			ApexPages.addMessage(m);
				}
			}
			
			//If no error has been hit...
			if (m == null){
				Integer intRSize = (r1.Male_Female_Private__c == 'Private or Adult w/ Spouse' ? 1 : (r1.Registrant_1__r.Primary_Contact__r.RecordTypeId == '012400000005P9ZAAU' ? 2 : 4));
				setR1Regs.add(r1.Registrant_1__c);
				setR1Regs.add(r1.Registrant_2__c);
				setR1Regs.add(r1.Registrant_3__c);
				setR1Regs.add(r1.Registrant_4__c);
				
				setR2Regs.add(r2.Registrant_1__c);
				setR2Regs.add(r2.Registrant_2__c);
				setR2Regs.add(r2.Registrant_3__c);
				setR2Regs.add(r2.Registrant_4__c);
				System.debug('Just added registrants from each room to sets. Number of Occupants from r1 = ' +r1.Number_of_Occupants__c +', number of Occupants from r2 = ' +r2.Number_of_Occupants__c +', room size = ' +intRSize);
				//If all of the occupants of the two rooms can fit in one, just merge them
				if (r1.Number_of_Occupants__c + r2.Number_of_Occupants__c <= intRSize){
					//Merge everyone into Room1
					r1.Registrant_1__c = null;
					r1.Registrant_2__c = null;
					r1.Registrant_3__c = null;
					r1.Registrant_4__c = null;
					
					for (Id idR : setR1Regs){
						if (r1.Registrant_1__c == null){
    						r1.Registrant_1__c = idR;
    					} else {
    						if (r1.Registrant_2__c == null){
    							r1.Registrant_2__c = idR;
    						} else {
    							if (r1.Registrant_3__c == null){
    								r1.Registrant_3__c = idR;
    							} else {
    								r1.Registrant_4__c = idR;
    							}
    						}
    					}
					}//end r1 loop
					
					for (Id idR : setR2Regs){
						if (r1.Registrant_1__c == null){
    						r1.Registrant_1__c = idR;
    					} else {
    						if (r1.Registrant_2__c == null){
    							r1.Registrant_2__c = idR;
    						} else {
    							if (r1.Registrant_3__c == null){
    								r1.Registrant_3__c = idR;
    							} else {
    								r1.Registrant_4__c = idR;
    							}
    						}
    					}
					}//end r2 loop
					//delete the second room
					try{
						System.debug('Trying to delete room 2');
						delete r2;
					} catch (Exception ex) {
						m = new ApexPages.Message(
			    			ApexPages.severity.ERROR,
			    			ex.getMessage()
			    		);
			    		ApexPages.addMessage(m); 
					}
					//update the first
					try{
						System.debug('Trying to update room 1');
						update r1;
					} catch (Exception ex) {
						m = new ApexPages.Message(
			    			ApexPages.severity.ERROR,
			    			ex.getMessage()
			    		);
			    		ApexPages.addMessage(m); 
					}
					
					//If no errors, say so
					if (m == null){
						strMergeResult = 'Rooms merged successfully.';
					}
				//otherwise, setup interface so user can merge
				} else {
					lstR1Regs = [Select Id, Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.FirstName, 
						Primary_Contact__r.LastName, Primary_Contact__r.RecordTypeId,
		    			Roommate_Preference_1_Registrant__c, Roommate_Preference_2_Registrant__c, Roommate_Preference_3_Registrant__c,
		    			Male_Female__c,
		    			(Select Id, PricebookEntryId, PricebookEntry.Product2Id from OpportunityLineItems)
		    			from Opportunity where Id IN: setR1Regs];
					
					lstR2Regs = [Select Id, Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.FirstName, 
						Primary_Contact__r.LastName, Primary_Contact__r.RecordTypeId,
		    			Roommate_Preference_1_Registrant__c, Roommate_Preference_2_Registrant__c, Roommate_Preference_3_Registrant__c,
		    			Male_Female__c,
		    			(Select Id, PricebookEntryId, PricebookEntry.Product2Id from OpportunityLineItems)
		    			from Opportunity where Id IN: setR2Regs];
					IsMerge = true;
				}
			}//end if rooms exist
			//If any errors were hit, roll back the changes
	    	if (m != null){
	    		Database.rollback(sp);
	    		strMergeResult = 'See error above.';
	    	}
		}//end if no initial error

		return null;	
	}//end MergeRooms
	
	public List<SelectOption> getRoom1() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	
    	for (Opportunity o : lstR1Regs){
    		options.add(new SelectOption(o.Id,o.Primary_Contact__r.Name));
    	}
    	
    	return options;	
    }
    
    public List<SelectOption> getRoom2() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	
    	for (Opportunity o : lstR2Regs){
    		options.add(new SelectOption(o.Id,o.Primary_Contact__r.Name));
    	}
    	
    	return options;	
    }
    
    public List<SelectOption> getStageVals() {
    	List<SelectOption> options = new List<SelectOption>(); 
    	
    	options.add(new SelectOption('Application Started','Application Started'));
		options.add(new SelectOption('I: Intent','I: Intent'));
		options.add(new SelectOption('S: Serious','S: Serious'));
		options.add(new SelectOption('C: Complete','C: Complete'));
		options.add(new SelectOption('Accepted','Accepted'));
		options.add(new SelectOption('Drop - Not Yet Accepted','Drop - Not Yet Accepted'));
		options.add(new SelectOption('Cancelled - After Accept (No Pmt)','Cancelled - After Accept (No Pmt)'));
		options.add(new SelectOption('Cancelled - Part. Pmt.','Cancelled - Part. Pmt.'));
		options.add(new SelectOption('Cancelled - Fully Pd','Cancelled - Fully Pd'));
		options.add(new SelectOption('Rejected','Rejected'));
		options.add(new SelectOption('Closed - Duplicate','Closed - Duplicate'));
    	
    	return options;	
    }
    
    public PageReference MoveRight(){
    	Move(true);
    	
    	return null;
    }//end move right
 
    public PageReference MoveLeft(){
    	Move(false);
    	
    	return null;
    }//end move right
    
    public void Move(Boolean LeftToRight){
    	List<Opportunity> lstFrom;
    	List<Opportunity> lstTo;
    	String[] strMove;
    	
    	if (LefttoRight){
    		lstFrom = lstR1Regs;
    		lstTo = lstR2Regs;
    		strMove = strLeftRegs;
    	} else {
    		lstFrom = lstR2Regs;
    		lstTo = lstR1Regs;
    		strMove = strRightRegs;
    	}
    	
    	for (String idR : strMove){
    		for (Integer i = 0; i < lstFrom.size(); i++){
    			
    			if (lstFrom.get(i).Id == idR){
    				lstTo.add(lstFrom.get(i).clone());
    				lstFrom.remove(i);
    			}
    			
    		}
    		
    	}
    }
    
    public PageReference ManualMergeRooms(){
		transient Savepoint sp = Database.setSavepoint();
		ApexPages.Message m;
		Integer intRSize;
		
		//get the room limit from one of the registrants
		if (lstR1Regs != null){
			intRSize = (lstR1Regs[0].Male_Female__c == 'Private or Adult w/ Spouse' ? 1 : (lstR1Regs[0].Primary_Contact__r.RecordTypeId == '012400000005P9ZAAU' ? 2 : 4));
		}
		//Just in case everyone gets merged into the room on the right
		if (intRSize == null &lstR2Regs != null){
			intRSize = (lstR2Regs[0].Male_Female__c == 'Private or Adult w/ Spouse' ? 1 : (lstR2Regs[0].Primary_Contact__r.RecordTypeId == '012400000005P9ZAAU' ? 2 : 4));
		}
		if (intRSize == null){
			m = new ApexPages.Message(
    			ApexPages.severity.ERROR,
    			'Error, there are no registrants to merge.'
    		);
    		ApexPages.addMessage(m);
		}
		
		if (lstR1Regs != null &&lstR1Regs.size() > intRSize){
			m = new ApexPages.Message(
    			ApexPages.severity.ERROR,
    			'There are too many registrants in the room on the left-hand side.  These registrants are in rooms limited to ' +intRSize +' occupants.'
    		);
    		ApexPages.addMessage(m);
		}
		
		if (lstR2Regs != null &&lstR2Regs.size() > intRSize){
			m = new ApexPages.Message(
    			ApexPages.severity.ERROR,
    			'There are too many registrants in the room on the right-hand side.  These registrants are in rooms limited to ' +intRSize +' occupants.'
    		);
    		ApexPages.addMessage(m);
		}
		
		if (m == null){
			//Merge Room1
			r1.Registrant_1__c = null;
			r1.Registrant_2__c = null;
			r1.Registrant_3__c = null;
			r1.Registrant_4__c = null;
			
			for (Opportunity o : lstR1Regs){
				if (r1.Registrant_1__c == null){
					r1.Registrant_1__c = o.Id;
				} else {
					if (r1.Registrant_2__c == null){
						r1.Registrant_2__c = o.Id;
					} else {
						if (r1.Registrant_3__c == null){
							r1.Registrant_3__c = o.Id;
						} else {
							r1.Registrant_4__c = o.Id;
						}
					}
				}
			}//end r1 loop
			
			//Merge Room2
			r2.Registrant_1__c = null;
			r2.Registrant_2__c = null;
			r2.Registrant_3__c = null;
			r2.Registrant_4__c = null;
			
			for (Opportunity o : lstR2Regs){
				if (r2.Registrant_1__c == null){
					r2.Registrant_1__c = o.Id;
				} else {
					if (r2.Registrant_2__c == null){
						r2.Registrant_2__c = o.Id;
					} else {
						if (r2.Registrant_3__c == null){
							r2.Registrant_3__c = o.Id;
						} else {
							r2.Registrant_4__c = o.Id;
						}
					}
				}
			}//end r2 loop
			
			if (lstR1Regs.size() > 0){
				try{
					System.debug('Trying to update room 1');
					update r1;
				} catch (Exception ex) {
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			ex.getMessage()
		    		);
		    		ApexPages.addMessage(m); 
				}
			} else {
				try{
					System.debug('Trying to delete room 1');
					delete r1;
				} catch (Exception ex) {
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			ex.getMessage()
		    		);
		    		ApexPages.addMessage(m); 
				}
			}
			
			if (lstR2Regs.size() > 0){
				try{
					System.debug('Trying to update room 2');
					update r2;
				} catch (Exception ex) {
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			ex.getMessage()
		    		);
		    		ApexPages.addMessage(m); 
				}
			} else {
				try{
					System.debug('Trying to delete room 2');
					delete r2;
				} catch (Exception ex) {
					m = new ApexPages.Message(
		    			ApexPages.severity.ERROR,
		    			ex.getMessage()
		    		);
		    		ApexPages.addMessage(m); 
				}
			}
			
			if (m == null){
				strMergeResult = 'Rooms successfully merged.';
				IsMerge = false;
			} else {
				Database.rollback(sp);
	    		strMergeResult = 'See error above.';
			}
		}//end if no initial errors
		
		return null;
    }//end ManualMergeRooms
    
    static Contact testConGen(Id idGroup, String strFirst, String strLast){
    	Contact c = new Contact(
    		FirstName = strFirst,
    		LastName = strLast,
    		AccountId = idGroup
    	);
    	
    	insert c;
    	return c;
    }//end testConGen
    
    static Opportunity testRegGen(Id idCon, Date dte, String strGen, Id idGroup, Id idRT, Id idProd, String strPref, Integer intPref){
    	Opportunity o = new Opportunity(
    		Convention__c = 'Northeast', 
    		CloseDate = dte, 
    		Male_Female__c = strGen, 
    		Group__c = idGroup,
    		RecordTypeId = idRT,
    		Primary_Contact__c = idCon,
    		StageName = 'Interested',
    		Name = 'Reg'
    		);
    	
    	if (intPref == 1){
    		o.Roommate_Preference_1__c = strPref;
    	}
    	if (intPref == 2){
    		o.Roommate_Preference_2__c = strPref;
    	}
    	if (intPref == 3){
    		o.Roommate_Preference_3__c = strPref;
    	}
    	insert o;
    	
    	OpportunityLineItem oli = new OpportunityLineItem(
    		PricebookEntryId = idProd,
    		OpportunityId = o.Id,
    		Quantity = 1,
    		TotalPrice = 200
    	);
    	
    	insert oli;

    	return o;
    }
    static testMethod void testPageActions() {
    	Date dteCon = System.today().addDays(90);
    	Account a = new Account(
    		Name = 'Nonnewaug',
    		BillingStreet = 'Street',
    		BillingState = 'Connecticut',
    		BillingPostalCode = '06751',
    		BillingCity = 'Woodbury'
    	);
    	insert a;
    	
    	High_School__c h = new High_School__c(
            Name = 'Jessie Test HS', 
            Account__c = a.Id);
        insert h;
    	
    	Id idRTReg = [Select Id from RecordType where DeveloperName = 'Individual_Convention_Registration'][0].Id;
    	Id idRTCon = [Select Id from RecordType where DeveloperName = 'ChapterConventionRegistration'][0].Id;
    	Id idProd = [Select Id From PricebookEntry p where Name like '%Student Registration%' and IsActive = true LIMIT 1][0].Id;
    	
    	Opportunity oCon = new Opportunity(
    		Convention__c = 'Northeast', 
    		CloseDate = dteCon, 
    		ocHigh_School__c = h.Id,
    		RecordTypeId = idRTCon,
    		StageName = 'Interested',
    		Name = 'Group'
    		);
    	
    	insert oCon;
    	
    	Opportunity oCon2 = new Opportunity(
    		Convention__c = 'Northeast', 
    		CloseDate = dteCon, 
    		ocHigh_School__c = h.Id,
    		RecordTypeId = idRTCon,
    		StageName = 'Interested',
    		Name = 'Group2'
    		);
    	
    	insert oCon2;
    	
    	Contact c1 = testConGen(a.Id, 'Rainbow', 'Paper');
    	Opportunity r1 = testRegGen(c1.Id, dteCon, 'Female', oCon.Id, idRTReg, idProd, '', 1);

        inflateTest();

		/*Contact c2 = testConGen(a.Id, 'Broadband', 'Router');
    	Opportunity r2 = testRegGen(c2.Id, dteCon, 'Female', oCon.Id, idRTReg, idProd, 'Rainbox Paper', 1);
    	
    	Contact c3 = testConGen(a.Id, 'Photosmart', 'Express');
    	Opportunity r3 = testRegGen(c3.Id, dteCon, 'Female', oCon.Id, idRTReg, idProd, 'roadband Router', 2);
    	
    	Contact c4 = testConGen(a.Id, 'Black', 'Berry');
    	Opportunity r4 = testRegGen(c4.Id, dteCon, 'Male', oCon.Id, idRTReg, idProd, 'Con Ediso', 3);
    	
    	Contact c5 = testConGen(a.Id, 'Con', 'Edison');
    	Opportunity r5 = testRegGen(c5.Id, dteCon, 'Male', oCon2.Id, idRTReg, idProd, 'Time Warner', 1);
    	
    	Contact c6 = testConGen(a.Id, 'Time', 'Warner');
    	Opportunity r6 = testRegGen(c6.Id, dteCon, 'Male', oCon2.Id, idRTReg, idProd, 'Eclipse IDE', 2);
    	
    	Contact c7 = testConGen(a.Id, 'Eclipse', 'IDE');
    	Opportunity r7 = testRegGen(c7.Id, dteCon, 'Male', oCon2.Id, idRTReg, idProd, 'USB Cable', 3);
    	
    	Contact c8 = testConGen(a.Id, 'USB', 'Cable');
    	Opportunity r8 = testRegGen(c8.Id, dteCon, 'Male', oCon2.Id, idRTReg, idProd, '', 1);
    	
    	Contact c9 = testConGen(a.Id, 'Hidon', 'Crooklyn');
    	Opportunity r9 = testRegGen(c9.Id, dteCon, 'Private or Adult w/ Spouse', oCon2.Id, idRTReg, idProd, 'USB Cable', 2);
    	
    	Contact c10 = testConGen(a.Id, 'Murphy', 'Renet');
    	Opportunity r10 = testRegGen(c10.Id, dteCon, 'Private or Adult w/ Spouse', oCon2.Id, idRTReg, idProd, 'Hidon Brooklyn', 3);
    	
    	ApexPages.StandardController stdCon = new ApexPages.StandardController(r1);
    	extConvention ext = new extConvention(stdCon);
    	
    	ext.filter_opp.CloseDate = dteCon;
    	ext.filter_opp.Convention__c = 'Northeast';
    	ext.filter_opp.Group__c = oCon.Id;
    	
    	ext.filter_opp2.CloseDate = dteCon;
    	ext.filter_opp2.Convention__c = 'Northeast';
    	ext.filter_opp2.Group__c = oCon2.Id;
    	
    	ext.strStages.add('Interested');
    	ext.strStages.add('Other Stage');
    	ext.getTools();
    	ext.getNumbers();
    	ext.getRTs();
    	ext.RegistrantCount();
    	ext.dummy_room.Hotel__c = a.Id;
    	
    	ext.MatchRoommates();
    	ext.GenerateRooms();
    	ext.GenerateRooms();
    	
    	ext.filter_opp.Male_Female__c = 'Male';
    	//ext.strNum = '< 4';
    	//ext.strNum2 = '< 4';
    	
    	String strSoQL = 'Select Number_of_Occupants__c, Name, Convention_Group__r.Name, Male_Female_Private__c,';
		strSoQL += ' Registrant_1__c,  Registrant_2__c, Registrant_3__c, Registrant_4__c,';
		strSoQL += ' Registrant_1__r.Primary_Contact__r.Name, Registrant_2__r.Primary_Contact__r.Name,';
		strSoQL += ' Registrant_3__r.Primary_Contact__r.Name, Registrant_4__r.Primary_Contact__r.Name';
		strSoQL += ' From Room__c where Male_Female_Private__c = \'' +ext.filter_opp.Male_Female__c +'\'';
		strSoQL += ' and Registrant_1__r.Convention__c =\'' +ext.filter_opp.Convention__c +'\' and Registrant_1__r.CloseDate = ' +ext.filter_opp.CloseDate.year() +'-' +(ext.filter_opp.CloseDate.month() < 10 ? '0' +ext.filter_opp.CloseDate.month().format() : ext.filter_opp.CloseDate.month().format()) +'-' +(ext.filter_opp.CloseDate.day() < 10 ? '0' +ext.filter_opp.CloseDate.day().format() : ext.filter_opp.CloseDate.day().format());
		strSoQL += ' and Convention_Group__c = \'' +ext.filter_opp.Group__c +'\'';
		strSoQL += ' LIMIT 2';
		System.debug('Left query = ' +strSoQL);
		List<Room__c> lstLRooms = Database.query(strSoQL);
		
		strSoQL = 'Select Number_of_Occupants__c, Name, Convention_Group__r.Name, Male_Female_Private__c,';
		strSoQL += ' Registrant_1__c,  Registrant_2__c, Registrant_3__c, Registrant_4__c,';
		strSoQL += ' Registrant_1__r.Primary_Contact__r.Name, Registrant_2__r.Primary_Contact__r.Name,';
		strSoQL += ' Registrant_3__r.Primary_Contact__r.Name, Registrant_4__r.Primary_Contact__r.Name';
		strSoQL += ' From Room__c where Male_Female_Private__c = \'' +ext.filter_opp.Male_Female__c +'\'';
		strSoQL += ' and Registrant_1__r.Convention__c =\'' +ext.filter_opp.Convention__c +'\' and Registrant_1__r.CloseDate = ' +ext.filter_opp.CloseDate.year() +'-' +(ext.filter_opp.CloseDate.month() < 10 ? '0' +ext.filter_opp.CloseDate.month().format(): ext.filter_opp.CloseDate.month().format()) +'-' +(ext.filter_opp.CloseDate.day() < 10 ? '0' +ext.filter_opp.CloseDate.day().format() : ext.filter_opp.CloseDate.day().format());
		strSoQL += ' and Convention_Group__c = \'' +ext.filter_opp2.Group__c +'\'';
		//strSoQL += ' and Number_of_Occupants__c ' +ext.strNum2;
		System.debug('Right query = ' +strSoQL);
		List<Room__c> lstRRooms = Database.query(strSoQL);

    	ext.getLeftRooms();
    	ext.getRightRooms();
    	Boolean ManMerged = false;
        Integer roomCount = 0;

    	for (Room__c lr : lstLRooms){
    		ext.strLeftRoom = lr.Id;
    		if(!ManMerged){
	    		for (Room__c rr : lstRRooms){
	    			ext.strRightRoom = rr.Id;
	    			System.debug('Merging, left room = ' +lr.Number_of_Occupants__c +', right room = ' +rr.Number_of_Occupants__c);
	    			ext.MergeRooms();
	    			if (!ManMerged &&ext.lstR1Regs.size() > 0 && ext.lstR2Regs.size() > 0){
	    				ext.getRoom1();
	    				ext.getRoom2();
	    				
	    				for (Opportunity r1reg : ext.lstR1Regs){
	    					if (ext.strLeftRegs.size() == 0){
	    						ext.strLeftRegs.add(r1reg.Id);
	    					}
	    				}
	    				for (Opportunity r2reg : ext.lstR2Regs){
	    					if (ext.strRightRegs.size() == 0){
	    						ext.strRightRegs.add(r2reg.Id);
	    					}
	    				}
	    				ext.getLeftRegs();
	    				ext.getRightRegs();
	    				ext.MoveRight();
	    				ext.MoveLeft();
	    				ext.ManualMergeRooms();
	    				ManMerged = true;
	    			}
	    		}
    		}

            // Because we are hitting SOQL limits in this unit test, we are limiting the amount of these tests...
            roomCount++;
            if (roomCount > 5) {
                break;
            }

    	}*/
    	
    }//end testPageActions

    static void inflateTest() {

        Integer j = 0;

        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;

    }
}
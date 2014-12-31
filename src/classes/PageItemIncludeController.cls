//  Copyright (c) 2009, David Van Puyvelde, Sales Engineering, Salesforce.com Inc.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  Neither the name of the salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

public class PageItemIncludeController {

	public List<PageToItem__c> items {get;set;}
	private String pageid {get;set;}
	public List<Selectoption> blocknameselect {get;set;}
	public PageToItem__c p {get;set;}
	
	public PageItemIncludeController(Apexpages.Standardcontroller con) {
		p = new PageToItem__c(Page__c = System.currentPageReference().getParameters().get('pageid'));
		items = [Select p.Page__r.Name, p.Page__c, p.Order__c, p.Display_in_Contentblock__c, p.ContentBlockItem__r.Name, p.ContentBlockItem__c From PageToItem__c p order by p.Page__r.Name];
		
		//Find the right pagetemplate id via the page
		Page__c p = [Select p.PageTemplate__r.ContentBlockNames__c, p.PageTemplate__c From Page__c p where Id =:System.currentPageReference().getParameters().get('pageid')];

		String contentblocknames = p.PageTemplate__r.ContentBlockNames__c;
		
		List<String> splitnames = contentblocknames.split(',');
		blocknameselect = new List<Selectoption>();
		for(String s:splitnames) {
			Selectoption so = new Selectoption(s,s);
			blocknameselect.add(so);
		}
	}
	
	
	public PageReference selectItem() {
		String itemid = System.currentPageReference().getParameters().get('itemid');
		p.ContentBlockItem__c = itemid;
		
		try {
			insert p;
			return new PageReference('/'+p.Page__c);
		}
		catch(Exception ex) {
			Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.ERROR, ex.getMessage());
			Apexpages.addMessage(msg);
			return null;
		}
	}
	
	
	//TEST METHODS
	private static testMethod void t1() {
		//set up a test template
		PageTemplate__c template = new PageTemplate__c(Name='test', VisualForce_Page_Name__c='TestTemplate', ContentBlockNames__c ='main,header');
		insert template;
		//set up a test page
		Page__c pg = new Page__c(Name='testpage', PageTemplate__c = template.Id);
		insert pg;
		//set up a test ContentBlockItem
		ContentBlockItem__c cb = new ContentBlockItem__c(Name='test content', Content__c='some content');
		insert cb;		
		//set up an existing pagetoitem
		PageToItem__c pti = new PageToItem__c(Page__c = pg.Id, ContentBlockItem__c = cb.Id);
		insert pti;
		
		PageReference pr = Page.PageItemInclude;
		pr.getParameters().put('pageid', pg.Id);
		Test.setCurrentPageReference(pr);
		
		PageItemIncludeController piic = new PageItemIncludeController(new Apexpages.Standardcontroller(pti));
		
		pr.getParameters().put('itemid', cb.Id);
		piic.selectItem();
	}

}
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

public class PageItemEditExtension {

	public ContentBlockItem__c contentblock {get;set;}
	public PageToItem__c pagetoitem {get;set;}
	public List<SelectOption> blocknameselect {get;set;}
	
	//CONSTRUCTOR
	public PageItemEditExtension(Apexpages.Standardcontroller con) {
		this.pagetoitem = (PageToItem__c)con.getRecord();
	}
	
	//this method is called in the apex action attribute. It will redirect to the webformeditor if the content is a form instead of HTML
	public PageReference checkType() {
		String ptid = System.currentPageReference().getParameters().get('id');
		String contentblocknames;
		//new pagetoitem
		if(ptid == null ) {
			ID masterpage = pagetoitem.Page__c;
			//Find the right pagetemplate id and contentblock names via the page
			Page__c p = [Select p.PageTemplate__r.ContentBlockNames__c, p.PageTemplate__c From Page__c p where Id =:masterpage];
			contentblocknames = p.PageTemplate__r.ContentBlockNames__c;
			contentblock = new ContentBlockItem__c();
		}
		
		
		
		//existing pagetoitem edit
		if(ptid != null) {
			pagetoitem = [Select p.Page__r.PageTemplateVFPage__c, p.Page__r.PageTemplate__c, p.Page__r.Name, p.Page__r.Id, p.Order__c, 
							p.Page__c, p.Id, p.Display_in_Contentblock__c, p.ContentBlockItem__r.Content__c, 
							p.ContentBlockItem__r.LastActivityDate, p.ContentBlockItem__r.SystemModstamp, p.ContentBlockItem__r.LastModifiedById, 
							p.ContentBlockItem__r.LastModifiedDate, p.ContentBlockItem__r.CreatedById, p.ContentBlockItem__r.CreatedDate, 
							p.ContentBlockItem__r.Name, p.ContentBlockItem__r.Id, p.ContentBlockItem__r.Type__c, p.ContentBlockItem__r.Web_Form__c, p.ContentBlockItem__c,
							p.Page__r.PageTemplate__r.VisualForce_Page_Name__c,p.Page__r.PageTemplate__r.ContentBlockNames__c
							From PageToItem__c p where Id =: ptid];
			//set the correct contentblock
			contentblock = pagetoitem.ContentBlockItem__r;
			contentblocknames = pagetoitem.Page__r.PageTemplate__r.ContentBlockNames__c;
		}

		
		//set up the select options for the contentblock names where the user can choose to display the content
		if(contentblocknames != null) {
			List<String> splitnames = contentblocknames.split(',');
			blocknameselect = new List<Selectoption>();
			for(String s:splitnames) {
				Selectoption so = new Selectoption(s,s);
				blocknameselect.add(so);
			}
		}
		if(pagetoitem.ContentBlockItem__r.Type__c == 'WebForm') {
			return new PageReference('/apex/WebFormEditor?id='+pagetoitem.ContentBlockItem__r.Web_Form__c);
		}
		else {
			return null;
		}
	}
	
	public PageReference save() {
		upsert contentblock;
		if(pagetoitem.ContentBlockItem__c == null) pagetoitem.ContentBlockItem__c = contentblock.Id;
		upsert pagetoitem;
		return new PageReference('/'+pagetoitem.Page__c);
	}
	
	
	//TEST METHODS
	public static testMethod void t1() {
		//set up a test template
		PageTemplate__c template = new PageTemplate__c(Name='test', VisualForce_Page_Name__c='TestTemplate', ContentBlockNames__c ='main,header');
		insert template;
		//set up a test page
		Page__c pg = new Page__c(Name='testpage', PageTemplate__c = template.Id);
		insert pg;
		//set up a test ContentBlockItem
		ContentBlockItem__c cb = new ContentBlockItem__c(Name='test content', Content__c='some content');
		insert cb;
		
		//new pagetoitem & contentblock
		PageItemEditExtension pie = new PageItemEditExtension(new Apexpages.Standardcontroller(new PageToItem__c(Page__c = pg.Id)));
		System.assertEquals(pie.checkType(), null);
		pie.save();
		
		//edit existing pagetoitem
		PageToItem__c pti = new PageToItem__c(Page__c = pg.Id, ContentBlockItem__c = cb.Id);
		insert pti;
		
		PageReference pr = Page.PageItemEdit;
		pr.getParameters().put('id', pti.Id);
		Test.setCurrentPageReference(pr);
		
		PageItemEditExtension pie2 = new PageItemEditExtension(new Apexpages.Standardcontroller(pti));
		pie2.checkType();
		pie2.save();
	}

}
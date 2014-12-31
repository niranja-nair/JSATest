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

public class FormItemIncludeController {

	private String pageid {get;set;}
	public List<Selectoption> blocknameselect {get;set;}
	public PageToItem__c p {get;set;}
	public List<Web_Form__c> webforms {get;set;}

	public FormItemIncludeController() {
		if(System.currentPageReference().getParameters().get('pageid') == null) {
			 Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'No pageId parameter specified'));
			 return;
		}
		
		p = new PageToItem__c(Page__c = System.currentPageReference().getParameters().get('pageid'));
		webforms = [Select w.Owner.Name, w.OwnerId, w.Object_Label__c, w.Name, w.LastModifiedDate, w.Id, w.Description__c From Web_Form__c w];
		
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
		String formid = System.currentPageReference().getParameters().get('formid');
		//get a reference to the selected webform
		Web_Form__c wf;
		
		for(Web_Form__c w:webforms) {
			if(w.Id == formid) {
				wf = w;
				break;
			}
		}
		
		ContentBlockItem__c cbi = new ContentBlockItem__c();
		cbi.Name = wf.Name;
		cbi.Type__c = 'WebForm';
		cbi.Web_Form__c = formid; //save the form in the web form field. The contentblock component will pick it up an render the correct Form
		
		try {
			//insert contentblock
			insert cbi;
			//insert the pagetoitem
			p.ContentBlockItem__c = cbi.Id;
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
		//set up a web form and fields
		//Create a webform, fields and save it
		Web_Form__c form = new Web_Form__c();
		form.Name = 'Test';
		form.Object_Name__c = 'Test__c';
		form.Object_Label__c = 'Test';		
		form.Return_URL__c = 'http://www.salesforce.com';
		form.SavedByWebformeditor__c = true;
		insert form;
		
		//create test form fields for this web form
		Form_Field__c f1 = new Form_Field__c(Type__c = 'STRING', Name = 'Text__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f2 = new Form_Field__c(Type__c = 'EMAIL', Name = 'Email__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f3 = new Form_Field__c(Type__c = 'URL', Name = 'URL__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f4 = new Form_Field__c(Type__c = 'BOOLEAN', Name = 'Checkbox__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f5 = new Form_Field__c(Type__c = 'DATE', Name = 'Date__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f6 = new Form_Field__c(Type__c = 'DATETIME', Name = 'DateTime__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f7 = new Form_Field__c(Type__c = 'CURRENCY', Name = 'Currency__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f8 = new Form_Field__c(Type__c = 'DOUBLE', Name = 'Number__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f9 = new Form_Field__c(Type__c = 'PERCENT', Name = 'Percent__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f10 = new Form_Field__c(Type__c = 'TEXTAREA', Name = 'Text_Area__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f11 = new Form_Field__c(Type__c = 'PHONE', Name = 'Phone__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f12 = new Form_Field__c(Type__c = 'PICKLIST', Name = 'Picklist__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f13 = new Form_Field__c(Type__c = 'UNSUPPORTED', Name = 'Text__c', Web_Form__c = form.Id, Label__c = 'lbl');
		Form_Field__c f14 = new Form_Field__c(Type__c = 'CUSTOMTEXT', Name = 'CUSTOM Text1', Web_Form__c = form.Id, Label__c = '* CUSTOM Text *',  Width__c = 250);
		
		insert f1;
		insert f2;
		insert f3;
		insert f4;
		insert f5;
		insert f6;
		insert f7;
		insert f8;
		insert f9;
		insert f10;
		insert f11;
		insert f12;
		insert f13;
		insert f14;
		
		PageReference pr = Page.PageItemInclude;
		pr.getParameters().put('pageid', pg.Id);
		Test.setCurrentPageReference(pr);
		
		FormItemIncludeController piic = new FormItemIncludeController();
		
		pr.getParameters().put('formid', form.Id);
		piic.selectItem();
	}

}
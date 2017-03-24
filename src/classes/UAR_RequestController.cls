/** ---------------------------------------------------------------------------------------
* @Description <User Access Request Form><
* <Form for requesting user access to SF Apps.>
*
* @Author AECOM - Tom Smalara
* @Date January 2017 
*----------------------------------------------------------------------------------------*/
public with sharing class UAR_RequestController {
	public String selectedApplication{get;set;}
	public String sComboName {get; set;}
	public String[] lSelectedCombos {get; set;}
	public UAR_Request__c oRequest {get; set;}
	public List<UAR_Combinations__c> lCombinations {get; set;}

	public List<SelectOption> lApps {
		get
		{
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('', '--select--'));
			String oldVal = '';
			for(uar_Combinations__c o: lCombinations)	{
				if(oldVal <> o.Application__c){
					options.add(new SelectOption(o.Application__c, o.Application__c));
					oldVal = o.Application__c;
				}
			}
			options.sort();
			return options;
		}
		set;
	}

	public List<SelectOption> lComboName {
		get
		{
			List<SelectOption> options = new List<SelectOption>();
			//options.add(new SelectOption('', '--select--'));
			String oldVal = '';
			for(uar_Combinations__c o: lCombinations)	{	
				if(o.application__c == selectedApplication){			
					options.add(new SelectOption(o.Id, (o.Name + ' - ' + o.ComboDescription__c).abbreviate(175)));
				}
			}
			options.sort();
			return options;
		}
		set;
	}

	public String sComboDescription {
		get
		{
			for(uar_Combinations__c c: lCombinations)	{	
				if(c.Id == oRequest.Combination__c){			
					return c.ComboDescription__c;
				}
			}
			return null;
		}
		set;
	}

	public List<SelectOption> lActions {
		get
		{
			List<SelectOption> options = new List<SelectOption>();
			Schema.DescribeFieldResult fieldResult = UAR_Request__c.Action__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();			
			for(Schema.PicklistEntry o : ple)
				options.add(new SelectOption(o.getLabel(), o.getValue()));
			return options;			
		}
	}
	
	public PageReference clearFormFields(){
        //oRequest = new UAR_Request__c();
        oRequest.Combination__c = null;
        return null;
    }



	public UAR_RequestController(ApexPages.StandardController oStandardController) {
		this.oRequest = (UAR_Request__c)oStandardController.getRecord();
		//SET DEFAULT ACTION TO GRANT
		oRequest.Action__c = 'Grant';
		//Get Combination Data
		lCombinations = [select id, application__c, name, combodescription__c, status__c, sortorder__c from uar_Combinations__c order by name asc];
		System.debug('lSelectedCombos::::' + lSelectedCombos);
	}

	public PageReference  saveRecord(){
		List<UAR_Request__c> lRequestToUpdate = new List<UAR_Request__c>();

		for(UAR_Combinations__c combo : [select Id, Name, ApproverPrimary__c, ApproverSecondary__c, ApproverThird__c from UAR_Combinations__c where id IN:lSelectedCombos]){
		//for(UAR_Combinations__c combo : [select Id, Name from UAR_Combinations__c where id IN:lSelectedCombos]){	
			UAR_Request__c r = new UAR_Request__c();
			r.ApproverPrimary__c = combo.ApproverPrimary__c;
			r.ApproverSecondary__c = combo.ApproverSecondary__c;
			r.ApproverThird__c = combo.ApproverThird__c;
			r.Application__c = selectedApplication;
			r.Name = combo.Name;
			r.Combination__c = combo.Id;
			r.Action__c = oRequest.Action__c;
			r.Justification__c = oRequest.Justification__c;
			r.RequestedFor__c = oRequest.RequestedFor__c;
			System.debug(LoggingLevel.DEBUG, 'r::::'+r.Combination__c);
			lRequestToUpdate.add(r);
		}
		System.debug(LoggingLevel.DEBUG,'lSelectedCombos::::'+lSelectedCombos);

		try {   
			insert lRequestToUpdate;
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to save the request. Please contact your administrator with the following error: ' + e));
           
		}

		PageReference confPage = new PageReference('/apex/UAR_RequestConfirmation');
        confPage.setRedirect(true);
        return confPage;
	}

	
}
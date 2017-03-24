public with sharing class UAR_PrivilegeAssociationController {
	public String combinationId {get; set;}
	public String combinationName {get; set;}
	public UAR_Associated_Privileges__c oAssocPrivilege {get; set;}
	public UAR_Privileges__c oPrivilege {get; set;}
	public String selectedPrivilegeType {get; set;}
	public String selectedPrivilegeId {get;set;}	

	public Map<Id, String> mPrivileges = new Map<Id, String>();
	
	public List<SelectOption> lPrivilegeTypes
	{
		get
		{
			List<SelectOption> options = new List<SelectOption>();
        
		   	Schema.DescribeFieldResult fieldResult = UAR_Privileges__c.PrivilegeType__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			options.add(new SelectOption('','--Select--'));
			for( Schema.PicklistEntry f : ple)
			{
			  options.add(new SelectOption(f.getLabel(), f.getValue()));
			}       
			return options;
		}
	}

	public List<SelectOption> lGeographies
	{
		get
		{
			List<Geography__c> lGeographyTemp = [SELECT Id, Name FROM Geography__c order by Name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(Geography__c o : lGeographyTemp)
				options.add(new SelectOption(o.id, o.Name));
			return options;
		}
	}

	public List<SelectOption> lPrivileges
	{
		get
		{
			List<UAR_Privileges__c> lPrivilegeTemp = [SELECT Id, PrivilegeType__c, Name FROM UAR_Privileges__c order by PrivilegeType__c, Name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--Create New Privilege--'));
			for(UAR_Privileges__c o : lPrivilegeTemp)
				options.add(new SelectOption(o.id, o.PrivilegeType__c + '/' + o.Name));
			return options;

		}
	}

	public List<SelectOption> lGroups
	{
		get
		{
			List<Group> lGroupTemp = [SELECT Id,Name FROM Group where type='regular' order by name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(Group o : lGroupTemp){
				options.add(new SelectOption(o.id, o.Name));
				mPrivileges.put(o.id, o.Name);
			}
			return options;

		}
	}

	public List<SelectOption> lQueues
	{
		get
		{
			List<Group> lQueueTemp = [SELECT Id,Name FROM Group where type='queue' order by name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(Group o : lQueueTemp){
				options.add(new SelectOption(o.id, o.Name));
				mPrivileges.put(o.id, o.Name);
			}
			return options;

		}
	}

	public List<SelectOption> lLicenses
	{
		get
		{
			List<UserLicense> lLicenseTemp = [SELECT Id,Name FROM UserLicense order by name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(UserLicense o : lLicenseTemp){
				options.add(new SelectOption(o.id, o.Name));
				mPrivileges.put(o.id, o.Name);
			}
			return options;

		}
	}

	public List<SelectOption> lPermissionSets
	{
		get
		{
			List<PermissionSet> lPermissionSetTemp = [SELECT Id,Label FROM PermissionSet where (NOT name like 'X%') order by name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(PermissionSet o : lPermissionSetTemp){
				options.add(new SelectOption(o.id, o.Label));
				mPrivileges.put(o.id, o.Label);
			}
			return options;

		}
	}

	public List<SelectOption> lProfiles
	{
		get
		{
			List<Profile> lProfileTemp = [SELECT Id,Name FROM Profile order by name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(Profile o : lProfileTemp){
				options.add(new SelectOption(o.id, o.Name));
				mPrivileges.put(o.id, o.Name);
			}
			return options;

		}
	}

	public List<SelectOption> lRoles
	{
		get
		{
			List<UserRole> lRoleTemp = [SELECT Id,Name FROM UserRole order by name];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(UserRole o : lRoleTemp){
				options.add(new SelectOption(o.id, o.Name));
				mPrivileges.put(o.id, o.Name);
			}
			return options;

		}
	}

		public List<SelectOption> lPackageLicenses
	{
		get
		{
			List<PackageLicense> lPackageLicenseTemp = [SELECT Id,NamespacePrefix FROM PackageLicense WHERE UsedLicenses > 0 order by NamespacePrefix];
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('','--select--'));
			for(PackageLicense o : lPackageLicenseTemp){
				options.add(new SelectOption(o.id, o.NamespacePrefix));
				mPrivileges.put(o.id, o.NamespacePrefix);
			}
			return options;

		}
	}

	public UAR_PrivilegeAssociationController(ApexPages.StandardController controller) {
		this.oAssocPrivilege = (UAR_Associated_Privileges__c)controller.getRecord();
		System.debug(LoggingLevel.ERROR,'this.oAssocPrivilege::::' + oAssocPrivilege);

		combinationId = oAssocPrivilege.Combination__c;
		List<UAR_Combinations__c> c = [select Name from UAR_Combinations__c where id= :combinationId limit 1];
		combinationName = c[0].Name;

		oPrivilege = new UAR_Privileges__c();

	}


	public PageReference  saveRecord(){
		System.debug(LoggingLevel.Error,'selectedPrivilegeId::::' + selectedPrivilegeId);
		if(selectedPrivilegeId==null){
			System.debug('save() entered!');
			oPrivilege.PrivilegeType__c = selectedPrivilegeType;	
			if(mPrivileges.get(oPrivilege.PrivilegeTypeId__c) <> null){
					oPrivilege.Name = oPrivilege.PrivilegeType__c + ': ' + mPrivileges.get(oPrivilege.PrivilegeTypeId__c);
				}else{
					oPrivilege.Name = oPrivilege.PrivilegeType__c + ': ' + oPrivilege.Description__c;
				}
			
			System.debug(LoggingLevel.ERROR,'oPrivilege::::' + oPrivilege);	
			try {   
				upsert oPrivilege;
				selectedPrivilegeId = oPrivilege.Id;
				System.debug('returned privilege id::::' + selectedPrivilegeId);
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to save the request. Please contact your administrator with the following error: ' + e));
			}
		}
		UAR_Associated_Privileges__c oAssociatedPrivilege = new UAR_Associated_Privileges__c();
		oAssociatedPrivilege.Combination__c = combinationId;
		oAssociatedPrivilege.Privilege__c = selectedPrivilegeId;
		try{
			upsert oAssociatedPrivilege;
		}
		catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to save the request. Please contact your administrator with the following error: ' + e));
			}
		PageReference detailPage = new PageReference('/' + combinationId);
        detailPage.setRedirect(true);
        return detailPage;
	}

	public PageReference clearFormFields(){
        oPrivilege.PrivilegeTypeId__c = null;
        return null;
    }

    public PageReference updateForm(){
    	//String privilegeId = oPrivilege.Id;
    	System.debug(LoggingLevel.ERROR, 'selectedPrivilegeId::::' + selectedPrivilegeId);

	    oPrivilege = new UAR_Privileges__c();
    	if(String.isNotEmpty(selectedPrivilegeId)){
	        oPrivilege = [select id, name, PrivilegeType__c, PrivilegeTypeId__c, Description__c, GrantInstructions__c, RevokeInstructions__c  
	        				from UAR_Privileges__c where Id= :selectedPrivilegeId];
	        System.debug(LoggingLevel.ERROR, 'privilegeTypeId::::' + oPrivilege.PrivilegeTypeId__c);
	    	
	        selectedPrivilegeType = oPrivilege.PrivilegeType__c;
	        //selectedPrivilegeTypeId = oPrivilege.PrivilegeTypeId__c;
	        System.debug(LoggingLevel.ERROR, 'oPrivilege::::' + oPrivilege);
    	}

        return null;
    }
}
@isTest
private class UAR_PrivilegeController_Test {
	
	@isTest static void test_method_one() {
		User testuser = ECO_Utils_Testing.createTestUser('System Administrator');

		Test.startTest();

		System.runAs(testuser){

			PermissionSet ps = [select id from PermissionSet where (NOT Name like 'X%') limit 1];
			UAR_Privileges__c p = new UAR_Privileges__c(PrivilegeTypeId__c=ps.Id, PrivilegeType__c='Permission Set', Description__c='testdata');
			//insert p;

	       	System.debug('p::::' + p);


			PageReference pg = page.UAR_Privilege;
	       	Test.setCurrentPage(pg);

	       	//Standard Controller
			ApexPages.StandardController sc = new ApexPages.StandardController(p);
			//Controller Extension
			UAR_PrivilegeController pc = new UAR_PrivilegeController(sc);

			List<SelectOption> lGroupTest = pc.lGroups;
			List<SelectOption> lQueueTest = pc.lQueues;
			List<SelectOption> lPermissionSetsTest = pc.lPermissionSets;
			List<SelectOption> lLicensesTest = pc.lLicenses;
			List<SelectOption> lProfilesTest = pc.lProfiles;
			List<SelectOption> lRolesTest = pc.lRoles;
			List<SelectOption> lPackageLicensesTest = pc.lPackageLicenses;
			List<SelectOption> lPrivilegeTypesTest = pc.lPrivilegeTypes;
			List<SelectOption> lGeographiesTest = pc.lGeographies;

	        pc.saveRecord();	

	        UAR_Privileges__c testresult = [select Description__c from UAR_Privileges__c where id=:p.Id limit 1]; 

	        System.assertEquals('testdata', testresult.Description__c);		

		}

		Test.stopTest();
		
	}
	
	
}
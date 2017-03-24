@isTest(seeAllData=false)
private class UAR_PrivilegeAssociationController_Test {
	
	@isTest static void test_method_one() {
		
		User testuser = ECO_Utils_Testing.createTestUser('System Administrator');

		System.runAs(testuser){

			List<User> lUser = new List<User>();
			User runninguser = ECO_Utils_Testing.createTestUser('System Administrator');
			lUser.add(runninguser);
			User user1 = ECO_Utils_Testing.createTestUser('Standard User');
			lUser.add(user1);
			User user2 = ECO_Utils_Testing.createTestUser('Standard User');
			lUser.add(user2);
			User user3 = ECO_Utils_Testing.createTestUser('Standard User');
			lUser.add(user3);
			User requestedfor = ECO_Utils_Testing.createTestUser('Standard User');
			lUser.add(requestedfor);
			insert lUser;

			UAR_Combinations__c c = new UAR_Combinations__c();
			c.Name='Combo1';
			c.ApproverPrimary__c = user1.Id;
			c.ApproverSecondary__c = user2.Id;
			c.ApproverThird__c = user3.Id;
			c.Application__c = 'test application';
			c.Requires_Approval__c = false;
			insert c;

			PermissionSet ps = [select id, Label from PermissionSet where (NOT Name like 'X%') limit 1];
			UAR_Privileges__c p = new UAR_Privileges__c(PrivilegeTypeId__c=ps.Id, PrivilegeType__c='Permission Set', Description__c='testdata');
			insert p;

	       	UAR_Associated_Privileges__c a = new UAR_Associated_Privileges__c();
	       	a.Combination__c = c.Id;
	       	a.Privilege__c = p.Id;

	       	Test.startTest();

			PageReference pg = page.UAR_PrivilegeAssociation;
	       	Test.setCurrentPage(pg);

	       	//Standard Controller
			ApexPages.StandardController sc = new ApexPages.StandardController(a);
			//Controller Extension
			UAR_PrivilegeAssociationController pc = new UAR_PrivilegeAssociationController(sc);

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

			//UAR_Associated_Privileges__c ap = [select Privilege__c, Combination__c, Description__c from UAR_Associated_Privileges__c 
			//									where Privilege__c=:p.Id and Combination__c=:c.Id limit 1];

			//System.assertEquals(p.Description__c, ap.Description__c);

			Test.stopTest();

		}
	
	}
}


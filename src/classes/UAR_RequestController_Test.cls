@isTest(SeeAllData=false)

private class UAR_RequestController_Test {
	
	@isTest static void test_method_one() {
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

		UAR_Combinations__c combo1 = new UAR_Combinations__c();
		combo1.Name='Combo1';
		combo1.ApproverPrimary__c = user1.Id;
		combo1.ApproverSecondary__c = user2.Id;
		combo1.ApproverThird__c = user3.Id;
		combo1.Application__c = 'test application';
		combo1.Requires_Approval__c = false;

		insert combo1;

		String[] lSelectedCombosTest = new String[]{combo1.Id};

		List<UAR_Privileges__c> lPrivileges = new List<UAR_Privileges__c>();
		
		PermissionSet p1 = [select id from PermissionSet where (NOT Name like 'X%') limit 1];
		lPrivileges.add(new UAR_Privileges__c(PrivilegeTypeId__c=p1.Id, PrivilegeType__c='Permission Set', Description__c='testdata'));
		
		Group p2 = [select id from Group where type='regular' limit 1];
		lPrivileges.add(new UAR_Privileges__c(PrivilegeTypeId__c=p2.Id, PrivilegeType__c='Group', Description__c='testdata'));
		
		Group p3 = [select id from Group where type='Queue' limit 1];
		lPrivileges.add(new UAR_Privileges__c(PrivilegeTypeId__c=p3.Id, PrivilegeType__c='Queue', Description__c='testdata'));
		
		Profile p4 = [select id from Profile limit 1];
		lPrivileges.add(new UAR_Privileges__c(PrivilegeTypeId__c=p4.Id, PrivilegeType__c='Profile', Description__c='testdata'));
		
		UserPackageLicense p5 = [select id from UserPackageLicense limit 1];
		lPrivileges.add(new UAR_Privileges__c(PrivilegeTypeId__c=p5.Id, PrivilegeType__c='Installed Package License', Description__c='testdata'));
		
		insert lPrivileges;

		List<UAR_Associated_Privileges__c> lAssoc = new List<UAR_Associated_Privileges__c>();
		UAR_Associated_Privileges__c assoc;

		List<UAR_Privileges__c> temp = [select id, name from UAR_Privileges__c where Description__c='testdata'];
		
		for(UAR_Privileges__c p : [select id from UAR_Privileges__c]){
			assoc = new UAR_Associated_Privileges__c();
			assoc.Combination__c = combo1.Id;
			assoc.Privilege__c = p.Id;		
			lAssoc.add(assoc);
		}
		insert lAssoc;


		List<UAR_Request__c> lRequests = new List<UAR_Request__c>();

		UAR_Request__c r1 = new UAR_Request__c();
		r1.Application__c = 'test application';
		r1.Name = 'test combo1';
		r1.Combination__c = combo1.Id;
		r1.Justification__c = 'test justification1';
		r1.RequestedFor__c = requestedfor.Id;
		r1.Action__c = 'Grant';
		r1.Status__c = 'Approved';
		lRequests.add(r1);

		UAR_Request__c r2 = new UAR_Request__c();
		r2.Application__c = 'test application';
		r2.Name = 'test combo2';
		r2.Combination__c = combo1.Id;
		r2.Action__c = 'Revoke';
		r2.Justification__c = 'test justification2';
		r2.RequestedFor__c = requestedfor.Id;
		r2.Status__c = 'Approved';
		lRequests.add(r2);

		insert lRequests;


		Test.startTest();

		System.runAs(runninguser){
				            
	        PageReference pg = page.UAR_Request;
	       	Test.setCurrentPage(pg);

	       	//TEST FOR GRANT ACTION
	   		ApexPages.StandardController sc1 = new ApexPages.StandardController(r1);
	   		UAR_RequestController rc1 = new UAR_RequestController(sc1);
	   		List<SelectOption> lApps = rc1.lApps;
	   		List<SelectOption> lActions = rc1.lActions;
	   		List<SelectOption> lComboName = rc1.lComboName;
	   		String sComboDescription = 'Combo Description;';
	   		
	   		rc1.lSelectedCombos = lSelectedCombosTest;
	        rc1.saveRecord();
	        sc1.save();

	        //TEST FOR REVOKE ACTION
	        ApexPages.StandardController sc2 = new ApexPages.StandardController(r2);
	        UAR_RequestController rc2 = new UAR_RequestController(sc2);
	        rc2.lSelectedCombos = lSelectedCombosTest;
	        rc2.saveRecord();
	        sc2.save();

	        System.assertEquals('Approved', r1.Status__c);
	        System.assertEquals('Approved', r2.Status__c);
		}
		
        
        Test.stopTest();

	}
	
	
}
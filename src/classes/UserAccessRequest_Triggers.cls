public without sharing class UserAccessRequest_Triggers {
	public static boolean bProfile = false;
	public static boolean bPermissionSet = false;

	public static UAR_Request__c oRequest;
	public static UAR_Combinations__c oCombination;

	public static List<UAR_Privileges__c> lPrivileges;
	public static Set<Id> permissionSetSet;
	public static List<GroupMember> lGroupMember;
	public static Set<Id> groupMemberSet;
	public static List<UserPackageLicense> lUserPackageLicense;
	public static Set<Id> userPackageLicenseSet;

	public static String sStatus='Completed';
	public static String sErrors;
	public static String sRequestId;

	@future
	public static void updateUserAccessRequest(Set<Id> Ids){

		oRequest = [select Id, Name, Action__c, Application__c, Justification__c, 
									RequestedFor__c, Status__c, Combination__c, RequestedByEmail__c, Errors__c 
									from UAR_Request__c where Id IN :Ids limit 1];

		

		System.assertNotEquals(oRequest.Status__c, 'Pending');
		System.debug(LoggingLevel.DEBUG, 'Record is Pending...');

		sRequestId = oRequest.Id;		


		List<UAR_Associated_Privileges__c> lPrivilegesTemp = [select privilege__c from UAR_Associated_Privileges__c where Combination__c= :oRequest.Combination__c]; //oCombination.Id];
		
		Set<Id> pIdSet = new Set<Id>();
		for(UAR_Associated_Privileges__c p : lPrivilegesTemp){
			pIdSet.add(p.Privilege__c);
		}

		lPrivileges = [select Id, PrivilegeType__c, PrivilegeTypeId__c from UAR_Privileges__c where Id IN :pIdSet];

		System.debug(LoggingLevel.DEBUG,'lPrivileges::::' + lPrivileges);

		permissionSetSet = new Set<Id>();
		groupMemberSet = new Set<Id>();
		userPackageLicenseSet = new Set<Id>();

		lGroupMember = new List<GroupMember>();		
		lUserPackageLicense = new List<UserPackageLicense>();

	
		List<PermissionSetAssignment> lPermissionSetAssignment = new List<PermissionSetAssignment>();

		//GET REQUESTEDFOR USER OBJECT
		User oUser = [select id, profileid from user where id= :oRequest.RequestedFor__c];

		For(UAR_Privileges__c p : lPrivileges){
			System.debug(LoggingLevel.DEBUG,'PrivilegeType::::' + p.PrivilegeType__c);
			if(p.PrivilegeType__c=='Profile'){	
				oUser.ProfileId = p.PrivilegeTypeId__c;
				bProfile = true;
			}
			if(p.PrivilegeType__c=='Permission Set'){
				PermissionSetAssignment oPermissionSetAssignment = new PermissionSetAssignment();
				oPermissionSetAssignment.AssigneeId = oRequest.RequestedFor__c;
				oPermissionSetAssignment.PermissionSetId = p.PrivilegeTypeId__c;
				lPermissionSetAssignment.add(oPermissionSetAssignment);
				permissionSetSet.add(p.PrivilegeTypeId__c);
			}
			if(p.PrivilegeType__c=='Group' || p.PrivilegeType__c=='Queue'){					
				GroupMember oGroupMember = new GroupMember();
				oGroupMember.GroupId = p.PrivilegeTypeId__c;
				oGroupMember.UserOrGroupId = oUser.Id;
				lGroupMember.add(oGroupMember);
				groupMemberSet.add(p.PrivilegeTypeId__c);
				System.debug(LoggingLevel.DEBUG,'lGroupMember::::' + lGroupMember);
			}
			if(p.PrivilegeType__c=='Installed Package License'){
				UserPackageLicense oUserPackageLicense = new UserPackageLicense();
				oUserPackageLicense.UserId = oUser.Id;
				oUserPackageLicense.PackageLicenseId = p.PrivilegeTypeId__c;
				lUserPackageLicense.add(oUserPackageLicense);
				userPackageLicenseSet.add(p.PrivilegeTypeId__c);
			}
			
		}
		//Check to see which privilege type should be updated
		if(lUserPackageLicense.size() > 0){
			if(oRequest.Action__c=='Grant'){
				try{
					Upsert lUserPackageLicense;
				}
				catch(Exception ex){
					System.debug(LoggingLevel.ERROR, 'ERROR::::' + ex);
					sErrors = String.valueOf(ex);
					sStatus = 'Failed';
				}
			}
			if(oRequest.Action__c=='Revoke'){
				try{	
					lUserPackageLicense = [select id from UserPackageLicense where UserId =: oUser.Id and PackageLicenseId IN :userPackageLicenseSet];
					Delete lUserPackageLicense;
				}
				catch(Exception ex){
					sErrors = String.valueOf(ex);
					sStatus = 'Failed';
				}
			}
		}

		if(bProfile){
			if(oRequest.Action__c=='Grant'){
				try{
					Update oUser;
				}
				catch (Exception ex){
					System.debug(LoggingLevel.ERROR, 'ERROR::::' + ex);
					sErrors = String.valueOf(ex);
					sStatus = 'Failed';
				}					
			}
		}
		if(lPermissionSetAssignment.size() > 0){
			if(oRequest.Action__c=='Grant'){
				try{
					Upsert lPermissionSetAssignment;					
				}
				catch(Exception ex){
					System.debug(LoggingLevel.ERROR, 'ERROR::::' + ex);
					sErrors = String.valueOf(ex);
					sStatus = 'Failed';
				}
			}
			if(oRequest.Action__c=='Revoke'){
				try{
					lPermissionSetAssignment = [select Id from PermissionSetAssignment where PermissionSetId IN :permissionSetSet and AssigneeId= :oUser.Id];
					Delete lPermissionSetAssignment;
				}
				catch(Exception ex){
					System.debug(LoggingLevel.ERROR, 'ERROR::::' + ex);
					sErrors = String.valueOf(ex);
					sStatus = 'Failed';
				}
			}
		}
		If(lGroupMember.size() > 0){
			if(oRequest.Action__c=='Grant'){
				try{
					System.debug(LoggingLevel.DEBUG,'Upsert::::' + lGroupMember);
					Upsert lGroupMember;
				}
				catch(Exception ex){
					System.debug(LoggingLevel.ERROR, 'ERROR::::' + ex);
					sErrors = String.valueOf(ex);
					sStatus = 'Failed';				
				}
			}
			if(oRequest.Action__c=='Revoke'){
				try{
					List<GroupMember> g = new List<GroupMember>();
					g = [select Id from GroupMember where GroupId IN :groupMemberSet and UserOrGroupId= :oUser.Id];
					Delete g;
				}
				catch(Exception ex){
					System.debug(LoggingLevel.ERROR, 'ERROR::::' + ex);
					sErrors = String.valueOf(ex);
					sStatus = 'Failed';
				}
			}			
		}	
	}

	
	public static void completeRequest(Set<Id> Ids){		
		System.debug(LoggingLevel.DEBUG, 'Status::::' + sStatus);
		oRequest = [select Id, Name, Action__c, Application__c, Justification__c, 
									RequestedFor__c, Status__c, Combination__c, RequestedByEmail__c, Errors__c 
									from UAR_Request__c where Id IN :Ids limit 1];
		System.debug(LoggingLevel.DEBUG, 'oRequest::::' + oRequest);

		List<UAR_Associated_Privileges__c> lPrivilegesTemp = [select Privilege__c, Privilege__r.PrivilegeType__c from UAR_Associated_Privileges__c where Combination__c= :oRequest.Combination__c];
	
		System.debug(LoggingLevel.DEBUG, 'oRequest.Status__c::::' + oRequest.Status__c);
		
		if(oRequest.Status__c == 'Approved'){
			oRequest.Status__c = 'Completed';	
			for(UAR_Associated_Privileges__c p : lPrivilegesTemp){
				System.debug(LoggingLevel.DEBUG, p.Privilege__r.PrivilegeType__c);
				if(p.Privilege__r.PrivilegeType__c == 'License' || p.Privilege__r.PrivilegeType__c == 'Delegated Admin' || p.Privilege__r.PrivilegeType__c == 'User Attribute')
					oRequest.Status__c = 'Pending Manual Changes';
			}

			try{				
				System.debug('oRequest::::Final::::' + oRequest);	
				Update oRequest;
			}
			catch(Exception ex){
				System.debug(LoggingLevel.DEBUG, 'DEBUG::::' + ex);
			}
		}
	}	

}
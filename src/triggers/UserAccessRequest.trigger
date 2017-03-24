/******************************************************************************************************************************
Created By :    Tom Smalara
Date       :    22 FEB 2016
Reason     :    
*******************************************************************************************************************************/
trigger UserAccessRequest on UAR_Request__c (before update, after update, after insert) {
	if(trigger.isAfter && trigger.isInsert){
			Set<ID> ids = Trigger.newMap.keySet();
			UserAccessRequest_Triggers.shareRequest(ids); 
	}
	if (trigger.isBefore && trigger.isUpdate) { 
		if(!system.isFuture()){	
			Set<ID> ids = Trigger.newMap.keySet();
			UserAccessRequest_Triggers.updateUserAccessRequest(ids); 
		}
	}
	if(trigger.isAfter && trigger.isUpdate){
			Set<ID> ids = Trigger.newMap.keySet();
			UserAccessRequest_Triggers.completeRequest(ids); 
	}
}
/************************************************************************************************************
* Apex Class Name   : WebformWebserviceProcessing.cls
* Version           : 1.0 
* Created Date      : 25 October 2018
* Function          : Webform Registration for Keep Me Informed, Book a test drive, Contact Us,
*                     Register My Interested(RMI) and Dealer Leads(Contact a Dealer)
* Modification Log  :
* -----------------------------------------------------------------------------------------------------------
* Developer         |       Date      |                   Description
* -----------------------------------------------------------------------------------------------------------
* Satyavani Boddu          25/10/2018                      Created 
************************************************************************************************************/
public with sharing class WebformWebserviceProcessing
{
	//Static Variables
    private static final APIIntegrationCodes.ErrorCode ERROR_CODES = new APIIntegrationCodes.ErrorCode();
    private static final APIIntegrationCodes.SuccesCode SUCCESS_CODES = new APIIntegrationCodes.SuccesCode(); 
    private static final SPException.Severity MODERATE_SEVERITY = SPException.Severity.MODERATE;  
    private static final SPException.Severity CRITICAL_SEVERITY = SPException.Severity.CRITICAL;
        
    // ************************************************************************************
    // *** Methods:
    //Execute the Weform Registrations 
    public static GuestVehicleWebserviceCalls.GuestWebFormWSResponse guestWebservices(GuestVehicleWebserviceCalls.GuestWebFormWSRequest request){
    	
    	System.debug('############# Entry : WebformWebserviceProcessing.guestWebservices ' + request);
    
        // ************************************************************************************
        // *** Variables:
        GuestVehicleWebserviceCalls.GuestWebFormWSResponse response = new GuestVehicleWebserviceCalls.GuestWebFormWSResponse(); 
        Map<String, map<String,String>> campaignMap = new Map<String, map<String,String>>();
        Account GuestAccount = new Account();
        Contact ContactObj;          
        map<String,Campaign> campObjMap = new map<String,Campaign>();
        List<Id> campaignIds = new List<Id>();        								
		List<Campaign> lstNewCampaign = new List<Campaign>();
		List<Task> lstNewTask = new List<Task>();
		List<CampaignMember> lstNewCampMem = new List<CampaignMember>();
		List<CampaignMember> lstExtCampMem = new List<CampaignMember>();
		
		if(String.IsBlank(request.webFormType))
		{
			response.responseMessage    =  'Invalid web form Type'; 
	        return response;
		}
		
		system.debug('request.campaignDetailswrapper.campaignDetailList ' + request.campaignDetailswrapper.campaignDetailList);
		
    	for(GuestVehicleWebserviceCalls.campaignDetail cmpDtl : request.campaignDetailswrapper.campaignDetailList)
        {	
        	if(!campaignMap.containsKey(cmpDtl.campaignCode))
        	{
        		campaignMap.put(cmpDtl.campaignCode, new map<String, String>());
        		campaignMap.get(cmpDtl.campaignCode).put('Name', cmpDtl.campaignName);
        	}
       	} 
       	 	 
	    String Phone  = String.IsNotblank(request.guestDetails.phone) ? request.guestDetails.phone : String.IsNotblank(request.guestDetails.personmobilephone) ? request.guestDetails.personmobilephone : Null;
		
		system.debug('campaignMap is ' + campaignMap);
			 	   	
		if(request.webFormType == 'CNCT001')
		{
			if(!GuestVehicleUtility.validateWebformDetails(request))
	        {
	            response.responseMessage    =  GuestVehicleUtility.errorStr; 
	            return response;
	        }	        
		}
		else
		{
			if(!GuestVehicleUtility.validateWebformDetails(request, true))
	        {
	            response.responseMessage    =  GuestVehicleUtility.errorStr; 
	            return response;
	        }	
		}
				      
		//Lets find the Guest in the Salesforce database
    	GuestAccount = GuestVehicleUtility.guestMatchingRule(Null, request.guestDetails.email, Null, Phone, Null, request.guestDetails.firstName, request.guestDetails.lastName);
    	GuestAccount = guestDetailsProcessing(request, GuestAccount); 
    	    	             
        //Cleanup the Old Account Match Records
        DateTime cleanupStartTime = system.now().addDays(-1 * SPCacheRecordTypeMetadata.getMatchHistoryCleanupPeriod());                                                                                                
        list<Account_Match__c> oldAccountMatches = [SELECT Id FROM Account_Match__c WHERE CreatedDate <= :cleanupStartTime];
        	if (!oldAccountMatches.isEmpty())
            delete oldAccountMatches;
                    
        try{
            if(GuestVehicleUtility.foundAccObj)
            {
                update GuestAccount;
                response.responseMessage += SUCCESS_CODES.GUEST_RECORD_UPDATED;
                Account_Match__c accMatch = new Account_Match__c(   Matched_Customer__c = true,
                                                                    Email_Input__c = request.guestDetails.email,
                                                                    Phone_Input__c = request.guestDetails.phone,
                                                                    First_Name_Input__c = request.guestDetails.firstName,
                                                                    Last_Name_Input__c = request.guestDetails.lastName,
                                                                    Matched_Record_Id__c = GuestAccount.Id,
                                                                    Email__c = GuestAccount.PersonEmail,
                                                                    First_Name__c = GuestAccount.FirstName,
                                                                    Last_Name__c = GuestAccount.LastName,
                                                                    Phone__c = GuestAccount.Phone );
                 insert  accMatch;                                                                                    
            }
            else
            {
                system.debug('GuestAccount is ' + GuestAccount);
                insert GuestAccount;
                response.responseMessage += SUCCESS_CODES.GUEST_RECORD_CREATED;
                /*Account_Match__c accMatch = new Account_Match__c( Matched_Customer__c = false,
                                                                Email_Input__c = request.guestDetails.email,
                                                                Phone_Input__c = request.guestDetails.phone,
                                                                First_Name_Input__c = request.guestDetails.firstName,
                                                                Last_Name_Input__c = request.guestDetails.lastName); 
                                                                
            	insert  accMatch;*/
            }
        }
        catch (exception e)
        {
            response.Succeed        = false;
            response.ResponseMEssage   = 'Error retrieving / creating the Account: ' + e.getMessage();
            system.debug('Stack Trace String ' + e.getStackTraceString() );
            system.debug('Line Number ' + e.getLineNumber() );
            return response;
        }
        
        // Link the Person Account to the Campaign by finding the Contact Id
        try {
                system.debug('Inside Contact');
                ContactObj = [   SELECT  id
                                FROM    Contact
                                WHERE   AccountId = :GuestAccount.Id
                             ];
         }
        catch (exception e) {
                system.debug('Contact Exception');
                response.Succeed        = false;
                response.ResponseMEssage   = 'Error retrieving the Contact record: ' + e.getMessage();
                return response;
         } 
                
        // Conatct US does not contain any campaign information
        if(request.webFormType != 'CNCT001')
        {	               
	        system.debug('webFormType is not equal to CNCT001');
	        // checking the campaign exits in Salesforce and prepares the map campObjMap
			for( Campaign campObj :  [ SELECT  id,Name,External_ID__c 
										FROM   Campaign 
										WHERE  External_ID__c IN :campaignMap.keySet()])
			{	
		    	campObjMap.put(campobj.External_ID__c,campobj);
		    	if(campaignMap.containskey(campObj.External_ID__c))
		    	{
		    		campaignMap.get(campObj.External_ID__c).put('Id', campObj.Id);
		    		campaignIds.add(campObj.Id);
		    	}
			}		
			system.debug('campObjMap is' + campObjMap);
						
			for(String campCode : campaignMap.keySet())
			{
				if(!campaignMap.get(campCode).containskey('Id'))
				{
					lstNewCampaign.add(new Campaign(External_ID__c = campCode, Name=campaignMap.get(campCode).get('Name')));					
				}
			}			
			
			// Create the new compaigns in Salesforce
			if(!lstNewCampaign.isEmpty())
			{
			  try
			  {
				insert lstNewCampaign;
				system.debug('lstNewCampaign is' + lstNewCampaign);
				system.debug('SPCacheRecordTypeMetadata.getIEIntegrationUserId() is ' + SPCacheRecordTypeMetadata.getIEIntegrationUserId());
				for(Campaign campObj : lstNewCampaign)
				{
					// Raise a Task to notify TMCA of new Campaign	                
	                lstNewTask.add(new Task(OwnerId = SPCacheRecordTypeMetadata.getIEIntegrationUserId(),WhatId = campobj.Id,
	                						Subject   = 'New Campaign created by IE New Webforms webservice',
	                						Description = 'Name:' + campobj.Name + ' Form Code: ' + campobj.External_ID__c));	
	                
	                //Update Map with ID for new campaigns
	                campaignMap.get(campObj.External_ID__c).put('Id', campObj.Id);
	                campaignIds.add(campObj.Id);                                                        							
				}
				system.debug('lstNewTask is' + lstNewTask);
				insert lstNewTask;
			  }
			  catch	(exception e) 
			  {
	                system.debug('Camapaign Exception');
	                response.Succeed        = false;
	                response.ResponseMEssage   = 'Error creating the Campaign or Task' + e.getMessage();
	                return response;
	          } 
			}
						
			// Already Campaign Member exists - update with latest response date         
	       	for(CampaignMember campMemObj :  [ SELECT  id, Last_Response_Date__c, Campaign.External_Id__c
	                                          FROM    CampaignMember
	                                          WHERE   CampaignId IN :campaignIds
	                                          AND     ContactId =: ContactObj.Id])
	         {
	         	campaignMap.get(campMemObj.Campaign.External_Id__c).put('CampMember', campMemObj.Id);
	         }
			
			// Create or Update the Campaign Membership record
			CampaignMember campMembObj;
			for(String campCode : campaignMap.keySet())
			{				
				if(campaignMap.get(campCode).containskey('CampMember'))
				{
					campMembObj= New CampaignMember(id = campaignMap.get(campCode).get('CampMember'));
					campMembObj.Last_Response_Date__c = system.today();
					lstExtCampMem.add(campMembObj);
				}
				else
				{
					campMembObj= New CampaignMember();
					campMembObj.CampaignId              = campaignMap.get(campCode).get('Id');
	                campMembObj.ContactId               = ContactObj.Id;
	                campMembObj.Status                  = 'Responded';
	                campMembObj.Last_Response_Date__c   = system.today();
	                if(request.webFormType == 'Sponsorships_Events' && request.LeadDetails != Null && request.LeadDetails.carSelectionOne != Null)
					{
					 campMembObj.Model_of_Interest__c   = request.LeadDetails.carSelectionOne;
					}
	                lstNewCampMem.add(campMembObj); 
				}				
			}
			  
			system.debug('lstExtCampMem is' + lstExtCampMem);   
			system.debug('lstNewCampMem is' + lstNewCampMem); 
			
			try
			{          
	        	// Update the existing compaign members in Salesforce
				if(!lstExtCampMem.isEmpty())
	         		update lstExtCampMem;
			 	// Insert the existing compaign members in Salesforce
				if(!lstNewCampMem.isEmpty())
					insert lstNewCampMem;
			}
			catch	(exception e) 
			{
	             system.debug('Camapaign Members Exception');
	             response.Succeed        	= false;
	             response.ResponseMEssage   = 'Error creating the Camapaign Members: ' + e.getMessage();
	             return response;
	        } 
			system.debug('sDealerAccount account is' + GuestVehicleUtility.sDealerAccount);
			Opportunity sOpportunity = new Opportunity();
			Map<String,Schema.RecordTypeInfo> recordTypeInfo;
			recordTypeInfo = Cache.getRecordTypeByName('Opportunity');
			// Is this a Test Drive (2) or Dealer Enquiry (103)? 
	        if(GuestVehicleUtility.sDealerAccount != null) 
	        {
               sOpportunity.Dealer__c = GuestVehicleUtility.sDealerAccount.Id;
               if(GuestVehicleUtility.sDealerAccount.Opportunity_Record_Type_ID__c != null && GuestVehicleUtility.sDealerAccount.Opportunity_Record_Type_ID__c instanceOf Id) 
               {
                      sOpportunity.RecordTypeId =  GuestVehicleUtility.sDealerAccount.Opportunity_Record_Type_ID__c.trim();
               }
               else 
               {
                      sOpportunity.RecordTypeId = recordTypeInfo.get('Prospect').getRecordTypeId();
                      // SPCacheRecordTypeMetadata.getOpportunityProspectRecordTypeId();
               }
	           //Buid the model code / Model name map from custom settings
	           map<string, string> map_ModelCodetoModelName = SP_WebtoLeadMetadata.getVehicleModelMap();
	           system.debug('*** map_ModelCodetoModelName = ' + map_ModelCodetoModelName);
	                
	          	sOpportunity.Name                               = request.guestDetails.FirstName + ' ' + request.guestDetails.LastName;
	            sOpportunity.AccountId                          = GuestAccount.Id;
	            //sOpportunity.CampaignId                         = campaignId; // TO BE DEFINE!!!
	            sOpportunity.StageName                          = 'Prospecting';
	            sOpportunity.Amount                             = 0;
	            if (map_ModelCodetoModelName.containsKey(request.leadDetails.CarSelectionOne)) {
	                  sOpportunity.Car_Selection_One__c           = map_ModelCodetoModelName.get(request.leadDetails.CarSelectionOne);
	                  System.debug('*** Car_Selection_One =' + sOpportunity.Car_Selection_One__c);
	            }
	            else{
	                    sOpportunity.Car_Selection_One__c           = request.leadDetails.CarSelectionOne;
	            }
	        
	            if (map_ModelCodetoModelName.containsKey(request.leadDetails.CarSelectionTwo)) {
	                 sOpportunity.Car_Selection_Two__c           = map_ModelCodetoModelName.get(request.leadDetails.CarSelectionTwo);
	            }
	            else {
	                 sOpportunity.Car_Selection_Two__c           = request.leadDetails.CarSelectionTwo;
	            }
	        
	            if (map_ModelCodetoModelName.containsKey(request.leadDetails.CarSelectionThree)) {
	                    sOpportunity.Car_Selection_Three__c         = map_ModelCodetoModelName.get(request.leadDetails.CarSelectionThree);
	            }
	            else {
	                    sOpportunity.Car_Selection_Three__c         = request.leadDetails.CarSelectionThree;
	            }
	            
	            //sOpportunity.Buying_In_Future__c                = args.BuyingInFuture;
	            //sOpportunity.Dealer_Address__c                  = args.DealerAddress;
	            sOpportunity.Dealer_Branch_Id__c                = request.dealerDetails.locationCode;
	            sOpportunity.Dealer_Code__c                     = request.dealerDetails.DealerCode;
	            //sOpportunity.Dealer_Email__c                    = args.DealerEmail;               
	            sOpportunity.Dealer_Name__c                     = request.dealerDetails.Name;
	            sOpportunity.Dealer_Postcode__c                 = request.dealerDetails.AddressDetails.postcode;
	            sOpportunity.Dealer_State__c                    = request.dealerDetails.AddressDetails.state;
	            sOpportunity.Dealer_Suburb__c                   = request.dealerDetails.AddressDetails.cityorsuburb;
				sOpportunity.Enquiry_Type__c                    = request.leaddetails.EnquiryType;
	           //sOpportunity.Form_Sub_Category__c               = args.FormSubCategory;
	            if (request.leadDetails.IntendedPurchaseDate != null && request.leadDetails.IntendedPurchaseDate.contains('0-3')) {  
                    system.debug('Purchase_Intention_Date__c 3 month');
                    sOpportunity.Purchase_Intention_Date__c = system.TODAY().addMonths(3);
                    
                } 
                if (request.leadDetails.IntendedPurchaseDate != null && request.leadDetails.IntendedPurchaseDate.contains('3-6')) {  
                    sOpportunity.Purchase_Intention_Date__c = system.TODAY().addMonths(6);
                    
                } 
                if (request.leadDetails.IntendedPurchaseDate != null && request.leadDetails.IntendedPurchaseDate.contains('6-12')) {  
                    sOpportunity.Purchase_Intention_Date__c = system.TODAY().addMonths(12);
                }    
                if (request.leadDetails.IntendedPurchaseDate != null) {          
                    sOpportunity.Months_Until_Intended_Purchase__c  = sOpportunity.Purchase_Intention_Date__c;
                    
                }
                if( sOpportunity.Purchase_Intention_Date__c != null) {
                    sOpportunity.CloseDate = sOpportunity.Purchase_Intention_Date__c;   
                }
                else {
                    sOpportunity.CloseDate = system.today().addMonths(12);
                }
	           
	           try 
	           {
					insert sOpportunity;					
					//Create Contact Role
					OpportunityContactRole oppContObj = new OpportunityContactRole();
					oppContObj.OpportunityId = sOpportunity.Id;
		            oppContObj.ContactId = ContactObj.Id;
		            oppContObj.IsPrimary = true;
		            oppContObj.Role = 'Decision Maker';
		            insert oppContObj;
	           }
	           catch (exception e) 
	           {
	              response.Succeed            = false;
	              response.ResponseMEssage   = 'Error creating the Opportunity: ' + e.getMessage();
	              return response;
	           }
	        }     
	        		
			
		}
		else
		{
 			system.debug('Enter into Contact US form');
 			// Create case
 			Map<String,Schema.RecordTypeInfo> recordTypeInfo;
			recordTypeInfo = Cache.getRecordTypeByName('Case');
            Case caseVar = new Case();
            caseVar.RecordTypeId = recordTypeInfo.get('CEC Cases').getRecordTypeId();
            caseVar.Origin = 'Website';
            caseVar.AccountId = GuestAccount.Id;
            caseVar.ContactId = contactObj.Id;
            
            map<string, string> map_ModelCodetoModelName = SP_WebtoLeadMetadata.getVehicleModelMap();

            caseVar.Enquiry_Type__c = request.leadDetails.EnquiryType;            
            caseVar.Type = 'Inquiry';
            caseVar.Model_Year__c = String.valueOf(request.leadDetails.ownedModelYear);                       
            caseVar.Model_Name_Code__c = request.leadDetails.ownedModel;

            // trigger assignment rule for creation in cases
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.useDefaultRule= true;
			dmlOpts.EmailHeader.TriggerUserEmail = true;
            caseVar.setOptions(dmlOpts);		
            
            system.debug('dmlOpts are' + dmlOpts);	
            
            // query Vehicle Ownerships
            List<Vehicle_Ownership__c> customerVO = [ SELECT ID,Name,Vehicle__c,Customer__c FROM Vehicle_Ownership__c WHERE Name =: request.leadDetails.ownedRegNo AND Status__c = 'Active' ];
            
           system.debug('customerVO ' + customerVO);
            // creating tasks
           List<Task> taskList = new List<Task>();
            
            if( customerVO.size() > 0 )
            {
                caseVar.Vehicle_Ownership__c = customerVO[0].Id;                  
                caseVar.Vehicle__c = customerVO[0].Vehicle__c;
                
                system.debug('caseVar.Vehicle_Ownership__r.Vehicle__c in if ' + customerVO[0].Vehicle__c);
                
                // check if customer has Valid Vehicle Ownership related to entered Rego
                Boolean customerVOFlag = false;
                               
                for( Vehicle_Ownership__c custVar : customerVO )
                {
                    if( custVar.Customer__c == GuestAccount.Id )
                    { 
                        customerVOFlag = true;
                    }
                }
                if( customerVOFlag ==  true ){
                    // possible Account details change
                    Task sTask1 = returnAccountDetailTask(request.guestdetails.phone);
                    taskList.add(sTask1);
                    system.debug('sTask1 ' + sTask1);
                }
                else{
                    
                    Task sTask1 = returnAccountDetailTask(request.guestdetails.phone);
                    taskList.add(sTask1);
                    
                    Task sTask2 = returnVOChangeTask(request.leadDetails.ownedRegNo,String.valueOf(request.leadDetails.ownedModelYear),request.leadDetails.ownedModel);
                    taskList.add(sTask2);
                    
                    system.debug('taskList ' + taskList);
                }
            }
            else if (request.leadDetails.ownedRegNo == null )
            {
                system.debug(' Registration number is null ');
                Task sTask1 = returnAccountDetailTask(request.guestdetails.phone);
                taskList.add(sTask1);                
            }   
            else
            {
                Task sTask1 = returnAccountDetailTask(request.guestdetails.phone);
                taskList.add(sTask1);
                
                    
                Task sTask2     = returnVOChangeTask(request.leadDetails.ownedRegNo,String.valueOf(request.leadDetails.ownedModelYear),request.leadDetails.ownedModel);
                taskList.add(sTask2);
                system.debug('taskList ' + taskList);
            }
            try{
                // insert Case
                insert caseVar;
               /* caseVar = [ SELECT Vehicle_Ownership__c,Vehicle_Ownership__r.Vehicle__c FROM Case WHERE id=: caseVar.ID];
                system.debug('caseVar.Vehicle_Ownership__c '+ caseVar.Vehicle_Ownership__r.Vehicle__c);  
                caseVar.Vehicle__c = caseVar.Vehicle_Ownership__r.Vehicle__c;
                
                update caseVar; */
                system.debug('caseVar ' + caseVar);
                system.debug('taskList ' + taskList );
                if( taskList.size() > 0)
                {
                    for(Task taskVar :  taskList)
                    {
                        taskVar.WhatId = caseVar.Id;
                        taskVar.OwnerId  = SPCacheRecordTypeMetadata.getIEIntegrationUserId();
                        taskVar.WhoId  = contactObj.Id;
                        taskVar.Status = 'Not Started';
                        taskVar.Priority = 'Normal';                        
                    }
                   insert taskList;
                } 
                
               response.Succeed            = true;
               response.ResponseMessage   = 'Case Created successfully.';
            }
            catch(Exception e)
            {
                response.Succeed            = false;
                response.ResponseMessage   = e.getMessage() + ' Case creation failed.';  
            } 
              
            return response;    
        }     	
    	return response;
    }     
    
    // ************************************************************************************
    // Method:guestDetailsProcessing - Prepare the Data for Insert or Update of Guest
    public static Account guestDetailsProcessing(GuestVehicleWebserviceCalls.GuestWebFormWSRequest request, Account accObj)
    {
        Account newGuest = new Account();
        if(accObj !=NULL)
        {   
            newGuest = new Account(id = accObj.Id);
        }    
        else       
        { 
        Map<String,Schema.RecordTypeInfo> recordTypeInfo;
		recordTypeInfo = Cache.getRecordTypeByName('Account');
        newGuest.RecordTypeId                   = recordTypeInfo.get('Prospect').getRecordTypeId();
        newGuest.PersonEmail                    = request.guestDetails.email;
        }
                
        //Update Guest details
        newGuest.FirstName                         = request.guestDetails.firstName;
        newGuest.LastName                          = request.guestDetails.lastName;        
        newGuest.Personmobilephone                 = String.IsNotblank(request.guestDetails.Personmobilephone) && String.valueof(request.guestDetails.Personmobilephone).startsWith('04') ? request.guestDetails.personmobilephone : accObj !=NULL ?accObj.personmobilephone : Null;
        newGuest.Phone                             = String.IsNotblank(request.guestDetails.phone) && String.valueof(request.guestDetails.phone).startsWith('04') ? request.guestDetails.phone : accObj !=NULL ?accObj.Phone : Null;                                                     
        
        //Update Marketing Details
        if (request.leadDetails != NULL)
        { 
           if(request.leadDetails.ownToyota != NULL)
           newGuest.Own_A_Toyota__c            = request.leadDetails.ownToyota;
           newGuest.Owned_Toyota_Model__c      = request.leadDetails.ownedModel;
           newGuest.Owned_Toyota_Year__c       = request.leadDetails.ownedModelYear;
        }                    
        return newGuest;
    }
    
    private static Task returnAccountDetailTask( String phone ){
        Task sTask    = new Task();
        sTask.Subject = 'Possible account details change';
        sTask.Description = 'Account details have changed as follows:' + '\n' + 'phone: ' +  phone;
        return sTask;
    }
    
    private static Task returnVOChangeTask( String regNumber, String year, String model){
        Task sTask     = new Task();
        sTask.Subject = 'Possible Ownership Change';
        sTask.Description = 'Values entered by user:' + '\n' + 'Registration: ' +  regNumber + '\n' + 'Year: ' + year + '\n' + 'Model: ' + model;   
        return sTask;
    }
}
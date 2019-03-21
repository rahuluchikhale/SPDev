/************************************************************************************************************
* Apex Class Name   : GuestRegVehicleWebserviceCalls.cls
* Version           : 1.0 
* Created Date      : 7 August 2018
* Function          : Webservice Calls from external channels. Guest Registration and Vehicle Management
* Modification Log  :
* -----------------------------------------------------------------------------------------------------------
* Developer         |       Date      |                     Description
* -----------------------------------------------------------------------------------------------------------
* Satyavani Boddu        07/08/2018                           Created 
* Satyavani Boddu        07/11/2018                           ValidateWebformDetails added
************************************************************************************************************/
global virtual with sharing class GuestVehicleWebserviceCalls 
{

 	// Guest Request Structure from IE - Satyavani Boddu        07/11/2018
    global virtual class GuestWebFormWSRequest 
    {
        webservice Guest                 	guestDetails			{ get; set; }
        webservice GuestPreferences      	guestPreferences		{ get; set; }
        webservice Dealer			     	dealerDetails			{ get; set; }
        webservice LeadDetails	    	 	leadDetails         	{ get; set; }
        webservice CampaignWrapper  	    campaignDetailsWrapper   { get; set; }
        webservice String				 	webFormType         	{ get; set; }

        global GuestWebFormWSRequest()
        {
            guestDetails 			= new Guest();
            guestPreferences 		= new GuestPreferences();
            dealerDetails 			= new Dealer();
            leadDetails 			= new LeadDetails();
            campaignDetailsWrapper  = new CampaignWrapper();
        }
    }
        
	// Guest Request Structure from ESB - MyToyota
    global virtual class GuestWSRequest {
        
        webservice String               salesforceId             	{ get; set; }
        webservice String               myToyotaId               	{ get; set; }
        webservice Guest                guestDetails             	{ get; set; }
        webservice Vehicle              vehicleDetails           	{ get; set; }
        webservice Boolean              CMUserFlag               	{ get; set; }
        webservice GuestPreferences     guestPreferences         	{ get; set; }
        webservice String			    guestType         			{ get; set; }

        global GuestWSRequest()
        {
            vehicleDetails = new Vehicle();
            guestDetails = new Guest();
            guestPreferences = new GuestPreferences();
        }

    }

    // Guest Details Structure
    global virtual class Guest 
    {
        
        webservice String       salutation                  { get; set; }
        webservice String       firstName                   { get; set; }
        webservice String       lastName                    { get; set; }
        webservice String       email                       { get; set; }
        webservice String       dob                         { get; set; }
        webservice String       phone                       { get; set; }
        webservice String       personmobilephone           { get; set; }
        webservice string       password                    { get; set; }
        webservice Datetime     lastLoginTime               { get; set; } 
        webservice Address      billingAddressDetails       { get; set; } 
        webservice Address      shippingAddressDetails      { get; set; }
        webservice string       ownersPortalUserId          { get; set; }

        global Guest()
        {
            billingAddressDetails = new Address();
            shippingAddressDetails = new Address();
        }
    }
    
    global virtual class Dealer 
    {
        
        webservice String	Name			{ get; set; }
        webservice String   DealerCode      { get; set; } //DealerID
        webservice String   locationCode    { get; set; } //BranchId
        webservice Address  AddressDetails  { get; set; }

        global Dealer()
        {
            AddressDetails = new Address();
        }
    }
    
    
     // Address Structure
    global virtual class Address {
        
        webservice String               street                      { get; set; } 
        webservice String               cityorsuburb                { get; set; }
        webservice String               postcode                    { get; set; } 
        webservice String               state                       { get; set; }
        webservice String               country                     { get; set; }
    } 

    // Vehicle details Structure
    global virtual class Vehicle {
    
        webservice String               vin                   		{ get; set; }
        webservice String               regoNo    		            { get; set; }
        webservice String               regoState           		{ get; set; }
        webservice String               batchNumber           		{ get; set; }  
       	webservice Date                 rdrDate               		{ get; set; } 
       	webservice TrackMyCar           trackMyCar      	  		{ get; set; }

        global Vehicle()
        {
            trackMyCar = new TrackMyCar();
        }
        
    }

    // Guest Preferences Structure
    global virtual class GuestPreferences {
    
        webservice Boolean              marketingPreference      	{ get; set; }
        webservice Boolean              pnpOptIn            	  	{ get; set; }
        webservice Boolean              emailOptInTMC       		{ get; set; }
        webservice Boolean              smsOptInTMC         		{ get; set; }
        webservice String               goPlacesPreference  		{ get; set; }
        
    }

    // Track My Car Structure
    global virtual class TrackMyCar {
    
        webservice String               statusDescription           { get; set; }
        webservice String               cosi                        { get; set; }
        webservice String               batchId                     { get; set; }
        
    } 
    
    // campaignDetails List Structure
    global virtual class CampaignWrapper
	{
		webservice list<campaignDetail>	 campaignDetailList		{get; set;}
		
		global CampaignWrapper()
        {
            campaignDetailList     = new list<campaignDetail>();
        }
	}
    
    // Campaign Structure
    global virtual class campaignDetail {
    
        webservice String               campaignCode           		{ get; set; }
        webservice String               campaignName                { get; set; }
        
        global campaignDetail()
        {
            campaignCode = '';
			campaignName = '';
        }
        
    } 
            
    // Marketing Details Structure
    global virtual class LeadDetails {
        
        webservice string   intendedPurchaseDate        {get; set;} // for opportunity
        webservice string   carSelectionOne             {get; set;} // for opportunity
        webservice string   carSelectionTwo             {get; set;} // for opportunity
        webservice string   carSelectionThree           {get; set;} // for opportunity
        
        webservice string   ownedModel            		{get; set;}
        webservice integer  ownedModelYear             	{get; set;}
        webservice boolean  ownToyota                   {get; set;}
        webservice string   enquiryType                 {get; set;} // Define a case and opportunity -  Webform Type (i.e. Contact Us, RMI)
        //Why??
        webservice string   ownedRegNo					{get; set;} // for Task and opportunity
        
    }     


    //Response Structure for Guest Vehicle Details Management
    global virtual class GuestWSResponse {
        
        webservice String                   resultStatus                { get; set; }
        webservice String                   responseMessage             { get; set; }
        webservice String                   salesforceId                { get; set; } // salesforce record Id 
        webservice String                   myToyotaId                  { get; set; } // myToyota Id
        webservice Guest                    guestDetails                { get; set; } 
        webservice GuestPreferences         guestPreferences            { get; set; }
        webservice String                   cmUserId                    { get; set; } // Is cmUserId required ?      
        webservice Boolean                  isActiveCMuser              { get; set; } // required ?
        webservice Boolean                  isVehicleCMEquipped         { get; set; } // required ?
       // webservice VehicleOwnershipList     vehicleOwnerships           { get; set; }
        

        global GuestWSResponse() {
            
            responseMessage            = '000';
            
        }
    }
    
    //Response Structure for Webform Processing 
    global class GuestWebFormWSResponse {
    	
        webservice boolean  Succeed                     {get; set;}
        webservice string   ResponseMessage             {get; set;}
    }
    
    /*----------------------------------------------------------------------------------------------------------------------------------------
        Method      :   registerGuest
        Input       :   GuestWSRequest
        Output      :   GuestWSResponse
        Description :   Guest Registation process
    ----------------------------------------------------------------------------------------------------------------------------------------*/
    webservice static GuestWSResponse registerGuest(GuestWSRequest request){
            
        System.debug('############# Entry : GuestRegVehicleWebserviceCalls.registerGuest with Request = '+request);
            
        GuestWSResponse response = new GuestWSResponse();
            
        try{
				response =  GuestVehicleDetailsMgmt.registerGuest(request);
        }    
        catch(SPException ex) {
            
                System.debug(logginglevel.error, ' ***  Exception Class ***' +  ex.getTypeName() + '\n' );
                System.debug(logginglevel.error, ' ***  Line Number ***' +  ex.getLineNumber() + '\n' );
                System.debug(logginglevel.error, ' ***  Cause of Exception  ***' +  ex.getMessage()  + '\n' );    
                System.debug(logginglevel.error, ' ***  Severity Level ***' + ex.getSeverity()  + '\n' );
                response.resultStatus             = 'ERROR';
                response.responseMessage       =  ex.getMessage(); 
                throw ex;                       
        }                
        system.debug('############# Exit : GuestRegVehicleWebserviceCalls.registerGuest with Response = ' + response);
       
        return response;                
    } 


     /*----------------------------------------------------------------------------------------------------------------------------------------
        Method      :   addAVehicle
        Input       :   GuestWSRequest
        Output      :   GuestWSResponse
        Description :   Add Vehicle and Vehicle Relationship for Driver in Salesforce
    ----------------------------------------------------------------------------------------------------------------------------------------*/
     
     webservice static GuestWSResponse addGuestVehicle(GuestWSRequest request)  {
     
        system.debug('############# Entry: GuestRegVehicleWebserviceCalls.addGuestVehicle with Request = ' + request);
        
        GuestWSResponse response = new GuestWSResponse();
        
        try {
            response = GuestVehicleDetailsMgmt.addGuestVehicle(request);
           
        }
        catch(SPException ex) {
            System.debug(' ***  Exception Class ***' +  ex.getTypeName() + '\n' );
            System.debug(' ***  Line Number ***' +  ex.getLineNumber() + '\n' );
            System.debug(' ***  Cause of Exception  ***' +  ex.getMessage()  + '\n' );    
            System.debug(' ***  Severity Level ***' + ex.getSeverity()  + '\n' );
            response.resultStatus             = 'ERROR';
            response.responseMessage       = ex.getMessage(); 
            throw ex;                      
        }
                
        system.debug('############# Exit: GuestRegVehicleWebserviceCalls.addGuestVehicle with Response = ' + response);
        
        return response;
    } 

    /*----------------------------------------------------------------------------------------------------------------------------------------
        Method      :   removeVehicle
        Input       :   GuestWSRequest
        Output      :   GuestWSResponse
        Description :   Remove the Vehicle from the Guest
    ----------------------------------------------------------------------------------------------------------------------------------------*/
     
     webservice static GuestWSResponse removeVehicle(GuestWSRequest request)  {
     
        system.debug('############# Entry: GuestRegVehicleWebserviceCalls.removeVehicle with Request = ' + request);
        
        GuestWSResponse response = new GuestWSResponse();
        
        try {
            response = GuestVehicleDetailsMgmt.removeVehicle(request);
           
        }
        catch(SPException ex) {
            System.debug(' ***  Exception Class ***' +  ex.getTypeName() + '\n' );
            System.debug(' ***  Line Number ***' +  ex.getLineNumber() + '\n' );
            System.debug(' ***  Cause of Exception  ***' +  ex.getMessage()  + '\n' );    
            System.debug(' ***  Severity Level ***' + ex.getSeverity()  + '\n' );
            response.resultStatus             = 'ERROR';
            response.responseMessage       = ex.getMessage(); 
            throw ex;                      
        }
                
        system.debug('############# Exit: GuestRegVehicleWebserviceCalls.removeVehicle with Response = ' + response);
        
        return response;
    }  
    
    
   /***********************************************************************************************************
        Webform Processing
    **********************************************************************************************************/

    webservice static GuestWebFormWSResponse guestWebservices(GuestWebFormWSRequest request) {
    	system.debug('********** Inside Webform Webservice');
    	GuestWebFormWSResponse response = new GuestWebFormWSResponse();
    	response = WebformWebserviceProcessing.guestWebservices(request);
        return response;
    }

}
/******************************************************************************
 *** Author:        SqwarePeg.com
 *** @Since:        11-11-2016
 *** Description:  Class to handle Prospects creation request from new Webform 
 *  with new logic and additionaly create Cases
 *  Webforms: Book a Test Drive, Contact a Dealer and Contact Us
 ******************************************************************************/
 
global with sharing class SP_Webform_Webservice {


    /***********************************************************************************************************
        Webform Webservice Request
    ***********************************************************************************************************/
    global class WebformWebserviceRequest {
    	
    	// Campaign relevant paramaters
    	webservice string   ExternalID                  {get; set;} // Need to add
    	webservice string   FormSubCategory             {get; set;}
    	
        // Dealer relevant parameters
        //webservice string   DealerFax                   {get; set;}
        webservice string   DealerAddress               {get; set;} // Dealer info not required
        webservice string   DealerEmail                 {get; set;}
        webservice string   DealerId                    {get; set;}
        webservice string   DealerBranchId              {get; set;}
        webservice string   DealerName                  {get; set;}
        webservice string   DealerPostcode              {get; set;}
        webservice string   DealerState                 {get; set;}
        webservice string   DealerSuburb                {get; set;}
        webservice string   DealerTelephone             {get; set;}
        
        // Account(Prospect's) personal detail paramters
        webservice string   AccountId                   {get; set;} // AccountId and BirthDate not required
        webservice string   Title                       {get; set;}
        webservice string   FirstName                   {get; set;}
        webservice string   LastName                    {get; set;}
        webservice string   Email                       {get; set;}
        webservice string   Telephone                   {get; set;}
        webservice string   BirthDate                   {get; set;}
        
        // Account's Address
        webservice string   Address                     {get; set;} // Address info not required
        webservice string   Suburb                      {get; set;}
        webservice string   State                       {get; set;}
        webservice string   Postcode                    {get; set;}
      
        // Marketting related paramters
        webservice string   IntendedPurchaseDate        {get; set;}
        webservice string   CarSelectionOne             {get; set;}
        webservice string   CarSelectionTwo             {get; set;} 
        webservice string   CarSelectionThree           {get; set;}
        webservice boolean  IsOptIn                     {get; set;}
       
        webservice string   LeadType                    {get; set;}
        webservice string   TextField                   {get; set;}
        webservice string   PreferredContactMethod      {get; set;}
       	webservice string   PuchasingSituation          {get; set;}
        webservice string   StillConsideringToyota      {get; set;}
        webservice string   VehicleMake                 {get; set;}
        webservice string   VehicleModel                {get; set;}
        webservice string   VehicleYear                 {get; set;}
        webservice string   InformationOrExperience     {get; set;}
        webservice string   EnquirySubType              {get; set;}
        webservice string   OwnedToyotaModel            {get; set;}
        webservice integer  OwnedToyotaYear             {get; set;}
        webservice boolean  OwnAToyota                  {get; set;}
        
        webservice string   PromotionTrackingSource     {get; set;}
        webservice string   PurchaseReasonOne           {get; set;}
        webservice string   PurchaseReasonTwo           {get; set;}
        webservice string   PurchaseReasonThree         {get; set;}
           
        webservice string   Cookie                      {get; set;}       
          
        webservice boolean  BuyingInFuture              {get; set;} 
        webservice boolean  StillOptIn                  {get; set;}
        webservice boolean  VehicleNew                  {get; set;}
        
        webservice string   EnquiryType                 {get; set;}
        webservice string   EnquiryCategory             {get; set;}
        //webservice string   caseVehicleType             {get; set;}
        
        webservice string   OwnedRegNumber				{get; set;}
    }
    
    global class AccountInformationResponse {
    	
        webservice string   Salutation              {get; set;}
        webservice string   FirstName               {get; set;}
        webservice string   LastName                {get; set;} 
        webservice string   MailingStreet           {get; set;}
        webservice string   MailingCity             {get; set;}
        webservice string   MailingPostcode         {get; set;}
        webservice string   Email                   {get; set;}
        webservice Date     PurchaseIntentionDate   {get; set;}
        webservice string   Phone                   {get; set;}
        webservice string   ModelofInterest         {get; set;}
        webservice string   Status                  {get; set;}
    }

    global class WebformWebserviceResponse {
    	
        webservice boolean  Succeed                     {get; set;}
        webservice string   ResponseMessage             {get; set;}
    }


    /***********************************************************************************************************
        Processing
    **********************************************************************************************************/

    webservice static WebformWebserviceResponse ProspectRedirect(WebformWebserviceRequest oArgs) {
    	system.debug('********** Inside Webform Webservice');

        WebformWebserviceResponse oldFinalResponse new WebformWebserviceResponse();

        GuestVehicleWebserviceCalls.GuestWebFormWSRequest newRequest = new GuestVehicleWebserviceCalls.GuestWebFormWSRequest();

        GuestVehicleWebserviceCalls.GuestWebFormWSResponse newResponse = new GuestVehicleWebserviceCalls.GuestWebFormWSResponse();

        newRequest = MappingUtility.mapRequests();

        //return SP_WebformWebserviceProcessing.ProspectRedirect(oArgs);
        newResponse =  GuestVehicleWebserviceCalls.guestWebservices(newRequest);

        oldFinalResponse = MappingUtility.mapResponse();

        return oldFinalResponse;

    }
    
    webservice static AccountInformationResponse GetAccountInfoWebService(String accountId) {
        return SP_WebformWebserviceProcessing.getAccountInfoWebService(accountId);
    }    
    
}
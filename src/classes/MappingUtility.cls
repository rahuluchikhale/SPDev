/**
 * Created by rahulchikhale on 2019-03-01.
 */

public with sharing class MappingUtility {


    public static GuestVehicleWebserviceCalls.GuestWebFormWSRequest mapRequests(SP_Webform_Webservice.WebformWebserviceRequest oldRequest){

        GuestVehicleWebserviceCalls.GuestWebFormWSRequest newRequest = new GuestVehicleWebserviceCalls.GuestWebFormWSRequest();

        // Map each field from old req to new

        // oldRequest.ExternalID no direct match
        newRequest.webFormType = oldRequest.FormSubCategory;

        newRequest.guestDetails.firstName =  oldRequest.FirstName;
        newRequest.guestDetails.lastName = oldRequest.LastName;
        newRequest.guestDetails.email = oldRequest.Email;
        //newRequest.guestDetails.accountId = oldRequest.AccountId
        newRequest.guestDetails.salutation = oldRequest.Title;
        newRequest.guestDetails.phone = oldRequest.Telephone;
        newRequest.guestDetails.dob = oldRequest.BirthDate;

        // Dealer details
        //newRequest.dealerDetails.p = oldRequest.DealerFax;
        //newRequest.dealerDetails.AddressDetails = oldRequest.DealerAddress; map addresses
        //newRequest.dealerDetails.Email = oldRequest.DealerEmail
        newRequest.dealerDetails.DealerCode =   oldRequest.DealerId;
        newRequest.dealerDetails.locationCode = oldRequest.DealerBranchId;
        newRequest.dealerDetails.Name =         oldRequest.DealerName;

        GuestVehicleWebserviceCalls.Address DealerAddressDetails = new GuestVehicleWebserviceCalls.Address();
        DealerAddressDetails.street = oldRequest.DealerAddress;

        DealerAddressDetails.state = oldRequest.DealerState;
        //DealerAddressDetails.country = oldRequest.DealerCountry; // no match
        DealerAddressDetails.postcode = oldRequest.DealerPostcode;
        DealerAddressDetails.cityorsuburb = oldRequest.DealerSuburb;
        // oldRequest.DealerTelephone no match


        GuestVehicleWebserviceCalls.Address accountAddress = new GuestVehicleWebserviceCalls.Address();
        accountAddress.street = oldRequest.Address;
        accountAddress.cityorsuburb = oldRequest.Suburb;
        accountAddress.state = oldRequest.State;
        accountAddress.postcode = oldRequest.Postcode;

        // Marketing related fields

        GuestVehicleWebserviceCalls.LeadDetails leadDetails = new GuestVehicleWebserviceCalls.LeadDetails();
        leadDetails.IntendedPurchaseDate  = oldRequest.IntendedPurchaseDate;
        leadDetails.CarSelectionOne = oldRequest.CarSelectionOne;
                leadDetails.CarSelectionTwo = oldRequest.CarSelectionTwo;
        leadDetails.CarSelectionThree = oldRequest.CarSelectionThree;
        //        leadDetails.IsOptIn = oldRequest.IsOptIn; no direct mapping

        // leadDetails.LeadType = oldRequest.LeadType; no direct mapping
        // leadDetails.TextField = oldRequest.TextField; no direct mapping
        // leadDetails.PreferredContactMethod = oldRequest.PreferredContactMethod; no direct mapping
        // leadDetails.PuchasingSituation = oldRequest.PuchasingSituation; no direct mapping
        // leadDetails.StillConsideringToyota = oldRequest.StillConsideringToyota; no direct mapping
        //  leadDetails.VehicleMake = oldRequest.VehicleMake; no direct mapping
        //  leadDetails.VehicleModel = oldRequest.VehicleModel; no direct mapping
        //  leadDetails.VehicleYear = oldRequest.VehicleYear; no direct mapping
        //  leadDetails.InformationOrExperience = oldRequest.InformationOrExperience; no direct mapping
        //  leadDetails.EnquirySubType = oldRequest.EnquirySubType; no direct mapping
        leadDetails.ownedModel = oldRequest.OwnedToyotaModel;
        leadDetails.ownedModelYear = oldRequest.OwnedToyotaYear;
        leadDetails.ownToyota = oldRequest.OwnAToyota;

        /***
        * No direct mapping
        PromotionTrackingSource
        PurchaseReasonOne
        PurchaseReasonTwo
        PurchaseReasonThree
        Cookie
        BuyingInFuture
        StillOptIn
        VehicleNew
        EnquiryCategory*/
        leadDetails.EnquiryType = oldRequest.EnquiryType;
        leadDetails.ownedRegNo = oldRequest.OwnedRegNumber;

                /* guestDetails 			= new Guest();
                 guestPreferences 		= new GuestPreferences();
                 dealerDetails 			= new Dealer();
                 leadDetails 			= new LeadDetails();
                 campaignDetailsWrapper  = new CampaignWrapper();

                 newRequest.*/

        return newRequest;

    }
    public static SP_Webform_Webservice.WebformWebserviceResponse mapResponse(GuestVehicleWebserviceCalls.GuestWebFormWSResponse newResponse){
        SP_Webform_Webservice.WebformWebserviceResponse oldResponse = new SP_Webform_Webservice.WebformWebserviceResponse();
        oldResponse.Succeed = newResponse.Succeed;
        oldResponse.ResponseMessage = newResponse.ResponseMessage;
        return oldResponse;
    }


}
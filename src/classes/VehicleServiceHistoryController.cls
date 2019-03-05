/**
 * Created by rahulchikhale on 2019-02-26.
 */

public with sharing class VehicleServiceHistoryController {
// public ApexPages.StandardSetController controller {get; set;}

    public  static Vehicle__c vehicle { get; set; }

    @TestVisible public  static SP_ServiceTSAWrapper wrapper { get; set; }

    static Map<String, Anypoint_Mapping__c > mapAnypointMappings = Anypoint_Mapping__c.getAll();

    static AnypointResponse responseany = new AnypointResponse();

    public static boolean showTSA {get; set;}

    public static date RDR_Date {get; set;}

    /*
    * VSH
    *
    * */

    @TestVisible public static List<RepairOrderBooking> repairOrderBookings {get; set;}


            public VehicleServiceHistoryController(ApexPages.StandardController con) {

        showTSA = false ;
        RDR_Date = null ;
        system.debug('showTSA valjue is' + showTSA);

    }

    public static void SHowTSAService() {

        system.debug('Inside SHowTSAService');

        showTSA = true ;

        system.debug('TSA is true');

        String vId = ApexPages.currentPage().getParameters().get('id');
        if ( vId != null && vId != '' ) {
            vehicle = [ SELECT Id, Name, RDR_Date__c FROM Vehicle__c WHERE Id =: vId ];
        }
        system.debug('Vanme is ' + vehicle.Name);
        if(showTSA) {

            RDR_Date = vehicle.RDR_Date__c ;

            HttpResponse    httpResponse;
            //httpResponse = sendHTTPRequest(vehicle.Name); call commented


            // TO DO: remove after API is up
            //setting repairOrderBookings from mock json
            setROBMock();
        }

    }


    /*----------------------------------------------------------------------------------------------------------------------------------------
         Method      :   sendHTTPRequest
         Input       :   String VehicleNumber
         Output      :   Map<String,String>
         Author      :   Rahul Chikhake
         Date        :   26.02.2019
         Description :   Send HttpRequest to the desired endpoint.
    ----------------------------------------------------------------------------------------------------------------------------------------*/

    public static HttpResponse sendHTTPRequest(String VehicleNo)
    {
        System.debug('############# Entry: SP_Anypoint_Integration.sendHTTPRequest ############');

        Http            http;
        HttpRequest     httpRequest;
        HttpResponse    httpResponse;
        system.debug('custom setting end point is' + SPCacheCMMetadata.getAnypointEndpoint());
        String endpoint = SPCacheCMMetadata.getAnypointEndpoint()+'/'+VehicleNo+'/servicebook'; // TO DO: remove after api is up
        //String endpoint = 'https://api-uat.toyota.com.au/ws/rest/service-history/nsd/bookings?VIN'+VehicleNo; new
        system.debug('end point is ' + endpoint);
        //SP_ServiceTSAWrapper1 wrapper = new SP_ServiceTSAWrapper1();


        try
        {
            http = new Http();
            httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setHeader('Content-type', 'application/json');
            httpRequest.setHeader('client_id', mapAnypointMappings.get('client_id').Anypoint_Field__c);
            httpRequest.setHeader('client_secret', mapAnypointMappings.get('client_secret').Anypoint_Field__c);
            httpRequest.setHeader('VIN', VehicleNo );
            httpRequest.setEndpoint(endPoint);
            httpRequest.setTimeout(60000);

            System.debug('############# Sending Request : '+httpRequest);
            httpResponse response = http.send(httpRequest);
            System.debug('############# httpResponse = '+response);

            system.debug('body is ' + JSON.deserializeUntyped(response.getBody()));
            if (response.getStatusCode() != 200)
            {
                responseany.statusCode = string.valueOf(response.getStatusCode());
                responseany.statusMessage = response.getStatus();
                responseany.errorSource = 'HTTP LAYER';

                System.debug('############# FAILED Response : '+response);

                if(response.getBody().contains('Invalid VIN') ) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Service data was not found for this VIN. Please contact support if you believe this to be an error'));
                }

                return response;
            }

            else{
                string Jstring = response.getBody().replace('"date":', '"date_x":');
                wrapper = (SP_ServiceTSAWrapper) JSON.deserializeStrict(Jstring, SP_ServiceTSAWrapper.class);
                system.debug('service keys is ' + wrapper.operations);
                //system.debug('service keys is ' + wrapper1.ServiceKeys);
                System.debug('############# SUCCEDED Response : '+response);

                return response;

            }

        }

        catch(CalloutException e)
        {
            System.debug('############# CalloutException = '+e.getMessage());
            System.debug('############# Exit: SP_Anypoint_Integration.sendHTTPRequest ############');

            throw e;
        }

        catch(Exception e)
        {
            System.debug('############# Exception = '+e.getMessage());
            System.debug('############# Exit: SP_Anypoint_Integration.sendHTTPRequest ############');

            throw e;
        }

        // System.debug('############# Exit: SP_Anypoint_Integration.sendHTTPRequest ############');

    }


    //TO DO: Get rid after api is up
    public static void setROBMock(){
        try{
            String jsonInputString = '[{ "repairOrderNumber": "RO11122", "bookingCreatedDateTime": "2019-03-03T23:19:59.689Z", "dropOffPlannedDateTime": "2019-03-03T23:19:59.689Z", "pickupPlannedDateTime": "2019-03-03T23:19:59.689Z", "booking": { "bookingReference": "BK9876", "BookingSrc": "Phone", "transportOption": "Stay" }, "vehicle": { "VIN": "MR0HA3CD300711242", "registration": "1BB9ZZ", "registrationState": "VIC", "mileage": 0 }, "location": { "tmcaDealerCode": "003321", "dealerName": "Acme Toyota", "tmcaBranchCode": "897326", "branchName": "ACME Melbourne Toyota", "department": "Service", "dmsVendor": "Revolution", "dms": "Tune" }, "contacts": [ { "firstName": "John", "lastName": "Guestson", "mobileNumber": "0412356789", "homePhone": "0391234567", "businessPhone": "0398765432", "email": "johnguestson@example.com", "relationship": "owner", "dmsCustId": "1357975", "address": { "street1": "1 High Street", "street2": "string", "suburb": "Prahran", "state": "VIC", "postcode": "3181" } } ], "jobs": [ { "jobNumber": "1", "isExpressMaintenance": true, "serviceOperation": { "category": "PM", "serviceType": "VehicleInspection", "codeType": "Infomedia", "code": "CVI", "description": "Carry out complimentary vehicle inspection" }, "comments": [ { "body": "Rattling in engine around 40 kph", "authorRole": "guest" } ], "notes": [ { "body": "Rattling inspected", "authorRole": "serviceAdvisor" } ] } ] } ]';

            repairOrderBookings = (List<VehicleServiceHistoryController.RepairOrderBooking>)json.deserialize(jsonInputString, List<VehicleServiceHistoryController.RepairOrderBooking>.class);

            System.debug('############# setROBMock ############');
            System.debug(JSON.serialize(repairOrderBookings));

        }catch(Exception e){
            System.debug('Error in conversion '+e.getCause()+' '+e.getLineNumber()+' '+e.getMessage()+' '+e.getStackTraceString()+' '+e.getTypeName());
        }
    }


    // Inner class to hold Anypoint response
    public class AnypointResponse
    {
        public string                       statusCode;
        public string                       statusMessage;
        public string                       errorSource;
    }


    // Inner class to hold Anypoint response

    @TestVisible public class SP_ServiceTSAWrapper {

        public String           serviceCode   {get; set;}
        public String           serviceType   {get; set;}
        public String           version       {get; set;}
        public String           vehicleLine   {get; set;}
        public String           katashikiCode {get; set;}
        public String           suffix        {get; set;}
        public List<Operations> operations    {get; set;}
        public String           date_x        {get; set;}
        public Boolean          tsaEligible   {get; set;}

    }

    public class Operations {
        public String               serviceNumber            {get; set;}
        public String               operation                {get; set;}
        public String               kilometres               {get; set;}
        public String               months                   {get; set;}
        public Double               retailServiceCostIncGST  {get; set;}
        public Decimal              tsaServiceCostIncGST     {get; set;}
        public String               estimatedServiceTime     {get; set;}
        public List<ServiceKeys>    serviceKeys              {get; set;}
    }

    public class ServiceKeys {
        public String key           {get; set;}
        public String section       {get; set;}
        public String description   {get; set;}
        public String action        {get; set;}
    }


    // Innder class to hold response for history

    @TestVisible public class RepairOrderHistory{

        public String repairOrderNumber {get; set;}
        public String workshopEndDateTime {get; set;}
        public String pickupActualDateTime {get; set;}
        public List<Guest> contacts {get; set;}
        public List<JobHistory> jobs {get; set;}
        public Vehicle vehicle {get; set;}
        public Location location {get; set;}
    }

    @TestVisible public class RepairOrderBooking {

        public String repairOrderNumber {get; set;}
        public Datetime bookingCreatedDateTime {get; set;}
        public Datetime dropOffPlannedDateTime {get; set;}
        public Datetime pickupPlannedDateTime {get; set;}
        public Booking booking {get; set;}
        public Vehicle vehicle {get; set;}
        public Location location {get; set;}
        public List<Guest> contacts {get; set;}
        public List<JobBooking> jobs {get; set;}
    }

    public class ServiceOperation {

        public String category {get; set;}
        public String serviceType {get; set;}
        public String codeType {get; set;}
        public String code {get; set;}
        public String description {get; set;}
    }

    public class Jobhistory {

        public String jobNumber {get; set;}
        public ServiceOperation serviceOperation {get; set;}
        public List<Sundry> sundries{get; set;}
        public List<Inclusion> inclusions {get; set;}
        public List<Part> parts{get; set;}
        public List<Comment> comments{get; set;}
        public List<Note> notes{get; set;}

    }

    public class JobBooking {

    public String jobNumber {get; set;}
    public ServiceOperation serviceOperation {get; set;}
    public Boolean isExpressMaintenance {get; set;}
    public List<Comment> comments {get; set;}
    public List<Note> notes {get; set;}

    }

    public class Guest {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String mobileNumber {get; set;}
    public String homePhone {get; set;}
    public String businessPhone {get; set;}
    public String email {get; set;}
    public String relationship {get; set;}
    public String dmsCustId {get; set;}
    public Address address {get; set;}

    }

    public class Address {

    public String street1 {get; set;}
    public String street2 {get; set;}
    public String suburb {get; set;}
    public String state {get; set;}
    public String postcode {get; set;}


    }

    public class Vehicle {

    public String VIN {get; set;}
    public String registration {get; set;}
    public String registrationState {get; set;}
    public String mileage {get; set;}

    }

    public class Inclusion {

    public String description {get; set;}
    public String inclusionNumber {get; set;}

    }

    public class Part{

    public String partNumber {get; set;}
    public String displayName {get; set;}
    public String quantity {get; set;}

    }

    public class Sundry{

    public String displayName {get; set;}
    public String quantity {get; set;}

    }

    public class Booking{

    public String bookingReference {get; set;}
    public String BookingSrc {get; set;}
    public String transportOption {get; set;}


    }

    public class Location{

    public String tmcDealerCode {get; set;}
    public String dealerName {get; set;}
    public String tmcBranchCode {get; set;}
    public String branchName {get; set;}
    public String department {get; set;}
    public String dmsVendor {get; set;}
    public String dms {get; set;}


    }

    public class Comment{
        public String body {get;set;}
        public String authorRole {get;set;}
    }


}
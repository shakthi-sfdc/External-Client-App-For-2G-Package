public with sharing class CreateField {

    @AuraEnabled
    public static void createField(){
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = System.Label.Field_API_Name;
        customField.label = System.Label.Field_API_Name;
        customField.type_x = 'Text'; 
        customField.length = 16;
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        if (results != null) {
            for (MetadataService.SaveResult result : results) {
                handleSaveResults(result);
            }
        } else {
            throw new MetadataServiceExamplesException('No response from Metadata API.');
        }
    }
    public class MetadataServiceExamplesException extends Exception { }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = getSessionIdFromNamedCredential();
		return service;		
    }

    @AuraEnabled
    public static String getSessionIdFromNamedCredential() {
        String returnString = '';
        String orgDomainURL = URL.getOrgDomainUrl().toExternalForm();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST'); 
        req.setEndpoint('callout:FT_Test__Create_Field_MDAPI');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        Consumer_Credential__mdt consumerCredential = [SELECT Client_Id__c, Client_Secret__c FROM Consumer_Credential__mdt LIMIT 1];
        String client_id = consumerCredential.Client_Id__c;
        String client_secret = consumerCredential.Client_Secret__c;

        //String body = System.Label.RequestBody;
        String body = 'grant_type=password' +
                        '&client_id=' + EncodingUtil.urlEncode(client_id, 'UTF-8') +
                        '&client_secret=' + EncodingUtil.urlEncode(client_secret, 'UTF-8') +
                        '&username={!$Credential.Username}' +
                        '&password={!$Credential.Password}';
                        
        returnString += 'Body: '+ body;
        req.setBody(body);
        Http http = new Http();
        HttpResponse res = http.send(req);
        returnString += 'Login failed:: Body '+ res.getBody();
        returnString += 'getStatusCode '+ res.getStatusCode();
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('access_token');
        } else {
            System.debug('Error: ' + res.getBody());
            //throw new CalloutException('Login failed: ' + res.getBody());
        }
        return returnString;
    }

    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        if(saveResult==null || saveResult.success)
            return;
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }   
}
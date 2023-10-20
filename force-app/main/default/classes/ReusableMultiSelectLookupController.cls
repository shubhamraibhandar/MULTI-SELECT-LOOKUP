/***********************************************************************************************************************
 * Name               : ReusableMultiSelectLookupController
 * Description        : controller class to multi-select lookup component
 * Created Date       : 03/10/2023
 * Created By         : Publicis Sapient
 * ----------------------------------------------------------------------------------------------------------------------
 * Version       Author           Date              Comment
 * 1.0           Shubham R        03/10/2023        Initial Version
 ***********************************************************************************************************************/
public inherited sharing class ReusableMultiSelectLookupController {
    private final static String SCENARIO = 'AuraController.ReusableMultiSelectLookupController';

    private final static Integer MAX_RETURNED_RESULT = 5;

    /***********************************************************************************************
     * @Description  : Method to return list of records to show in lookup cmp
     * @Return       : List<sObject>
     ***********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<sObject> retriveSearchData(
        String ObjectName,
        String fieldName,
        String value,
        List<String> selectedRecId,
        String lookupFilter
    ) {
        List<sObject> sObjectResultList = new List<sObject>();
        if (String.isEmpty(value)) {
            return sObjectResultList;
        }

        if (selectedRecId == null) {
            selectedRecId = new List<String>();
        }

        Logger.setScenario(SCENARIO);
        try {
            Map<String, Object> bindVariables = new Map<String, Object>();
            bindVariables.put('nameValue', ('%' + value.trim() + '%'));
            bindVariables.put('selectedRecId', selectedRecId);

            String filterCondition = String.isNotBlank(lookupFilter)
                ? (' AND ' + lookupFilter)
                : '';

            String query =
                'SELECT ' +
                fieldName +
                ' FROM ' +
                ObjectName +
                ' WHERE Name LIKE :nameValue ' +
                filterCondition +
                ' AND Id NOT IN :selectedRecId order by createdDate DESC LIMIT ' +
                MAX_RETURNED_RESULT;

            Logger.debug(new LogMessage('Generated Query: {0}', query));
            Logger.debug(
                new LogMessage(
                    'Bind variables: {0}',
                    JSON.serialize(bindVariables)
                )
            );

            sObjectResultList = Database.queryWithBinds(
                query,
                bindVariables,
                AccessLevel.USER_MODE
            );
            return sObjectResultList;
        } catch (Exception ex) {
            Logger.error('Failed to search for records', ex);

            AuraHandledException aex = new AuraHandledException(
                'Failed to search for records'
            );
            aex.initCause(ex);
            aex.setMessage('Failed to search for records');
            throw aex;
        } finally {
            Logger.saveLog();
        }
    }
}
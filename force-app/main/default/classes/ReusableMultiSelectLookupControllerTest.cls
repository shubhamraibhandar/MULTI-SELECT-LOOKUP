/***********************************************************************************************************************
 * Name               : ReusableMultiSelectLookupControllerTest
 * Description        : Test class for ReusableMultiSelectLookupController
 * Created Date       : 06/01/2023
 * Created By         : Publicis Sapient
 * ----------------------------------------------------------------------------------------------------------------------
 * Version       Author           Date              Comment
 * 1.0           Shubham R        06/01/2023        Initial Version
 ***********************************************************************************************************************/
@isTest
public class ReusableMultiSelectLookupControllerTest {
    /***********************************************************************************************
     * @Description  : Test method to verify retriveSearchData functionality
     ***********************************************************************************************/
    @isTest
    static void testGetRecords() {
        List<Account> acc = OxagonDataFactory.createAccount(
            new List<Account>{
                new Account(Name = 'Test1'),
                new Account(Name = 'Test2'),
                new Account(Name = 'Test3'),
                new Account(Name = 'Test4'),
                new Account(Name = 'Test5'),
                new Account(Name = 'Test6'),
                new Account(Name = 'Test7')
            }
        );
        List<sObject> accList = ReusableMultiSelectLookupController.retriveSearchData(
            'Account',
            ' Name, Type ',
            'Test',
            null,
            'Name != null'
        );
        System.AssertEquals(
            accList.size(),
            5,
            'Unable to fetch sObject records'
        );
    }

    /***********************************************************************************************
     * @Description  : Test method to verify retriveSearchData functionality
     ***********************************************************************************************/
    @isTest
    static void testGetRecordsWhenNoRecordsPresent() {
        Boolean exceptionOccurred = false;
        try {
            List<sObject> accList = ReusableMultiSelectLookupController.retriveSearchData(
                'Account',
                ' Name, Type ',
                'Test ',
                null,
                'Name != null'
            );
            System.AssertEquals(
                accList.isEmpty(),
                true,
                'Unable to fetch sObject records'
            );
        } catch (Exception e) {
            exceptionOccurred = true;
        }
        System.AssertEquals(exceptionOccurred, false, 'Exception check failed');
    }
}
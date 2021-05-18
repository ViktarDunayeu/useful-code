public without sharing class ApplicationFormController{
    /*
    *   links for test
    *   https://dukeseducation--dev--c.visualforce.com/apex/ApplicationFormPage?recordType=Cardiff%20Sixth%20Form%20College&pageLayout=Cardiff%20Sixth%20Form%20College
    *   https://dukeseducation--dev--c.visualforce.com/apex/ApplicationFormPage?recordType=Earlscliffe&pageLayout=Earlscliffe
    *   https://dukeseducation--dev--c.visualforce.com/apex/ApplicationFormPage?recordType=Fine%20Arts%20College&pageLayout=Fine%20Arts%20College
    *   https://dukeseducation--dev--c.visualforce.com/apex/ApplicationFormPage?recordType=Rochester&pageLayout=Rochester
    *   https://dukeseducation--dev--c.visualforce.com/apex/ApplicationFormPage?recordType=St%20Andrews&pageLayout=St%20Andrews
    */

    //https://dukeseducation--dev--c.visualforce.com/apex/ApplicationFormPage?recordType=Rochester&pageLayout=Application%20Layout

    private List<FieldWrapper> leftColumn {get; set;}
    private List<FieldWrapper> rightColumn {get; set;}

    public ApplicationFormController(ApexPages.StandardController controller){
        String pageLayoutName = System.currentPageReference().getParameters().get('pageLayout');
        String recordTypeName = System.currentPageReference().getParameters().get('recordType');

        Application__c application = (Application__c)controller.getRecord();
        application.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();

        List<List<String>> layoutFileds = getFiledsFromLayout(pageLayoutName);
        this.leftColumn = getFieldsInfoList(layoutFileds[0]);
        this.rightColumn = getFieldsInfoList(layoutFileds[1]);
    }

    public List<FieldWrapper> getLeftFields(){
        return leftColumn;
    }

    public List<FieldWrapper> getRightFields(){
        return rightColumn;
    }

    public static List<List<String>> getFiledsFromLayout(String pageLayout){
        List<List<String>> fieldList = new List<List<String>>();
        Metadata.LayoutSection formSectionInfo = getSectionByLayout(pageLayout);
        
        for (Metadata.LayoutColumn column: formSectionInfo.layoutColumns) {
            List<String> columnFileds = new List<String>();
            if (column.layoutItems != null) {
                for (Metadata.LayoutItem item : column.layoutItems) {
                    columnFileds.add(item.field);
                }
            }
            fieldList.add(columnFileds);
        }
        return fieldList;
    }

    public static Metadata.LayoutSection getSectionByLayout(String layoutName){
        String currentName = 'Application__c-' + layoutName;
        Metadata.LayoutSection formSection;

        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {currentName});
        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);

        for (Metadata.LayoutSection section : layoutMd.layoutSections) {
            if(section.label == 'Form'){
                formSection = section;
            }
        }

        return formSection;
    }

    public static List<FieldWrapper> getFieldsInfoList(List<String> layoutFileds){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Application__c').getDescribe().Fields.getMap();
        List<FieldWrapper> fieldsInfo = new List<FieldWrapper>();

        for(Schema.SObjectField mapItem: fieldMap.values()){
            for(String layoutItem: layoutFileds){
                if(mapItem.getDescribe().getName() == layoutItem){
                    FieldWrapper wrapper = new FieldWrapper(
                        mapItem.getDescribe().getName(),
                        mapItem.getDescribe().getLabel()
                    );
                    fieldsInfo.add(wrapper);
                }
            }
        }

        return fieldsInfo;
    }
}
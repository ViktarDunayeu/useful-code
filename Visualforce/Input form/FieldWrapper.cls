public with sharing class FieldWrapper {

    public String apiName {get; set;}
    public String label {get; set;}

    public FieldWrapper(String apiName, String label) {
        this.apiName = apiName;
        this.label = label;
    }
}
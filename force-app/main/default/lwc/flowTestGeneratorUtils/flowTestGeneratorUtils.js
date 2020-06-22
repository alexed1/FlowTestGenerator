export {
    settings
};

const settings = {
    attributeParamName: 'Name',
    attributeParamValue: 'Value__c',
    inputTypeText: 'text',
    outputTypeString: 'String',
    inputTypeMap: {"String": 'text', "Number": "number", "DateTime": 'datetime', "Date": 'date'},
    outputTypeMap: {
        "number": "DOUBLE",
        "datetime": "DATETIME",
        "date": "DATETIME",
        "text": "STRING",
    },
    stepSpecifyTestInputs: 'inputs',
    stepSpecifyTestOutputs: 'outputs',
    stepConfirmGenerateTest: 'confirm'
}
import {LightningElement, api, track} from 'lwc';
import {settings} from 'c/flowTestGeneratorUtils';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

export default class FlowTestSetAssertions extends LightningElement {
    @api flowTestId;
    _outputOptions = [];
    _flowVariables = [];
    @track _testAssertions = [];
    lastExpressionIndex = 0;

    @api get flowVariables() {
        return this._flowVariables;
    }

    set flowVariables(value) {
        this._flowVariables = value;
        this.setVariablesOptions();
    }

    @api get testAssertions() {
        let resultOptions = [];
        this._testAssertions.forEach(curLine => {
            resultOptions.push(this.convertJSToSObject(curLine));
        });
        return resultOptions;
    }

    set testAssertions(value) {
        this._testAssertions = [];
        if (value && value.length) {
            value.forEach(curValue => {
                this._testAssertions.push(this.convertSObjectToJS(curValue));
            });
        }
    }

    dispatchFlowValueChangedEvent() {
        const valueChangeEvent = new FlowAttributeChangeEvent('testAssertions', this.testAssertions);
        // this.dispatchEvent(valueChangeEvent);
    }

    convertJSToSObject(curValue) {
        let newValue = JSON.parse(JSON.stringify(curValue));
        delete newValue.uid;
        return newValue;
    }

    convertSObjectToJS(curValue) {
        return this.generateNewTestAssertion(curValue);
    }

    generateNewTestAssertion(curValue) {
        if (curValue) {
            return {...curValue, ...{uid: this.lastExpressionIndex++}}
        }
        return {
            uid: this.lastExpressionIndex++,
            Name: null,
            Assertion_Formula__c: null,
            Error_Message__c: null,
            Id: null,
            Flow_Test__c: this.flowTestId
        };
    }
    innerIndex = 0;
    labels = {
        inputVariablesLabel: "Specify Test Inputs",
        outputVariablesLabel: "Specify Test Outputs",
        addInputVariableButtonLabel: "Add Input Variable",
        addExpressionButtonLabel: "Add Expression",
        addAssertionButtonLabel: "Add Assertion",
        assertionNameInputLabel: "Assertion Name",
        assertionErrorMessageLabel: "Error Message",
        generateTestClassLabel: "Generate Test Class",
        testMethodNameLabel: "Test Method Name",
        setOutputVariablesButtonLabel: "Set Output Variables",
        confirmAndGenerateButtonLabel: "Confirm and Generate"
    }

    setVariablesOptions() {
        this._inputOptions = [];
        if (this._flowVariables && this._flowVariables.length) {
            this._flowVariables.forEach(curVariable => {
                if (!curVariable.IsCollection) {
                    if (curVariable.IsOutput) {
                        let curType = settings.outputTypeMap[curVariable.DataType.toLowerCase()];
                        this._outputOptions.push({
                            label: curVariable.ApiName,
                            value: ('##' + curVariable.ApiName),
                            dataType: curType ? curType : settings.outputTypeString,
                            renderType: curVariable.DataType.toLowerCase()
                        })
                    }
                }
            })
        }
    }

    handleRemoveAssertion(event) {
        this._testAssertions = this._testAssertions.filter(curLine => curLine.uid.toString() !== event.currentTarget.dataset.uid);
        this.dispatchFlowValueChangedEvent();
    }

    @api getTestMethodData() {
        let assertionsMap = {};
        let inputVariablesMap = {};

        this._testAssertions.forEach(curAssertion => {
            assertionsMap[curAssertion.Assertion_Formula__c] = curAssertion.Error_Message__c;
        });
        let outputVariablesToTypeMap = {};
        this._outputOptions.forEach(curOutputVariable => {
            outputVariablesToTypeMap[curOutputVariable.value.replace('##', '')] = curOutputVariable.dataType;
        });

        return {
            testMethodName: this.flowTestId,
            inputVariablesMap: inputVariablesMap,
            outputVariablesToTypeMap: outputVariablesToTypeMap,
            assertionsMap: assertionsMap
        };
    }

    connectedCallback() {
        if (!this._testAssertions || !this._testAssertions.length) {
            this.handleAddTestAssertion();
        }
    }

    handleExpressionChanged(event) {
        let changedAssertion = this._testAssertions.find(curAssertion => curAssertion.uid === event.detail.name);
        if (changedAssertion) {
            changedAssertion.Assertion_Formula__c = event.detail.value;
            this.dispatchFlowValueChangedEvent();
        }
    }

    handleAddTestAssertion(event) {
        this._testAssertions.push(this.generateNewTestAssertion());
    }

    get testAssertions() {
        let index = 1;
        return this._testAssertions.map(curAssertion => {
                return {
                    ...curAssertion, ...{index: index++}
                }
            }
        )
    }

    handleAssertionVariableChange(event) {
        let foundAssertion = this._testAssertions.find(curLine => curLine.uid.toString() === event.currentTarget.dataset.uid);
        if (foundAssertion) {
            foundAssertion[event.currentTarget.name] = event.target.value;
            this.dispatchFlowValueChangedEvent();
        }

    }

    @api
    validate() {
        let validity = {
            isValid: true
        };
        let inputsToVerify = this.template.querySelectorAll('c-expression-builder');
        if (inputsToVerify && inputsToVerify.length) {
            inputsToVerify.forEach(curInput => {
                let reportedValidity = curInput.validate();
                if (!reportedValidity || !reportedValidity.isValid) {
                    validity = reportedValidity;
                    return reportedValidity;
                }
            })
        }
        return validity;
    }
}
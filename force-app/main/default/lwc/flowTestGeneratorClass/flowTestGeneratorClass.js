import {LightningElement, api, track} from 'lwc';
import generateTestClass from '@salesforce/apex/FlowTestGenerator.generateTestClass';
import {settings} from 'c/flowTestGeneratorUtils';

export default class FlowTestGeneratorClass extends LightningElement {
    @api flowApiName;
    @track flowTestMethods = [];
    @api curTestMethod;
    _inputOptions = [];
    _outputOptions = [];
    _flowVariables;
    stepName;
    innerIndex = 0;

    connectedCallback() {
        if (!this.flowTestMethods || !this.flowTestMethods.length) {
            this.handleAddTestMethod();
        }
    }

    handleAddTestMethod(event) {
        this.curTestMethod = this.generateNewTestMethod();
        this.flowTestMethods.push(this.curTestMethod);
        this.stepName = settings.stepSpecifyTestInputs;
    }

    generateNewTestMethod() {
        return {
            id: this.flowApiName + this.innerIndex++,
            methodName: null,
            testMethodData: null
        };
    }

    handleStepChangedEvent(event) {
        this.stepName = event.detail.stepName;
    }

    @api
    get flowVariables() {
        return this._flowVariables;
    }

    set flowVariables(value) {
        this._flowVariables = value;
        this.setVariablesOptions();
    }

    setVariablesOptions() {
        this._inputOptions = [];
        if (this._flowVariables && this._flowVariables.length) {
            this._flowVariables.forEach(curVariable => {
                if (!curVariable.IsCollection) {
                    if (curVariable.IsInput) {
                        this._inputOptions.push({
                            label: curVariable.ApiName,
                            value: curVariable.ApiName
                        })
                    }
                    if (curVariable.IsOutput) {
                        let curType = settings.outputTypeMap[curVariable.DataType];
                        this._outputOptions.push({
                            label: curVariable.ApiName,
                            value: ('##' + curVariable.ApiName),
                            dataType: curType ? curType : settings.outputTypeString
                        })
                    }
                }
            })
        }
    }

    handleGenerateTestClass(event) {
        let allTestMethodCMPs = this.template.querySelectorAll('c-flow-test-generator-method');
        if (allTestMethodCMPs) {
            let allTestMethodData = [];
            allTestMethodCMPs.forEach(curTestMethodCMP => {
                allTestMethodData.push(curTestMethodCMP.getTestMethodData());
            });
            generateTestClass({
                nameSpace: '',
                flowName: this.flowApiName,
                testClassDataListJSON: JSON.stringify(allTestMethodData)
            }).then(result => {

            });
        }
    }

    labels = {
        addNewMethodButtonLabel: "Add New Test Method",
        generateTestClassLabel: "Generate Test Class"
    }

    get renderConfirmScreen() {
        return this.stepName === settings.stepConfirmGenerateTest;
    }

    get renderSpecifyInputVariables() {
        return this.stepName === settings.stepSpecifyTestInputs;
    }
}
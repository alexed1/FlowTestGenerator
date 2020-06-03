import {LightningElement, api, track} from 'lwc';
import {settings} from 'c/flowTestGeneratorUtils';

export default class FlowTestGeneratorMethod extends LightningElement {
    @api methodName;
    @api flowApiName;
    @api inputOptions = [];
    @api outputOptions = [];
    @api flowVariables;
    @api stepName;
    @track _testAssertions = [];
    @track _expressionLines = [];

    get renderSpecifyInputVariables() {
        return this.stepName === settings.stepSpecifyTestInputs;
    }

    get renderSpecifyOutputVariables() {
        return this.stepName === settings.stepSpecifyTestOutputs;
    }

    get disableMethodNameInput() {
        return this.stepName !== settings.stepSpecifyTestInputs;
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

    handleNavigateToConfirmAndGenerate(event) {
        this.dispatchStepChangedEvent(settings.stepConfirmGenerateTest);
    }

    handleNavigateToSetOutputVariables(event) {
        this.dispatchStepChangedEvent(settings.stepSpecifyTestOutputs);
    }

    dispatchStepChangedEvent(newStepName) {
        const memberRefreshedEvt = new CustomEvent('stepchanged', {
            bubbles: true,
            detail: {
                stepName: newStepName
            }
        });
        this.dispatchEvent(memberRefreshedEvt);
    }

    handleRemoveAssertion(event) {
        this._testAssertions = this._testAssertions.filter(curLine => curLine.id.toString() !== event.currentTarget.dataset.id);
    }

    @api getTestMethodData() {
        let assertionsMap = {};
        let inputVariablesMap = {};

        this._expressionLines.forEach(curEL => {
            inputVariablesMap[curEL.paramName] = curEL.paramValue;
        });
        this._testAssertions.forEach(curAssertion => {
            assertionsMap[curAssertion.formulaString] = curAssertion.errorMessage;
        });
        let outputVariablesToTypeMap = {};
        this.outputOptions.forEach(curOutputVariable => {
            outputVariablesToTypeMap[curOutputVariable.value.replace('##', '')] = curOutputVariable.dataType;
        });

        return {
            testMethodName: this.methodName,
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

    handleInputParamChangedEvent(event) {
        this._expressionLines = event.detail.value;
    }

    handleExpressionChanged(event) {
        let changedAssertion = this._testAssertions.find(curAssertion => curAssertion.id === event.detail.name);
        if (changedAssertion) {
            changedAssertion.formulaString = event.detail.value;
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

    handleMethodNameChange(event) {
        this.methodName = event.target.value;
    }

    handleAssertionVariableChange(event) {
        let foundAssertion = this._testAssertions.find(curLine => curLine.id.toString() === event.currentTarget.dataset.id);
        if (foundAssertion) {
            foundAssertion[event.currentTarget.name] = event.target.value;
        }
    }

    generateNewTestAssertion() {
        return {
            id: this.methodName + this.innerIndex++,
            name: null,
            formulaString: null,
            errorMessage: null
        };
    }
}
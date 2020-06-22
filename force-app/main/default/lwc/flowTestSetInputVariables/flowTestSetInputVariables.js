import {LightningElement, track, api} from 'lwc';
import {settings} from 'c/flowTestGeneratorUtils';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

export default class FlowTestSetInputVariables extends LightningElement {
    @api flowTestId;
    @track _expressionLines = [];
    _flowVariables = [];
    _inputOptions = [];
    // _outputOptions = [];
    isLoading;
    lastExpressionIndex = 0;

    labels = {
        addButtonLabel: 'Add'
    }

    @api get flowVariables() {
        return this._flowVariables;
    }

    set flowVariables(value) {
        this._flowVariables = value;
        this.setVariablesOptions();
    }

    @api get expressionLines() {
        return this._expressionLines;
    }

    set expressionLines(value) {
        this._expressionLines = value;
    }

    @api get inputOptionsValues() {
        let resultOptions = [];
        this._expressionLines.forEach(curLine => {
            // if (curLine.paramValue || curLine.paramValue) {
            resultOptions.push(this.convertJSToSObject(curLine));
            // }
        });
        return resultOptions;
    }

    set inputOptionsValues(value) {
        this._expressionLines = [];
        if (value && value.length) {
            value.forEach(curValue => {
                this._expressionLines.push(this.convertSObjectToJS(curValue));
            });
        }
    }

    generateNewExpression(curValue) {
        if (curValue) {
            return {...curValue, ...{uid: this.lastExpressionIndex++}}
        }
        return {
            uid: this.lastExpressionIndex++,
            Name: '',
            Value__c: '',
            Type__c: null,
            Id: null,
            Flow_Test__c: this.flowTestId
        };
    }

    convertJSToSObject(curValue) {
        let newValue = JSON.parse(JSON.stringify(curValue));
        delete newValue.uid;
        return newValue;
    }

    convertSObjectToJS(curValue) {
        return this.generateNewExpression(curValue);
    }

    connectedCallback() {
        if (!this._expressionLines || !this._expressionLines.length) {
            this.addNewExpression();
        }
    }

    dispatchFlowValueChangedEvent() {
        const valueChangeEvent = new FlowAttributeChangeEvent('inputOptionsValues', this.inputOptionsValues);
        this.dispatchEvent(valueChangeEvent);
    }

    handleParamChange(event) {

        let curExpressionLine = this.getExpressionLineById(event.currentTarget.dataset.uid);
        if (curExpressionLine) {
            let isOptionValid = this.isOptionValid(curExpressionLine[event.currentTarget.name], event.detail.value);
            if (isOptionValid) {
                curExpressionLine[event.currentTarget.name] = event.detail.value;
                if (event.currentTarget.name === settings.attributeParamName) {
                    let curVariable = this.getFlowVariableByApiName(event.detail.value);
                    if (curVariable) {
                        let definedType = settings.inputTypeMap[curVariable.DataType];
                        curExpressionLine.Type__c = definedType ? definedType : settings.inputTypeText
                    }
                }
            } else {
                //TODO: handle error invalid option
                console.log('Option is invalid: ' + event.detail.value);
            }
        }
        this.dispatchFlowValueChangedEvent();
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
                }
            })
        }
    }

    handleValueChange(event) {
        let curExpressionLine = this.getExpressionLineById(event.currentTarget.dataset.uid);
        if (curExpressionLine) {
            curExpressionLine[event.currentTarget.name] = event.target.value;
        }
        this.dispatchFlowValueChangedEvent();
    }

    getExpressionLineById(id) {
        return this._expressionLines.find(curLine => curLine.uid.toString() === id);
    }

    getFlowVariableByApiName(apiName) {
        if (this._flowVariables && this._flowVariables.length) {
            return this._flowVariables.find(curVariable => curVariable.ApiName === apiName);
        }
    }

    handleExpressionRemove(event) {
        this._expressionLines = this._expressionLines.filter(curLine => curLine.uid.toString() !== event.currentTarget.dataset.uid);
    }

    handleAddExpression() {
        this.addNewExpression();
    }

    addNewExpression() {
        this._expressionLines.push(this.generateNewExpression());
    }


    isOptionValid(selectedLineOption, newLineOption) {
        return true;
        // let validOptions = this.getValidOptions(selectedLineOption);
        // return !!validOptions.find(curOption => curOption.paramName === newLineOption);
    }

    get disabledAddButton() {
        return this._expressionLines.length >= this._inputOptions.length;
    }
}
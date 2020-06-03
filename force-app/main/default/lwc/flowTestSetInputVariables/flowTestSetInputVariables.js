import {LightningElement, track, api} from 'lwc';
import {settings} from 'c/flowTestGeneratorUtils';


export default class FlowTestSetInputVariables extends LightningElement {
    @api name;
    @api label;
    @api addButtonLabel;
    @api flowVariables = [];
    @api inputOptions = [];
    @track _expressionLines = [];

    isLoading;
    lastExpressionIndex = 0;

    @api get expressionLines() {
        return this._expressionLines;
    }

    set expressionLines(value) {
        this._expressionLines = value;
    }

    connectedCallback() {
        if (!this._expressionLines || !this._expressionLines.length) {
            this.addNewExpression();
        }
    }

    dispatchValueChangedEvent() {
        const memberRefreshedEvt = new CustomEvent('expressionchanged', {
            bubbles: true,
            detail: {
                name: this.name,
                value: this._expressionLines
            }
        });
        this.dispatchEvent(memberRefreshedEvt);
    }

    handleParamChange(event) {

        let curExpressionLine = this.getExpressionLineById(event.currentTarget.dataset.id);
        if (curExpressionLine) {
            let isOptionValid = this.isOptionValid(curExpressionLine[event.currentTarget.name], event.detail.value);
            if (isOptionValid) {
                curExpressionLine[event.currentTarget.name] = event.detail.value;
                if (event.currentTarget.name === settings.attributeParamName) {
                    let curVariable = this.getFlowVariableByApiName(event.detail.value);
                    if (curVariable) {
                        let definedType = settings.inputTypeMap[curVariable.DataType];
                        curExpressionLine.type = definedType ? definedType : settings.inputTypeText
                    }
                }
            } else {
                //TODO: handle error invalid option
                console.log('Option is invalid: ' + event.detail.value);
            }
        }
        this.dispatchValueChangedEvent();
    }

    handleValueChange(event) {
        let curExpressionLine = this.getExpressionLineById(event.currentTarget.dataset.id);
        if (curExpressionLine) {
            curExpressionLine[event.currentTarget.name] = event.target.value;
        }
        this.dispatchValueChangedEvent();
    }

    getExpressionLineById(id) {
        return this._expressionLines.find(curLine => curLine.id.toString() === id);
    }

    getFlowVariableByApiName(apiName) {
        if (this.flowVariables && this.flowVariables.length) {
            return this.flowVariables.find(curVariable => curVariable.ApiName === apiName);
        }
    }

    handleExpressionRemove(event) {
        this._expressionLines = this._expressionLines.filter(curLine => curLine.id.toString() !== event.currentTarget.dataset.id);
    }

    handleAddExpression() {
        this.addNewExpression();
    }

    addNewExpression() {
        this._expressionLines.push(this.generateNewExpression());
    }

    generateNewExpression() {
        return {
            id: this.name + this.lastExpressionIndex++,
            paramName: '',
            paramValue: '',
            type: null
        };
    }

    // getValidOptions(selectedLineOption) {
    //     if (!this.expressionLines || !this.expressionLines.length) {
    //         return this._inputOptions;
    //     } else {
    //         return this._inputOptions.filter(curOption => {
    //             let foundExpression = this.expressionLines.find(curExpressionLine => {
    //                 return (curExpressionLine.paramName === curOption.value || curExpressionLine.paramName === selectedLineOption)
    //             });
    //             return !foundExpression;
    //         });
    //     }
    // }

    isOptionValid(selectedLineOption, newLineOption) {
        return true;
        // let validOptions = this.getValidOptions(selectedLineOption);
        // return !!validOptions.find(curOption => curOption.paramName === newLineOption);
    }

    get disabledAddButton() {
        return this._expressionLines.length >= this.inputOptions.length;
    }
}
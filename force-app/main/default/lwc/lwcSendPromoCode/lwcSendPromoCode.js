import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import SendPromoCodeLabel from '@salesforce/label/c.SendPromoCode';

import PROMO_CODE_BRAND_FIELD from '@salesforce/schema/Case.Promo_code_brand__c';
import PROMO_CODE_SENT_FIELD from '@salesforce/schema/Case.Promo_code_sent_to_customer__c';
import RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import BRAND_FIELD from '@salesforce/schema/Case.brand__c';

const FIELDS = [PROMO_CODE_BRAND_FIELD, RECORDTYPEID_FIELD, BRAND_FIELD, PROMO_CODE_SENT_FIELD];

export default class SendPromoCode extends NavigationMixin(LightningElement) {
    @api recordId;
    showLoader = true;
    showBrand = false;
    titleLabel = SendPromoCodeLabel;
    rtId;
    error;
    
    discountCodeField = PROMO_CODE_BRAND_FIELD;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    handleResult({error, data}) {
        if(data) {
            console.log(JSON.stringify(data));
            this.caseRecord = data;
            this.rtId = data.fields.RecordTypeId.value;
            const brand = getFieldValue(this.caseRecord, BRAND_FIELD);
            const isPromoCodeSent = getFieldValue(this.caseRecord, PROMO_CODE_SENT_FIELD);

            if (isPromoCodeSent) {
                this.showNotification('error', 'Error', 'Promo Code has already been sent for this case.');
                this.navigateToCaseRecord();
            }
            else
            {
                this.showBrand = true;
            }

            /*if (!brand) {
                this.showBrand = true;
            } else if (brand.toUpperCase() !== 'BEANZ') {
                this.showNotification('error', 'Error', 'Promo Code can only be sent for Beanz case.');
                this.navigateToCaseRecord();
            } else if (isPromoCodeSent) {
                this.showNotification('error', 'Error', 'Promo Code has already been sent for this case.');
                this.navigateToCaseRecord();
            }*/
            this.showLoader = false;
        } else {
            this.error = error;
        }
    } 
    
    handlesubmit(event) {
        event.preventDefault();
        this.showLoader = true;
        console.log(JSON.parse(JSON.stringify(event.detail)));
        //const brand = getFieldValue(this.caseRecord, BRAND_FIELD);
        const brand = 'Beanz';
        const fields = event.detail.fields;
        
        if (brand) {
            fields.Promo_code_brand__c = brand;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);        
        this.showNotification('Success', 'Success', 'Promo code sent to customer.');
    }
    
    navigateToCaseRecord() {
        this.showLoader = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
    
    showNotification(_variant, _title, _message) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
}
import { LightningElement, wire,track } from 'lwc';
import getContactList from '@salesforce/apex/DataController.getContactList'
import getAccountList from '@salesforce/apex/DataController.getAccountList'
export default class PaginationDemo extends LightningElement {
    totalContacts
    visibleContacts
    @track selectedCons;
    @track error;
    @track bShowModal = false;
    totalAccounts
    visibleAccounts
    @wire(getContactList)
    wiredContact({error, data}){
        if(data){ 
            this.totalContacts = data
            console.log(this.totalContacts)
        }
        if(error){
            console.error(error)
        }
    }

    @wire(getAccountList)
    wiredaccount({error, data}){
        if(data){ 
            this.totalAccounts = data
            console.log(this.totalAccounts)
        }
        if(error){
            console.error(error)
        }
    }

    updateContactHandler(event){
        this.visibleContacts=[...event.detail.records]
        console.log(event.detail.records)
    }
    updateAccountHandler(event){
        this.visibleAccounts=[...event.detail.records]
        console.log(event.detail.records)
    }
    // Select the all rows
    allSelected(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }
        }
        console.log("selectedRows***********"+JSON.stringify(selectedRows));
    }

    showAccounts() {
        this.bShowModal = true;

        this.selectedCons = [];

        let selectedRows = this.template.querySelectorAll('lightning-input');

        // based on selected row getting values of the contact
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
                this.selectedCons.push({
                    Name: selectedRows[i].value,
                    Id: selectedRows[i].dataset.id
                })
            }
        }
        console.log("selectedRows***********"+JSON.stringify(selectedRows));
    }
    

}
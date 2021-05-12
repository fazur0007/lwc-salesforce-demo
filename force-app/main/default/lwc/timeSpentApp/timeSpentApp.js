import { LightningElement, track,api } from 'lwc';
import timeSpent from '@salesforce/apex/TimeTrackerApp.timeSpent';
import getDefaultTime from '@salesforce/apex/TimeTrackerApp.getDefaultTime';
export default class Stopwatch extends LightningElement {
    @track showStartBtn = true;
    @track timeVal = '0:0:0:0';
    timeIntervalInstance;
    totalMilliseconds = 0;
    @api objectApiName;
    @api recordId;
    @track currenObjectName;
    @track currenRecordId;

    connectedCallback() {
        this.currenRecordId = this.recordId;
        this.currenObjectName = this.objectApiName;
        let jsonString = {
            "currenRecordId" : this.currenRecordId,
            "currentObjectName" :this.currenObjectName
        };
        getDefaultTime({jsonObject : jsonString})
            .then(result => {
                console.log(result); 
                let timeSpent = JSON.parse(result);
                if(timeSpent.hasOwnProperty('Capture_Time_Spent__c')){
                    console.log(timeSpent.Capture_Time_Spent__c);
                    let dbTime = timeSpent.Capture_Time_Spent__c.split(":");
                    this.timeVal = '0:'+ (dbTime[1] === '00' ? '0' : dbTime[1]) +':0:0';
                    //this.totalMilliseconds = (dbTime[1] === '00' ? '0' : dbTime[1]);
                }                
            })
            .catch(error => {
                console.log(error);
            });
    }
    getDefaultTimeDetaiils(){

    }
    start(event) {
        this.showStartBtn = false;
        var parentThis = this;
        let currentRecId = this.currenRecordId;
        let currentObjName = this.currentObjectName;
        console.log("*****"+currentRecId);
        // Run timer code in every 100 milliseconds
        this.timeIntervalInstance = setInterval(function() { 

            // Time calculations for hours, minutes, seconds and milliseconds
            var hours = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((parentThis.totalMilliseconds % (1000 * 60)) / 1000);
            var milliseconds = Math.floor((parentThis.totalMilliseconds % (1000)));
            
            // Output the result in the timeVal variable
            parentThis.timeVal = hours + ":" + minutes + ":" + seconds + ":" + milliseconds;   
            
            parentThis.totalMilliseconds += 100;
            let jsonString = {
                "timeSpentMinutes" : parentThis.timeVal,
                "currenRecordId" : currentRecId,
                "currentObjectName" :currentObjName
            };
            timeSpent({jsonObject : jsonString})
                .then(result => {
                    console.log(result);
                })
                .catch(error => {
                    console.log(error);
                });
        }, 100);
    }

    stop(event) {
        this.showStartBtn = true;
        clearInterval(this.timeIntervalInstance);
    }

    reset(event) {
        this.showStartBtn = true;
        this.timeVal = '0:0:0:0';
        this.totalMilliseconds = 0;
        clearInterval(this.timeIntervalInstance);
    }
}
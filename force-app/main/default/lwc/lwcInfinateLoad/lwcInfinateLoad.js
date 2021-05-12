import { LightningElement, track } from 'lwc';
export default class LwcInfinateLoad extends LightningElement {
    tableColumns = [
        {label: 'Number', fieldName: 'Id', type: 'number'},
        {label: 'Name', fieldName: 'Name'}
    ];

    @track data = [];
    @track isLoaded = false;

    addMoreDataCounter = 0;

    connectedCallback() {
        this.addMoreData();
        this.isLoaded = true;
    }

    addMoreData() {
        const offset = this.data.length;
        let newData = [];

        for(let i=offset + 1;i<=offset + 100; i++) {
            newData.push({
                Id: i,
                Name: 'Test Row #' + i
            });
        }

        this.data = [...this.data, ...newData];

        this.addMoreDataCounter++;
    }

    onLoadMoreHandler() {
        console.log('load more');
        this.addMoreData();

        if(this.addMoreDataCounter === 100 ) {
            this.isLoaded = false;
        }
    }
}
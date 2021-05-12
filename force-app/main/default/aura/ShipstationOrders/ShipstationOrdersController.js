({
    getMyOrders : function(component, event, helper) {
        helper.getMyOrders(component, event, helper);
    },
    handleRowAction: function ( cmp, event, helper ) {
        //var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        //var recId = row.Id;
        cmp.set("v.rowData",row);
        cmp.set("v.openModal", true);
    },
    handleOpenModal: function(component, event, helper) {
        component.set("v.openModal", true);
    },
    handleCloseModal: function(component, event, helper) {
        component.set("v.openModal", false);
    }
})
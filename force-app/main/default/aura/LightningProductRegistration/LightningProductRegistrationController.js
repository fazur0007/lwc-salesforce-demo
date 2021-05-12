({
	initialize : function(component, event, helper) {        
		let searchParameters = decodeURIComponent(window.location.search);
        if (searchParameters !== '') {
            searchParameters = searchParameters.substring(1).split('&'); // get ride of '?'
            for (let i = 0; i < searchParameters.length; i++) {
                let eachKey = searchParameters[i].split('=');
                if(eachKey[0] === 'state')
                {
                    component.set('v.statequeryparam', eachKey[1]);
                }                
            }
        }
        console.log('state:'+component.get('v.statequeryparam'));
	}
})
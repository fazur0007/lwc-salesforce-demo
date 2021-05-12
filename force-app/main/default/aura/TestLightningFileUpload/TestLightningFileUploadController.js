({
	handleClick : function(component, event, helper) {
		 var uploadedFiles = event.getParams("files");
        alert("Files uploaded : " + uploadedFiles.length);

	}
})
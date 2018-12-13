({  
    // Load current profile picture
    onInit: function(component) {
        var action = component.get("c.getProfilePicture"); 
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var image = a.getReturnValue();
            console.log(image);
            if (image != null && image.Id != null) {
                component.set("v.image", '/sfc/servlet.shepherd/version/download/'+image.Id);
                component.set("v.renderNew", true);
            }
            var response = a.getState();
            if (response == "ERROR") {
                let errorData = JSON.parse(error.message);
                error(errorData.name + errorData.message);
            }
            
        });
        $A.enqueueAction(action); 
    },
    
    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {

        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one profile picture");
        }
        helper.readFile(component, helper, files[0]);
    },

    deletePicture: function(component, event, helper) {
        helper.delete(component);
    }
    
})
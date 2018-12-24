({
    // Load current profile picture.
    onInit: function(component) {
        let action = component.get("c.getProfilePicture");
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            let state = response.getState();

            if (state == "SUCCESS") {
                let image = response.getReturnValue();

                if (image != null && image.Id != null) {
                    component.set("v.image", '/sfc/servlet.shepherd/version/download/' + image.Id);
                    component.set("v.message", "");
                    component.set("v.renderDelete", true);
                }
            } else if (state == "ERROR") {
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Error',
                     type: 'error',
                     message: errors[0].message
                });
                toastEvent.fire();
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
        let files = event.dataTransfer.files;

        if (files.length > 1) {
            return alert("You can only upload one profile picture");
        }

        helper.readFile(component, files[0]);
    },

    deletePicture: function(component, event, helper) {
        helper.delete(component);
    }

})
({
    readFile: function(component, file) {
        if (!file) return;

        if (!file.type.match(/(image.*)/)) {
            return alert('Image file not supported');
        }

        let self = this;
        let reader = new FileReader();
        reader.onloadend = function() {
            let dataURL = reader.result;
            component.set("v.image", dataURL);
            self.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
    },

    upload: function(component, file, base64Data) {
        let action = component.get("c.saveFile");
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data,
            contentType: file.type
        });
        action.setCallback(this, function(response) {
            let state = response.getState();

            if (state == "SUCCESS") {
                component.set("v.renderDelete", true);
                component.set("v.message", "Image uploaded");
            } else if (state == "ERROR") {
                this.errorToast(response.getError()[0].message);
            }
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action);
    },

    delete: function(component) {
        let action = component.get("c.deleteFile");
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            let state = response.getState();

            if (state == "SUCCESS") {
                component.set("v.renderDelete", false);
                component.set("v.image", "https://i.imgur.com/1RM15yn.jpg");
                component.set("v.message", "Image deleted");
            }

            if (state == "ERROR") {
                this.errorToast(response.getError()[0].message);
            }

        });
        $A.enqueueAction(action);
    },

    errorToast: function(message){
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Error',
            type: 'error',
            message: message
            });
        toastEvent.fire();
    }

})
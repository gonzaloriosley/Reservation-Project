HTMLContainer = document.getElementById("controlAddIn");

HTMLContainer.insertAdjacentHTML('beforeend',
    '<div id="myDiv" style="width=100%; height=772px"></div>');

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlReady", []);
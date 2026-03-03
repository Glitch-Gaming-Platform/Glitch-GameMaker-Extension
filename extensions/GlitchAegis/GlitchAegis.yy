{
  "optionsFile": "options.json",
  "options": [
    {"name":"title_id","type":2,"value":"","description":"The UUID of your game title from the Glitch Dashboard","resourceType":"GMExtensionOption",},
    {"name":"title_token","type":2,"value":"","description":"The Title Token generated in the Technical Integration tab","resourceType":"GMExtensionOption",}
  ],
  "exportToGame": true,
  "supportedTargets": -1,
  "extensionVersion": "1.0.0",
  "files": [
    {
      "filename": "glitch_aegis.gml",
      "kind": 2,
      "functions": [
        {"name":"glitch_init","externalName":"glitch_init","kind":2,"help":"glitch_init()","returnType":2,"argCount":0,"args":[],"resourceType":"GMExtensionFunction",},
        {"name":"glitch_send_heartbeat","externalName":"glitch_send_heartbeat","kind":2,"help":"glitch_send_heartbeat()","returnType":2,"argCount":0,"args":[],"resourceType":"GMExtensionFunction",},
        {"name":"glitch_validate_license","externalName":"glitch_validate_license","kind":2,"help":"glitch_validate_license()","returnType":2,"argCount":0,"args":[],"resourceType":"GMExtensionFunction",},
        {"name":"glitch_track_event","externalName":"glitch_track_event","kind":2,"help":"glitch_track_event(step_key, action_key)","returnType":2,"argCount":2,"args":[1,1],"resourceType":"GMExtensionFunction",}
      ],
      "resourceType": "GMExtensionFile"
    },
    {
      "filename": "glitch_bridge.js",
      "kind": 5,
      "functions": [
        {"name":"glitch_js_get_url_param","externalName":"glitch_js_get_url_param","kind":5,"help":"","returnType":1,"argCount":1,"args":[1],"resourceType":"GMExtensionFunction",}
      ],
      "resourceType": "GMExtensionFile"
    }
  ],
  "parent": {
    "name": "Extensions",
    "path": "folders/Extensions.yy",
  },
  "resourceVersion": "1.2",
  "name": "GlitchAegis",
  "resourceType": "GMExtension",
}

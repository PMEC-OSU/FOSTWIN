# FOSTWIN Digital Twin

Welcome to the open source FOSWEC (Floating Oscillating Surge Wave Energy Converter) digital twin project.  To learn more about FOSWEC devices and digital twin modeling, please check out these resources: [SNL](https://energy.sandia.gov/foswec-testing-helps-validate-open-source-modeling-code/) & [OSU](https://wave.oregonstate.edu/).

![](./images/topLevel.png)

# Getting Started
In order to develop a control model and test it's realtime operation and behavior through the FOSTWIN web interface, we recommend you read through this readme first.  Then clone this repo and you're ready to start developing your controller for the FOSTWIN digital twin! 

If you're more interested in using the default control model and learning about FOSWEC systems through the web interface, we recommend you read through [this](./DigitalTwins.md) readme to get familiar with the digital twin(s) you'll be controlling.

## Controller
To develop a controller for the FOSTWIN digital twin, we've included a nearly blank model called **CONTROLLER_STARTER.slx**, that we highly recommend you start out with.  This nearly blank controller simply has the required inports and outports to allow it to be dropped into the Top Level model. Without the correct number of inports and outports (as defined in the starter model), the uploaded control model will not be able to be used through the web platform. Here's what it looks like in Simulink:

![](./images/controller_starter.png)

As you can see, the starter has no actual control built in, further the position values from the flaps simulated in the digital twin are routed directly to the current output that is fed back into the digital twin model and wouldn't be good to use as is. If your controller doesn't have any parameters that would need to be updated when starting (or restarting) a simulation, or wouldn't need to be changed while the simulation is running, just terminate the inports and don't connect the outports to any wires in your controller model.  

We've also provided a **defaultCtrlModel.slx** that creates a simple damping control system, this model may be helpful to examine to get get 

![](./images/default.png)

## Control Params?

While there is absolutely no requirement to manually change parameters within the control model (default or the one you create), the web interface allows for changing control parameters (and wave height if using systemID as the twin) while the model is being ran on the (Speedgoat)[https://www.speedgoat.com/speedgoat-solutions?utm_term=&utm_campaign=Dynamic+Ad+Groups&utm_source=adwords&utm_medium=ppc&hsa_acc=6520550235&hsa_cam=887795487&hsa_grp=43284490926&hsa_ad=208143357041&hsa_src=g&hsa_tgt=aud-387379185812:dsa-295317350131&hsa_kw=&hsa_mt=b&hsa_net=adwords&hsa_ver=3&gclid=EAIaIQobChMIiNj__c3F8wIVBQutBh1JvQioEAAYAiAAEgJZsfD_BwE] in a realtime simulation, so this version of the project allows the same behavior.  Looking at the **defaultCtrlModel.slx** may help make this more clear.  In the image from above of the **defaultCtrlModel.slx**, note that the inports (Control_Param1 & Control_Param2) are routed into a multiplication block tied to the velocity calculated from the position data from the twin.  These multiplication blocks are a replacement for a gain block that would represent the damping force applied to the motor, and we can change this damping force while a simulation is running via changing the parameter fed into the control model from the constant block shown in the top level model.

Via the web platform, we have incorporated a UDP system that takes in the commands from the web UI, converts them from bytes to the appropriate data type, and feeds them into the control model selected (Default or an uploaded model you've created).  If you're running the model locally in non-realtime mode (**CURRENTLY NOT OPERATIONAL**), the control parameters still need to be initialized the same way, however changing during runtime isn't available.  If you're running the model in a realtime environment on your own Speedgoat, we've provided a ```ctrl()``` matlab function that wraps the ```target.setparam()``` Simulink realtime functionality.  Here's an example of how to use it from the matlab prompt:

```C++
>> initModels_GUI (initializes everything)
>> starttarget
>> ctrl('param1', 15)
>> ctrl('waveH', 2)
...
```

If you'd prefer to run the command yourself, here is what the ```ctrl()``` function does (you'd run the pTg.setparam() line manually):

```C++
function [error] = ctrl(portName, value)
%CTRL - wrapper to set params while running a realtime simulation

error = "";
pTopModelName = evalin('base','pTopModelName');
pTg = evalin('base','pTg');
allowed_ports = ['param1' 'param2' 'param3' 'param4' 'waveH'];

if ismember(portName, allowed_ports) == 0
   error = sprintf('portName argument not accepted.\nExpected: param1, param2, param3, param4, waveH\nRecieved: %s', portName);
   return
end

try 
    pTg.setparam([pTopModelName, '/', portName], 'Value', value);
catch e
    error = e;
end

end
```





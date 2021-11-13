# FOSTWIN Digital Twin

<img style="height:300px;float:right;margin-bottom:10px;" src="images/FOSWEC2_HWRL.png">

- [FOSTWIN Digital Twin](#fostwin-digital-twin)
- [Getting Started](#getting-started)
  - [Purpose](#purpose)
      - [New Users](#new-users)
      - [Experienced Users](#experienced-users)
- [Using the Web Interface](#using-the-web-interface)
  - [Compilation](#compilation)
  - [Control Parameters](#control-parameters)
  - [Model Upload](#model-upload)
  - [Start/ Stop FOSTWIN](#start-stop-fostwin)
  - [Prepare & Download Data (and data definitions)](#prepare--download-data-and-data-definitions)
  - [Finished With System](#finished-with-system)
  - [Edit Control Display](#edit-control-display)
- [Developing A Controller](#developing-a-controller)
  - [Control Parameters](#control-parameters-1)
  


# Getting Started
## Purpose

In a joint effort between [SNL](https://energy.sandia.gov/foswec-testing-helps-validate-open-source-modeling-code/), [OSU](https://wave.oregonstate.edu/), and [Evergreen Innovations (EGI)](https://www.evergreeninnovations.co/speedgoat-simulink-rt-services/), we present this open source repository and a web based platform allowing MATLAB & Simulink developers to interact with a Digital Twin of a Floating Oscillating Surge Wave Energy Device (FOSWEC).  Information about the FOSWEC device being simulated in the Digital Twins included in this repo and the web interface can be found [here](./DigitalTwins.md).

The web based platform aims to serve a mix of different users with varying experience and dynamics modeling skill levels, from someone who wants to get familiar with realtime Digital Twin simulations to someone who has access to the realtime Simulink toolboxes and wants to test their custom controller model but doesn't have the realtime [Speedgoat](https://www.speedgoat.com/speedgoat-solutions?utm_term=&utm_campaign=Dynamic+Ad+Groups&utm_source=adwords&utm_medium=ppc&hsa_acc=6520550235&hsa_cam=887795487&hsa_grp=43284490926&hsa_ad=208143357041&hsa_src=g&hsa_tgt=aud-387379185812:dsa-295317350131&hsa_kw=&hsa_mt=b&hsa_net=adwords&hsa_ver=3&gclid=EAIaIQobChMIiNj__c3F8wIVBQutBh1JvQioEAAYAiAAEgJZsfD_BwE) hardware.

#### New Users

If you're someone who is wanting to get familiar with the idea of realtime simulations, FOSWEC's, and digital twins, read the section [below](#using-the-web-interface), skip the model upload, and select **Default Control** in the compilation option box in the web UI.  We'd also recommend you read through [this](./DigitalTwins.md) readme to get a baseline understanding about what's happening in the digital twins.

#### Experienced Users

If you're up to speed with the web interface and are ready to work on developing your own Controller model, we recommend you skip to to [Developing A Controller](#developing-a-controller) & read [this](./DigitalTwins.md) digital twin readme.  

# Using the Web Interface

## Compilation

![](images/compilation.png)

The options shown in this box are all parameters in the models that cannot be changed without recompiling the code that is executed on the speedgoat hardware.  In order to change any of these options, you must stop any running simulation, then press the "Start Compilation!" button. You will first be met with a success/ failure message that will pop up in the compilation options box, then as the project compiles the Compilation Report box directly to the right of the options will start to output information about the options selected, then information about the compilation itself. 

**COMPILATION COMPLETE WILL BE RENDERED AT THE END OF THE COMPILATION REPORT INDICATING THE SYSTEM IS READY TO BE STARTED**

## Control Parameters

![](images/ctrlparams.png)

**WHEN "START FOSTWIN" IS PRESSED, THE INITIAL VALUES FOR THE CONTROL PARAMETER VALUES ARE TAKEN FROM THESE SLIDERS**

The **Default Control** option built into the system has the ability to change the damping forces that are applied to the simulated motor torque shaft *while* the simulation is running, this is a unique benefit to running a simulation in realtime.  Try increasing or decreasing the damping, then watching the power, current, and position charts change in the UI.

While these values are able to be changed in realtime, when you start a simulation, these values need to be initialized to some starting value.  When you press the start simulation button, the values shown on the sliders (or spinners) are set as the starting values for the Aft and Bow Damping.  **There is absolutely no requirement to change parameters during a simulation but it's available if you want to!**

You'll likely note that "Param3" and "Param4" don't have a unique name and are set to 0 by default, this is because we've built the system to allow for a custom controller to be uploaded into the system, where it could also have parameters that can be changed during the running simulation.  We currently allow for four input parameters to the controller model, again with no requirement to use them, so these "Param3" and "Param4" sliders have no effect on the Default Control model, but are there to allow for the ability to control models with more complex input parameters.  More information about the control parameters and uploading a custom controller is [here](#developing-a-controller).

## Model Upload


## Start/ Stop FOSTWIN


## Prepare & Download Data (and data definitions)

## Finished With System


## Edit Control Display

![](images/editctrldisp.png)

Wen you click the "Edit Control Display" button, you'll be met with the options above.  The purpose here is to make the UI reflect your custom controller.  The Signal names across the top row will update the labels on the very bottom chart on in the UI.  This chart is configured to show any data set up in your uploaded control model that is sent to one of the four available outputs.  This is simply to improve your experience and can be totally skipped if you're fine with the shown names.  

The Param options for the rest of the dialogue box are just for setting names, ranges, and types for the control options.  We have it pre-populated with realistic ranges and correct names if "Default Control" is selected in the compilation options.  The Type is either a range (slider) or a spinner (a numeric input with up and down arrows to increment the value).  

**The primary difference between range and spinner is a spinner sends the param when "set param" button is pressed, and the sliders set the param and send it to the speedgoat when the slider is released.**

**Pressing "Update" button will refresh the page.**



# Developing A Controller

To develop a controller for the FOSTWIN digital twin, we've included a nearly blank model called **CONTROLLER_STARTER.slx**, that we highly recommend you start out with.  This nearly blank controller simply has the required inports and outports to allow it to be dropped into the Top Level model. Without the correct number of inports and outports (as defined in the starter model), the uploaded control model will not be able to be used through the web platform. Here's what it looks like in Simulink:

![](/images/controller_starter.PNG)

As you can see, the starter has no actual control built in, further the position values from the flaps simulated in the digital twin are routed directly to the current output that is fed back into the digital twin model and wouldn't be good to use as is. If your controller doesn't have any parameters that would need to be updated when starting (or restarting) a simulation, or wouldn't need to be changed while the simulation is running, just terminate the inports and don't connect the outports to any wires in your controller model.  

We've also provided a **defaultCtrlModel.slx** that creates a simple damping control system, this model may be helpful to examine to get familiar with using the inports for control parameters and outports for logging data signals. 

![](/images/default.PNG)

## Control Parameters

While there is absolutely no requirement to manually change parameters within the control model (default or the one you create), the web interface allows for changing control parameters (and wave height if using systemID as the twin) while the model is being ran on the [Speedgoat](https://www.speedgoat.com/speedgoat-solutions?utm_term=&utm_campaign=Dynamic+Ad+Groups&utm_source=adwords&utm_medium=ppc&hsa_acc=6520550235&hsa_cam=887795487&hsa_grp=43284490926&hsa_ad=208143357041&hsa_src=g&hsa_tgt=aud-387379185812:dsa-295317350131&hsa_kw=&hsa_mt=b&hsa_net=adwords&hsa_ver=3&gclid=EAIaIQobChMIiNj__c3F8wIVBQutBh1JvQioEAAYAiAAEgJZsfD_BwE) in a realtime simulation, so this version of the project allows the same behavior.  Looking at the **defaultCtrlModel.slx** may help make this more clear.  In the image from above of the **defaultCtrlModel.slx**, note that the inports (Control_Param1 & Control_Param2) are routed into a multiplication block tied to the velocity calculated from the position data from the twin.  These multiplication blocks are a replacement for a gain block that would represent the damping force applied to the motor, and we can change this damping force while a simulation is running via changing the parameter fed into the control model from the constant block shown in the top level model.

Via the web platform, we have incorporated a UDP system that takes in the commands from the web UI, converts them from bytes to the appropriate data type, and feeds them into the control model selected (Default or an uploaded model you've created).  If you're running the model locally in non-realtime mode, the control parameters still need to be initialized the same way, however changing during runtime isn't available.  If you're running the model in a realtime environment on your own Speedgoat, we've provided a ```ctrl()``` matlab function that wraps the ```target.setparam()``` Simulink realtime functionality.  Here's an example of how to use it from the matlab prompt:

```C++
>> initModels_GUI
>> starttarget
>> ctrl('param1', 15)
>> ctrl('waveH', 2)
>> stoptarget 
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





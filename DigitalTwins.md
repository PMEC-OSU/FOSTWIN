# Digital Twin Description

This document outlines the FOSWEC digital twin implementations with the intent of giving a look into the operation of the code behind the models.  

### Interaction
There are currently three ways to interact with the digital twin code:
- The first is to run the model through a dashboard running in real-time on Speedgoat hardware [here](https://fostwin.evergreeninnovations.co/login).
- The second is to download and run locally a non-realtime version of the Digital Twin located [here](https://github.com/PMEC-OSU/FOSTWIN).
- The third is to download and run locally a realtime version of the Digital Twin located [here](https://github.com/PMEC-OSU/FOSTWIN) with Speedgoat hardware.

### Model types

Fundamentally there are two Digital Twin models of the FOSWEC to choose from:  
- The first is based on the open source code [WEC-Sim](https://wec-sim.github.io/WEC-Sim/master/index.html).  
- The second is a system identification model based on experimental data collected from the actual FOSWEC device during a test campaign at OSU detailed [here](https://dx.doi.org/10.15473/1782587).  Further information from this test campaign can be found in the paper located [here](https://doi.org/10.1016/j.energy.2021.122485).

### Model overview
Each version of the Digital Twin includes the plant model and a control model.  The plant model is intended to be fixed, however the control model is meant to be experimented with.  There is a default control model to get started with but it is possible for this model to be replaced with a custom control model by the user.

### Wave types
Currently there are provisions for running regular and irregular wave conditions.  Irregular waves have a JONSWAP spectrum input.

## Control Model

Two version of control model are given, namely a default model and a starter model.  Either the default or starter model can be modified for the users application.
### Inputs and outputs
The control model has the following inputs and outputs available to the user:
- Inputs: Flap position relative to the platform for both bow and aft flaps
- Outputs: Current command to be sent to the motor drive for both bow and aft flaps

Additionally, input control parameters can be specified by the user.  For example, the default control has damping for each flap as control parameters.
### Default control model
The default control model implements basic velocity proportional damping.
![](/images/defaultCtrlModel.png)
### Starter control model
This is a minimum starting model with a default set of inputs and outputs that serves as a starting point for control algorithm implementation.
![](/images/CONTROL_STARTER.png)
## WEC-Sim model
The WEC-Sim model uses a simplified geometry and WAMIT output to provide a time domain model of the FOSWEC.  The simulation is set up to replicate the test conditions experienced during testing at the O.H. Hinsdale Wave Research Laboratory.  This includes matching the water depth and mooring, which was a taut system.
![](/images/FOSWEC_v2.png)
## System identification model
The system identification model is based off of experimental test data collected by the FOSWEC at the O.H. Hinsdale Wave Research Laboratory.  System identification techniques from MATLAB were used to establish a multiple input multiple output (MIMO) admittance model of the system.  Input is the motor torque and output is motor position.  
![](/images/systemID.png)

Wave input is created by taking wave characteristics and using the results from WAMIT to create an excitaion force input for the model.



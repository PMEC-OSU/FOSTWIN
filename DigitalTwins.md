# Digital Twin Description

This document outlines the FOSWEC digital twin implementations with the intent of giving a look into the operation if the code behind the models.  

### Interaction
There are currently two ways to interact with the digital twin code:
- The first is to download and run locally a non-realtime version of the Digital Twin located [here](https://github.com/PMEC-OSU/FOSTWIN).
- The second is to run the model through a dashboard running in real-time on Speedgoat hardware [here](https://fostwin.evergreeninnovations.co/login).

### Model types

Fundamentally there are two Digital Twin models of the FOSWEC to choose from:  
- The first is based on the open source code [WEC-Sim](https://wec-sim.github.io/WEC-Sim/master/index.html).  
- The second is based on experimental data collected from the actual FOSWEC device during a test campaign at OSU detailed [here](https://www.osti.gov/biblio/1717884-foswec-dynamics-controls-test-report).

### Model overview
Each version of the Digital Twin includes the plant model and a control model.  The plant model is intended to be fixed, however the control model is meant to be experimented with.  There is a default control model to get started with but the intention is this will be replaced with a custom control model by the user.

### Wave types
Currently there are provisions for running regular and irregular wave conditions.  Irregular waves are a JONSWAP spectrum input.

## Control Model

Two version of control model are given, namely a default model and a starter model.  Either the default or starter model can be modified for the users application.
### Inputs and outputs
The control model has the following inputs and outputs available to the user:
- Inputs: Flap position relative to the platform for both bow and aft flaps
- Outputs: Current command to be sent to the motor drive for both bow and aft flaps

Additionally, input control parameters can be specified by the user.
### Default control model
The default control model implements basic velocity proportional damping, and outputs a calculated power for each time step. A CONTROL_STARTER model is provided to have a starting point for creating your own control model.
![](/images/defaultCtrlModel.png)
### Starter control model
This is a blank model with a default set of inputs and outputs that serves as a starting point for control algorithm implementation.
![](/images/CONTROL_STARTER.png)
## WEC-Sim model
The WEC-Sim model uses a simplified geometry and WAMIT output to provide a time domain model of the FOSWEC.  The simulation is set up to replicate the test conditions experienced during testing at the O.H. Hinsdale Wave Research Laboratory.  This includes matching the water depth and mooring, which was a taut system.
![](/images/FOSWEC_v2.png)
## System identification model
The system identification model is based off of experimental test data collected by the FOSWEC at the O.H. Hinsdale Wave Research Laboratory.  System identification techniques from MATLAB were used to establish a multiple input multiple output (MIMO) admittance model of the system.  Input is the motor torque and output is motor position.  
![](/images/systemID.png)

Wave input is achieved by generating a wave surface elevation time series, then using results from WAMIT to create an associated excitation force time series.



# Digital Twin Description

This document outlines the FOSWEC digital twin implementations with the intent of giving a look into the operation if the code behind the models.  

There are currently two ways to interact with the digital twin code:
- The first is to download and run locally a non-realtime version of the Digital Twin located [here](https://github.com/PMEC-OSU/FOSTWIN).
- The second is to run the model through a dashboard running in real-time on Speedgoat hardware [here](https://fostwin.evergreeninnovations.co/login).


Fundamentally there are two Digital Twin models of the FOSWEC to choose from:  
- The first is based on the open source code [WEC-Sim](https://wec-sim.github.io/WEC-Sim/master/index.html).  
- The second is based on experimental data collected from the actual FOSWEC device during a test campaign at OSU detailed [here](https://www.osti.gov/biblio/1717884-foswec-dynamics-controls-test-report).

Each version of the Digital Twin includes the plant model and a control model.  The plant model is intended to be fixed, however the control model is meant to be experimented with.  There is a default control model to get started with but the intention is this will be replaced with a custom control model.


## Control Model

The control model has the following inputs and outputs available to the user:

- Inputs: Flap position relative to the platform for both bow and aft flaps
- Outputs: Current command to be sent to the motor drive for both bow and aft flaps

Additionally, input control parameters can be specified by the user.

The default control model implements basic velocity proportional damping, and outputs a calculated power for each time step. A CONTROL_STARTER model is provided to have a starting point for creating your own control model.

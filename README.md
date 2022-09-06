# FOSTWIN Digital Twin <!-- omit in toc -->

<img style="height:350px;margin-bottom:10px;" src="images/FOSWEC2_HWRL.png" align="right">

- [Overview](#overview)
- [Control competition](#control-competition)
- [Participate in competition](#participate-in-competition)
- [Top level model](#top-level-model)
- [Running the FOSTWIN locally](#running-the-fostwin-locally)
- [Developing a custom controller](#developing-a-custom-controller)
- [Web interface](#web-interface)
- [Digital twin description](#digital-twin-description)
  - [Control model](#control-model)
  - [WEC-Sim model](#wec-sim-model)
  - [System identification model](#system-identification-model)


# Overview

In a joint effort between [Sandia National Labs (SNL)](https://energy.sandia.gov/foswec-testing-helps-validate-open-source-modeling-code/), [Oregon State University (OSU)](https://wave.oregonstate.edu/), and [Evergreen Innovations (EGI)](https://www.evergreeninnovations.co), we present this open source repository to interact with a digital twin of the Floating Oscillating Surge Wave Energy Device (FOSWEC). This repository is complemented by a web-based platform that gives simple and convenient access to the tools provided here. A video tutorial of how to use this web interface can be found [here](https://digitalops.sandia.gov/Mediasite/Play/5ac7786567ef4e7fa6f77b385a2781ef1d). 

If you would like more information about the FOSWEC device please check out the following resources.
- https://dx.doi.org/10.15473/1782587
- https://doi.org/10.1016/j.energy.2021.122485

From here onwards, we will refer to the digital twin of the FOSWEC as the FOSTWIN.

# Control competition
For information on the timeline of a currently on-going control competition and the reward, please take a look [here](https://pmec-osu.github.io/FOSTWIN/).

## Rules
The following rules apply to the control competition:
- Use of System Identification (SID) digital twin model only (not WECSim)
- Must use provided SID admittance (includes drive train dynamics)
- No changes to be made outside of the control model (FOSTWIN/ctrl/userCtrlModel block)
- Must be able to run the entire model (including control) in real-time at 1kHz loop rate on our provided Speegoat Baseline target machine
- Optimize net (mechanical - I2R winding loss) power capture for a JONSWAP (gamma=3.3) sea state with Hs of 0.136 m and Tp of 2.61s for a 300s simulation time
- Irregular waves seeded with 'default' for the random number generator must be used. In scoring the results, we will evaluate with 5 additional seeds unknown to the developer

If you require any clarification, please email johannes@evergreeninnovations.co.

## Scoring

The following scoring criteria will be evaluated in the order listed, where the subsequent criteria will only be used to determine the winner(s) if there are ties:

1. Mean of net (mechanical - I2R loss) power across the sea states as calculated in the provided SID model
2. Peak-to-mean ratio of the net power - a lower ratio provides a higher score
3. Total Harmonic Distortion (THD) of the aft and bow current signals
4. Computational time


# Participate in competition

1. Create an account [here](https://fostwin-signup.evergreeninnovations.co/)
2. You will be emailed a link to create a password, providing access to a dashboard where you can select dates to use our provided real-time Speedgoat system
3. Select up to 10 dates at a time (10 active dates, once a day has passed you're able to schedule more time on the system as needed)
4. Clone this repository
5. Get familiar with the models and optionally start with the ctrlStarter.slx file provided
6. Develop your custom controller locally. Most developers will do so in non-realtime mode. However, the various Matlab scripts are set up to work with realtime Speedgoat hardware if you have access to one
7. On one of the dates you scheduled in Step 3, login to the system, upload your model, set to competition mode, compile, and confirm that your controller can operate at 1 kHz loop rate on a baseline Speedgoat target. 
   1. Optionally while running your model, test changing control parameters (if your model has any) to optimize the power output over a 300 s simulation. 
8. Once satisfied, email your controller and your optimized control parameters (if relevant) to johannes@evergreeninnovations.co by **June 16th 2023** 
9. If your controller is within the top 5 submissions, you'll be emailed with your results and we will arrange for up to $2,000 in travel reimbursement to attend the MASK Basin Workshop in September 2023.

## Scheduling times

When you enroll in the competition, you are first presented with a dashboard to select dates to use the system.  When you select a given date, you have reserved that date from 00:00:00 -> 23:59:59 in `US/Central` time (Midnight to Midnight).

1. When your turn on the system has arrived, the date scheduling dashboard's "To FOSTWIN Dashboard" button will become enabled, and clicking it will take you to the web interface described in the following sub-sections.  
2. At about 10 minutes prior to the end of your scheduled time an alert will be raised from the website.  At this point, you should stop your simulation and download your data.
3. At about 5 minutes prior to the end of your scheduled time, the system will be automatically stopped, then reset. This means any non-saved simulation data will be lost.
4. At the end of your turn, you will be redirected to the date selection dashboard where you can schedule more time on the system if desired.
   
**Note**: When your turn arrives, the `STATUS` box in the middle of the FOSTWIN dashboard (with TET and Speedgoat info underneath) should say `System Not In Use`. If this is not the case, please press the `Finished With System` button to reset the system.  

# Running the FOSTWIN locally
To run the FOSTWIN locally, follow these steps:
1. Clone the FOSTWIN repository [here](https://github.com/PMEC-OSU/FOSTWIN) (this repo).
2. OPTIONAL STEPS IF WANTING TO RUN THE WECSIM TWIN LOCALLY (you can skip this step for the SID version):  
   1. Install version 5.0 of [WEC-Sim](https://github.com/WEC-Sim/WEC-Sim/releases). This is the only version currently supported.
3. Modify `initModels_GUI.m` in the FOSTWIN repository as desired:
   - Choose simulation type either `NonRealTime` or `SingleSpeedgoat`
   - Set wave height and wave periods for your simulation
   - Set initial values for inputs to your control model
   - Set simulation stop time
   - Set wave type of `regular` or `irregular`
   - Specify the control model name
   - Choose either the `WECSim` or `systemID` TWIN model
   - If using a Speedgoat for realtime simulation, set the name of your target device
   - IF OPTIONAL WECSIM STEP COMPLETED ABOVE: 
     - Change `wecSimPath` near the top of the `initModels_GUI` script to reflect the source directory of your installed WEC-Sim installation
     - When running WECSim as the twin for the first time locally, uncomment the `modifyWECSim_Lib_Frames` line of the `initModels_GUI` script.
4. Run `initModels_GUI.m` to get started
5. Results of the simulation are saved to simulation-data.mat in the non-realtime environment.

# Top Level Model
The top level model is where the controller and the FOSTWIN model simulation are joined:
![](images/FOSTWIN.png)

# Developing a custom controller

We recommend you start with the controller template model `ctrlStarter.slx`. The `ctrlStarter.slx` model has no actual control built in, but defines all relevant controller input and output bus structures. This includes up to four parameters that can be tuned live via the web-based system. If your controller does not have any (or fewer than four) tunable parameters, simply terminate the unused parameters.

![](/images/ctrlStarter.png)

We have also provided a `defaultCtrlModel` that creates a simple velocity proportional damping control system. This model may be helpful to get familiar with using the controller inputs (aft and bow flap positions), the control parameters, and the outputs for logging of data signals. 

![](/images/defaultCtrl.png)

### Tunable control parameters

The web interface allows for changing some control parameters while the model is being run on the real-time Speedgoat system. An example of tunable parameters are the aft and bow damping applied in the `defaultCtrlModel`. Varying these parameters, which are mapped to `ctrlParam1` and `ctrlParam2`, allows manipulating the damping force applied to the motor as the simulation is running. This feature can be used to develop a first quick sense for where the optimum damping values may lie. 

### Control signals 

On the right-hand side of the `defaultCtrlModel` and `ctrlStarter` models, you will see that there are always 2 outputs. One of these output busses is essential for the interaction between the controller and the twin, containing the motor current setpoints `curAft` and `curBow`. The second output bus is used for logging and sending data to the charts on the web interface.

There is no requirement to make use of the extra `ctrlSignals` output bus; these signals are informational only. However, this bus must still exist to successfully compile the controller when running via the web interface. The four bus signals are returned in the full resolution data, and populate the very bottom chart on the web platform. Using the [Edit Control Display](#edit-control-display) button, you can rename the signals on the chart to make interpreting the data easier. If not making use of the four informational control signals, we recommend wiring a constant 0 block to suppress Simulink warnings.

## Controller State

The model contains a supervisory state machine. This state machines ensures that maximum current constraints are not violated and catches controller instabilities.

![](images/stateCtrl.png)

There are 6 states in this state machine:
1. Undefined - a non-state to handle edge cases
2. Init - starting point 
3. Normal - main absorption controller operating without issues
4. Stabilizing - stabilize the system after an excessive motor current
5. Safe Damping - safe condition, where the absorption control is taken over by a default (and known to be stable) damping controller
6. Fault - absorption controller deactivated

The state machine operation is shown in the Simulink State Flow chart below. The system generally remains in the Normal state, unless a large motor current signal is detected. This detection is based on a low-pass filtered version of the instantaneous current, such that a very short current spike does not trigger an error condition. If an excessive current signal is detected, the state machine seeks to stabilize the system and return to the Normal operating state. Continued violation of the motor current limit will trigger the Fault state, where the absorption controller remains deactivated.

![](images/stateCtrlChart.png)


# Web Interface

Google chrome is the the recommended browser for best performance. If it is difficult to see everything inside of the boxes in the web interface, please zoom out to improve the visual quality.  

### Power signs

For mechanical power, power absorbed from the waves is negative. Electrical losses (I2R) are always positive. The net power is the sum of the mechanical power and the I2R losses. A negative net power means net power is being absorbed from the waves. A positive net power means the I2R losses outweigh the absorbed wave power. For the competition, optimizing net power means obtaining a **maximum negative value** of the net power mean over the sea state.

### Compilation

The options shown in the below box are all parameters that cannot be changed without recompiling the code that is executed on the Speedgoat hardware. To change any of these options, stop any running simulation, and then press the `Start Compilation!` button. As the project compiles, the Compilation Report box directly to the right of the options will start to output compilation information. Depending on the length of simulation requested, this compilations could take a few minutes.

![](images/compilation.png)

**COMPILATION COMPLETE WILL BE RENDERED AT THE END OF THE COMPILATION REPORT INDICATING THE SYSTEM IS READY TO BE STARTED**

Checking the `Set To Competition Mode` box simply changes the `Twin Type` to `SystemID`, and sets the wave conditions as defined above in the [competition rules](#rules)


### Control parameters

When `Start FOSTWIN` is pressed, the initial values for the control parameters will be taken from the relevant sliders. Our default controller uses two control parameters, the aft and the bow damping. "Param3" and "Param4" are not used for this default controller, but are available for the use in custom controllers. More information concerning the control parameters and uploading a custom controller is [here](#developing-a-controller).

![](images/ctrlparams.png)

#### Wave height

When the twin type is chosen as `SystemID`, you can change the wave height while the simulation is running. When the twin type is `WECSim`, the wave height is fixed to the value chosen at compile time. This limitation is due to the way in which the wave excitation force is calculated within `WECSim`. More information on the two twin types is provided [here](./DigitalTwins.md)

### Custom controller model upload

To upload a model, select the desired model file in the explorer and then click upload. Only .slx files are allowed. When uploading a new model, please make sure that no model is currently running or compiling. If you do not yet have a custom control model, you can simply select Default Control in the [Compilation Options](#compilation). 

![](images/upload.png)

### System control buttons
These buttons control the overal system behavior, with details given below.
![](images/systemcontrol.png)

#### Modify control display (**optional**)

The Modify Control Display button gives you the following options:
![](images/editctrldisp.png)

This diaglog allows for some UI customization, to reflect your custom controller and input option type. The Signal names across the top row update the labels on the very bottom chart in the UI. This chart is configured to show any data set up in your uploaded control model that is sent to one of the four available outputs. 

The Param options for the rest of the dialogue box are for setting names, ranges (min, max, step), and types for the control options.  These are pre-populated with realistic ranges and correct names if "Default Control" is selected in the compilation options. The Type is either a range (slider) or a spinner (a numeric input with up and down arrows to increment the value). The spinner updates the param when "set param" button is pressed. The sliders update the param when the slider is released.

Pressing the "Update" button will save your changes and refresh the main page.

#### Start/ Stop FOSTWIN

These buttons start and stop the realtime simulation on the Speedgoat real-time. The Stop button allows you to terminate the simulation before the allocated run time. Note that you can only prepare and download data once the simulation is completed, either after the full run time, or until the Stop button was pressed.

#### Prepare & Download Data (and data definitions)

Pressing this button prepares high temporal resolution (1 kHz for SID) data for subsequent post processing. For long simulation times, this data preparation may take a few minutes. Once complete, a .mat file will be available in your downloads.

The logged data includes:
- Power
  - `powerMechAft` - mechanical power generated on aft flap
  - `powerMechBow` - mechanical power generated on bow flap
  - `powerMechTotal` - sum of the aft and bow mechanical powers
  - `powerMechAvg` - Moving average of total mechanical power. Irregular waves are calculated across 60 waves, and regular are calculated across 5 waves. 
  - `powerI2R` - I2R loss
  - `powerNet` - `powerMechTotal` - `powerI2R`
  - `powerNetMean` - running mean of `powerNet` - at the end of the simulation, the last value is the mean calc across the simulation duration.  At each step in the simulation, the num samples denominator is incremented by 1, such that the avg at the start of the simulation is valid for the number of time steps passed.
  - `powerNetMovingAverage` - Moving average of `powerNet` - Irregular waves are calculated across 60 waves, and regular are calculated across 5 waves.
- Conditions
  - `wave` - height (H) and period (T) of the waves simulated
  - `waveType` - regular or irregular
  - `Ts` - time step - the rate at witch the Speedgoat executes every step.
  - `simulationType` - SingleSpeedgoat or NonRealtime
- Control Signals
  - `Aft` - Position and current (signals passed between controller and twin)
  - `Bow` - Position and current (signals passed between controller and twin)
  - `ctrlSignals` - 1 through 4 for the 4 custom outputs of the control model (default or custom upload)
  - `ctrlParams` - 1 through 4 for the 4 custom inputs of the control model (default or custom upload)
  - `state` - State values from ctl state machine
  - `waveH_rt` - waveH values across simulation - can be changed in realtime mode with `systemID` twin

When running locally, the custom output from WECsim is also available, and will be included under a `WECSim` key in the logged data object.  When running through the web interface, only the above signals in our custom logging system are available.

Both Power and Control Signals data have one point for every time step of the simulation, while the conditions are constant values defined at the start of the simulation.

#### Finished with system

This button only needs to be pressed once when you are ready to sign out of the system. This button resets the remote host machine to be ready for the next user. Note that this button clears all data from the host machine, including any simulation data you have not yet downloaded.

### Ocean Scale

We have used an indicative scale of 1:33 to scale up the tank-scale wave parameters. This may be helpful for developers more familiar with ocean-scale design values. These ocean-scale values are not used anywhere in the simulation and are for guidance only. 

# Digital twin description

This section of the document briefly outlines the FOSWEC digital twin implementations.

### Model types

There are two digital twin models of the FOSWEC to choose from:  
- The first is based on the open source code [WEC-Sim](https://wec-sim.github.io/WEC-Sim/master/index.html).  
- The second is a system identification model based on experimental data collected from the actual FOSWEC device during a test campaign at OSU detailed [here](https://dx.doi.org/10.15473/1782587).  Further information from this test campaign can be found in the paper located [here](https://doi.org/10.1016/j.energy.2021.122485).

### Model overview

Each version of the digital twin includes the plant model and a control model. The plant model is intended to be fixed, however the control model is meant to be experimented with. There is a default control model to get started with. This model can easily be replaced with a custom control model by the user.

### Wave types

Currently there are provisions for running regular and irregular wave conditions.  Irregular waves have a JONSWAP spectrum input.

## WEC-Sim model

The WEC-Sim model uses a simplified geometry and WAMIT output to provide a time domain model of the FOSWEC. The simulation is set up to replicate the test conditions experienced during testing at the O.H. Hinsdale Wave Research Laboratory. This includes matching the water depth and mooring, which was a taut system.
![](/images/WECSim.png)

## System identification model

The system identification model is based off of experimental test data collected by the FOSWEC at the O.H. Hinsdale Wave Research Laboratory. System identification techniques from MATLAB were used to establish a multiple input multiple output (MIMO) admittance model of the system. Input is the motor torque and output is motor position.  
![](/images/systemID.png)

The wave input for the SID model is created by taking the wave characteristics and using the results from WAMIT to create an excitaion force input for the model.

##### Aft vs Bow

The bow flap is that facing the incoming waves first.

<img style="height:350px;margin-bottom:10px;" src="images/real-device.png" align="middle">




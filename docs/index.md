<!-- ## Mask Basin Workshop & FOSTWIN Digital Twin omit in toc -->

## The competition

Welcome to the FOSTWIN controller design competition! The purpose of this page is to outline the background, timeline, rules and scoring criteria for this competition. The key competition goal is to develop an effective power absorption controller for a digital twin of the [FOSWEC](https://energy.sandia.gov/foswec-testing-helps-validate-open-source-modeling-code/) device. The objective of this controller will be to generate the ***most net power*** while running on a ***real-time digital twin***. The net power is the absorbed mechanical power, less the winding losses in the motors. 

The competition will focus on the FOSWEC v2 device tested at the [OSU O.H. Hinsdale Wave Research Laboratory](https://engineering.oregonstate.edu/facilities/wave-lab).
The top 5 net power producing controllers will be selected based on data produced and gathered during realistic sea state simulations. The successful developers will be awarded bragging rights and up to $2,000 in travel expense reimbursement for attending the [MASK Basin](https://www.defense.gov/Multimedia/Photos/igphoto/2001207018/#:~:text=The%20Navy's%20Indoor%20Ocean%20%2D%2D,Carderock%20Division%2C%20located%20in%20Maryland.) Workshop in **September 2023**.

![](images/FOSWEC2_HWRL.png)

## Background

To foster the development of realistic real-time absorption control for wave energy, we have created the tools in this [open source repository](https://github.com/PMEC-OSU/FOSTWIN). Using these tools, a control developer (you!) can run a FOSWEC digital twin simulation and a simple power absorption controller within minutes. The developer can then design enhanced custom controllers, and test these controllers on a remote real-time Speedgoat system. This offers developers the unique opportunity to test real-time control code behavior without needing their own real-time hardware.

## Competition timeline

Please join our competition! We have made the control development system easy to use, and you can get started in as little as 30 minutes. The timeline is as follows:

| Event | Date |
|---|---|
| Competition kick off | September 06, 2022 |
| [Motion and Vibration Control (MoViC 2022)](https://ifacms-movic2022.seas.ucla.edu/home/) info session | September 7-9, 2022 |
| [OREC/UMERC+METS](https://pacificoceanenergy.org/orec/) info session | September 13-15, 2022 |
| FOSTWIN info/ Q&A webinar [Microsoft Teams](https://teams.microsoft.com/l/meetup-join/19%3ameeting_YjIyM2M0NGUtZjVlMC00NTBiLTkzNWQtNjQ3MDI4MjBiNjhl%40thread.v2/0?context=%7b%22Tid%22%3a%227ccb5a20-a303-498c-b0c1-29007381b574%22%2c%22Oid%22%3a%228a3f0be9-1cb7-43e5-abcd-cde4ba053685%22%7d)| February 6th, 2023, 9:00 AM MT | 
| Final submissions due | ~~June 16th, 2023~~ July 19th, 2023 |
| MASK Basin workshop | September 2023 |


## Goals of Competition <!-- omit in toc -->

1. Connect motivated WEC developers with industry leaders and researchers
2. Build experience with developing **real-time** controllers to produce **net power** (electrical, or other useful work) in WEC devices
3. Extend on content from the [2019 PMEC Workshop](https://www.energy.gov/eere/water/events/integrated-wec-design-theory-and-practice-workshop) (video below of PMEC Workshop) and learn about the FOSWEC device
4. Acquire knowledge about WEC modeling and simulation working with the [FOSTWIN](https://github.com/PMEC-OSU/FOSTWIN) open source repository
5. Learn from Sandia WEC experts and the NAVY about developing System Identification (SID) methods from large scale testing to improve WEC modeling
6. Deepen understanding of digital twin techniques between the [WECSim](https://wec-sim.github.io/WEC-Sim/master/index.html) and [System Identification](https://github.com/PMEC-OSU/FOSTWIN#system-identification-model) digital twins available in the interface.
 
<iframe width="560" height="315" src="https://www.youtube.com/embed/OUxbaEC2K6Y" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" style="width:100%;" allowfullscreen></iframe>

## Competition award

Everyone who participates in this competition will have the opportunity to advance their WEC modeling and controller skills through the events leading to the [competition submission date](#competition-timeline). The developers of the top 5 controllers will be awarded up to $2,000 in travel expense reimbursement to attend the [**MASK Basin workshop**](https://www.defense.gov/Multimedia/Photos/igphoto/2001207018/#:~:text=The%20Navy's%20Indoor%20Ocean%20%2D%2D,Carderock%20Division%2C%20located%20in%20Maryland.) in **September 2023**.
Through the final workshop, and the events leading up to the competition submission date, participants and awardees will meet industry leaders and WEC experts from Sandia, Oregon State University, and the NAVY (just to name a few) to grow their wave energy network.

At the workshop, the winning developers will participate in a large scale tank testing campaign of the [Sandia WaveBot](https://www.youtube.com/embed/c4npWk_-Pjk).
In doing so, the awardees will learn in-depth details about tank testing of WEC devices to validate System Identification modeling techniques.
In addition to the measurements collected and the numerical methods used in the system identification validation, the awardees will gain hands-on experience with the tools, sensors, and methodology used to measure forces exerted on and throughout the WEC.  


<iframe width="560" height="315" src="https://www.youtube.com/embed/c4npWk_-Pjk" title="YouTube video player" style="width:100%;" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Steps to participate
To participate in the competition, there are just a few steps to take:

1. Become familiar with the [FOSWEC Digital Twin](https://github.com/PMEC-OSU/FOSTWIN)
2. [Set up an account](#joining-instructions) to use our real-time capable Speedgoat environment
3. Develop a custom controller as a Simulink model & run the model in real-time through the provided web platform
4. Collect & submit your results from the real-time simulation(s)

To participate in this competition, you must have:

- A valid [MATLAB](https://www.mathworks.com/products/matlab.html) license 
- A valid [Simulink](https://www.mathworks.com/products/simulink.html) license

## Rules
The following rules apply to the control competition:
- Use the System Identification (SID) digital twin model provided [here](https://github.com/PMEC-OSU/FOSTWIN) (do NOT use the WECSim twin for the competition)
- Use the provided SID admittance (includes drive train dynamics)
- Do not make changes outside of the control model (FOSTWIN/ctrl/userCtrlModel block)
- Run the entire model (including control) in real-time at 1kHz loop rate on our provided Speedgoat Baseline target machine
- Optimize net (mechanical - I2R winding loss) power capture for a JONSWAP (gamma=3.3) sea state with Hs of 0.136 m and Tp of 2.61s for a 300s simulation time
- Use irregular waves seeded with 'default' for the random number generator. In scoring the results, we will evaluate with 5 additional seeds unknown to the developer

If you require any clarification, please email johannes@evergreeninnovations.co.

## Scoring

The following scoring criteria will be evaluated in the order listed, where the subsequent criteria will only be used to determine the winner(s) if there are ties:

1. Mean of net (mechanical - I2R loss) power across the sea states as calculated in the provided SID model
2. Peak-to-mean ratio of the net power - a lower ratio provides a higher score
3. Total Harmonic Distortion (THD) of the aft and bow current signals
4. Computational time (lower TET on the Speedgoat system provides a higher score)

## Joining instructions

1. Create an account [here](https://fostwin-signup.evergreeninnovations.co/)
2. You will be emailed a link to create a password, providing access to a dashboard where you can select dates to use our provided real-time Speedgoat system
3. Select up to 10 dates at a time (10 active dates, once a day has passed you're able to schedule more time on the system as needed)
4. Clone the [FOSTWIN repository](https://github.com/PMEC-OSU/FOSTWIN)
5. Get familiar with the models and optionally start with the ctrlStarter.slx file provided
6. Develop your custom controller. Most developers will do so in non-realtime mode (on your local PC). However, the various Matlab scripts are set up to work with realtime Speedgoat hardware if you have access to one.
7. On one of the dates you scheduled in Step 3, login to the system, upload your model, set to competition mode, compile, and confirm that your controller can operate at 1 kHz loop rate on a baseline Speedgoat target.  
8. Once you are ready, email your controller and your optimized control parameters (if relevant) to johannes@evergreeninnovations.co by **June 16th, 2023** 
9. If your controller is within the top 5 submissions, you'll be emailed with your results and we will arrange for up to $2,000 in travel expense reimbursement to attend the MASK Basin Workshop in September 2023.

You must submit your entry as two files:

- the `.mat` file containing the results of running your controller on the remote Speedgoat system (via the web-based interface)
- the `.slx` file for your controller

## Further reading

The main code repository is [here](https://github.com/PMEC-OSU/FOSTWIN).

Additional resources describing the FOSWEC device can be found here:

 - [FOSWEC v2 YouTube video](https://youtu.be/OUxbaEC2K6Y)
 - [FOSWEC v2 testing report](https://doi.org/10.2172/1717884)
 - [FOSWEC v2 journal paper](https://doi.org/10.1016/j.energy.2021.122485)


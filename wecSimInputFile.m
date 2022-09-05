%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%              FOSWEC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Simulation Data
simu=simulationClass();
simu.simMechanicsFile = 'FOSWEC_v2.slx';
simu.rampTime = 5*waveT; % use wavetime from workspace 
simu.endTime = str2double(stopTime);
simu.dt = Ts; % set same dt in simulink model
simu.mode = 'normal';
simu.explorer = 'off';
simu.domainSize = 2;
simu.cicEndTime=20;
simu.solver = 'ode4';
simu.stateSpace=1;

%% Wave Information
switch waveType
    
    case 'regular'
        waves = waveClass('regularCIC');
        try 
            waves.height = waveH; % get values set into workspace from python server
            waves.period = waveT;
        catch ME
             fprintf('\n*** Error setting wave parameters from workspace, using defaults.\n')
             fprintf('\n*** Matlab error \n %s \n\n',ME.getReport)
             waves.height = 0.136;                          % Wave Height [m]
             waves.period = 2.61;   % Wave Period [s]
        end
        
    case 'irregular'
        waves = waveClass('irregular');
        try 
            waves.height = waveH; % get values set into workspace from python server
            waves.period = waveT;
            waves.spectrumType = 'JS'; %jonswap
            waves.bem.option = 'EqualEnergy';
            waves.phaseSeed = 1;
            waves.gamma = 3.3;
        catch ME
             fprintf('\n*** Error setting wave parameters from workspace, using defaults. \n')
             fprintf('\n*** Matlab error \n %s \n\n',ME.getReport)
             waves.height = 0.136;                          % Wave Height [m]
             waves.period = 2.61;   % Wave Period [s]
             waves.spectrumType = 'JS'; %jonswap
             waves.bem.option = 'EqualEnergy';
             waves.phaseSeed = 1;
             waves.gamma = 3.3;
        end
        
    otherwise
        waves = waveClass('regularCIC');
        try 
            waves.height = waveH; % get values set into workspace from python server
            waves.period = waveT;
        catch ME
             fprintf('\n*** Error setting wave.H from workspace\n')
             fprintf('\n*** Matlab error \n %s \n\n',ME.getReport)
             waves.height = 0.136;                          % Wave Height [m]
             waves.period = 2.61;   % Wave Period [s]
        end
        
end

                                

%% Body Data
%% Body 1: Front Flap (Float 1)
body(1) = bodyClass('hydroData/foswec.h5');
body(1).geometryFile = 'geometry/flap.stl';
body(1).mass = 23.14;                       %[kg] from Exp
body(1).inertia = [1.42 1.19 1.99];    %[kg-m^2] from Exp
% pitch
body(1).linearDamping(5,5) = 4.7141;      % from forced oscillation
body(1).quadDrag.drag(5,5) = 5; %21.3757;  	% from forced oscillation

%% Body 2: Platform (Base)
body(2) = bodyClass('hydroData/foswec.h5');
body(2).geometryFile = 'geometry/platformFull.stl';
body(2).viz.color = [1 1 1];
body(2).viz.opacity = 0.25;
body(2).mass = 343;%165.5;                      %[kg]  from Exp
body(2).inertia = [37.88 29.63 53.61]; %[kg-m^2] from Exp
% % heave
% body(2).linearDamping(3) = 3*(176.04);  % from heave decay
% body(2).quadDrag.drag(3,3) = 780.8;     % WAG
% % pitch
% body(2).linearDamping(5) = 0.85*(29.63-12.9347); % 40; % mean(c)*(Iyy-B55)
% body(2).quadDrag.drag(5,5) = 25.1855;
% % surge
% body(2).quadDrag.drag(1,1) = 780.8;     % WAG
% body(2).linearDamping(1) = 770;        	%[N/m/s] from surge decay

%% Body 3: Back Flap (Float 2)
body(3) = bodyClass('hydroData/foswec.h5');
body(3).geometryFile = 'geometry/flap.stl';
body(3).mass = 23.14;                       %[kg] from Exp
body(3).inertia = [1.42 1.19 1.99];    %[kg-m^2] from Exp
% pitch
body(3).linearDamping(5,5) = 4.7141;      % from forced oscillation
body(3).quadDrag.drag(5,5) = 5;% 21.3757;	% from forced oscillation


%% Body 4: Mooring Non-hydro Body (Mooring Line 1)
body(4) = bodyClass('');                % Initialize bodyClass without an *.h5 file
body(4).geometryFile = 'geometry/squares.stl';    % Geometry File
body(4).nonHydro = 1;                     % Turn non-hydro body on
body(4).name = 'line_1';                  % Specify body name
body(4).mass = 0.01;                     % Specify Mass  
body(4).inertia = [0 0 0];         % Specify MOI  
body(4).centerGravity = [-0.65 0 -1.2];                % Specify centerGravity  
body(4).volume = 0;                    % Specify Displaced Volume  
body(4).centerBuoyancy = [0,0,0];

%% Body 4: Mooring Non-hydro Body (Mooring Line 2)
body(5) = bodyClass('');                % Initialize bodyClass without an *.h5 file
body(5).geometryFile = 'geometry/squares.stl';    % Geometry File
body(5).nonHydro = 1;                     % Turn non-hydro body on
body(5).name = 'line_2';                  % Specify body name
body(5).mass = 0.01;                     % Specify Mass  
body(5).inertia = [0 0 0];         % Specify MOI  
body(5).centerGravity = [0.65 0 -1.2];                % Specify centerGravity  
body(5).volume = 0;                    % Specify Displaced Volume  
body(5).centerBuoyancy = [0,0,0];

%% Constraints and PTOs
%% PTO 1: Rotational PTO (PTO 1)
pto(1)= ptoClass('PTO_flap1');
pto(1).location = [-0.65 0 -0.6];
% apply damping of 0.1 Nms at motor
% pto(1).damping = 0.1;

%% PTO 2: Rotational PTO (PTO 2)
pto(2)= ptoClass('PTO_flap2');
pto(2).location = [0.65 0 -0.6];
% apply damping of 0.1 Nms at motor
% pto(2).damping = 0.1;

%% PTO 3: Rotational PTO (Connection 1)
pto(3) = ptoClass('connection_1');
pto(3).location = [-0.65 0 -1.05];
% apply Mooring stiffness 
pto(3).stiffness = (1e4)/10;     %based on stiffness from previous model
pto(3).damping = 0;

%% PTO 4:  Rotational PTO (Anchor 1)
pto(4) = ptoClass('anchor_1');
pto(4).location = [-0.65 0 -1.35];
pto(4).stiffness = 0;
pto(4).damping = 0;

%% PTO 5: Rotational PTO (Connection 2)
pto(5) = ptoClass('connection_2');
pto(5).location = [0.65 0 -1.05];
% apply Mooring stiffness 
pto(5).stiffness = (1e4)/10;     %based on stiffness from previous model
pto(5).damping = 0;

%% PTO 6:  Rotational PTO (Anchor 2)
pto(6) = ptoClass('anchor_2');
pto(6).location = [0.65 0 -1.35];
pto(6).stiffness = 0;
pto(6).damping = 0;
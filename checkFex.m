% check excitation force between WAMIT mat file for SID and h5 file for
% WecSim

clearvars; close all; clc;

% SID excitation force from WAMIT
sid = load('excitationWAMIT.mat');

dofPitch = 5;
rho = 1020;
g = 9.81;

% use wecSim script to read H5 file
hydroWecSimFlapBow = readBEMIOH5('hydroData/foswec.h5',1,0); % bow flap is body 1
hydroWecSimFlapAft = readBEMIOH5('hydroData/foswec.h5',3,0); % aft flap is body 3

wecSimFexBowPitch =  rho*g* (squeeze(hydroWecSimFlapBow.hydro_coeffs.excitation.re(dofPitch,1,:)) ...
                        + 1i*squeeze(hydroWecSimFlapBow.hydro_coeffs.excitation.im(dofPitch,1,:)));

wecSimFexAftPitch =  rho*g* (squeeze(hydroWecSimFlapAft.hydro_coeffs.excitation.re(dofPitch,1,:)) ...
                        + 1i*squeeze(hydroWecSimFlapAft.hydro_coeffs.excitation.im(dofPitch,1,:)));


% write the h5 results into a .mat file for SID
FexAftPitch = wecSimFexAftPitch;
FexBowPitch = wecSimFexBowPitch;
w = hydroWecSimFlapAft.simulation_parameters.w;

%save('excitationWAMITV2.mat','FexBowPitch','FexAftPitch','w');

figure
subplot(2,1,1)
plot(sid.w, abs(sid.FexBowPitch))
hold on
plot(hydroWecSimFlapBow.simulation_parameters.w, abs(wecSimFexBowPitch))
ylabel('Fex Pitch Bow (Nm/m)')
xlabel('t (s)')
title('Abs')
legend('SID','wecSim')

subplot(2,1,2)
title('Abs')
plot(sid.w, abs(sid.FexAftPitch))
hold on
plot(hydroWecSimFlapAft.simulation_parameters.w, abs(wecSimFexAftPitch))
ylabel('Fex Pitch Aft (Nm/m)')
xlabel('t (s)')
legend('SID','wecSim')

figure
subplot(2,1,1)
plot(sid.w, real(sid.FexBowPitch))
hold on
plot(hydroWecSimFlapBow.simulation_parameters.w, real(wecSimFexBowPitch))
ylabel('Fex Pitch Bow (Nm/m)')
xlabel('t (s)')
title('Real')
legend('SID','wecSim')

subplot(2,1,2)
plot(sid.w, real(sid.FexAftPitch))
hold on
plot(hydroWecSimFlapAft.simulation_parameters.w, real(wecSimFexAftPitch))
ylabel('Fex Pitch Aft (Nm/m)')
xlabel('t (s)')
legend('SID','wecSim')

figure
subplot(2,1,1)
plot(sid.w, imag(sid.FexBowPitch))
hold on
plot(hydroWecSimFlapBow.simulation_parameters.w, imag(wecSimFexBowPitch))
ylabel('Fex Pitch Bow (Nm/m)')
xlabel('t (s)')
title('Imag')
legend('SID','wecSim')

subplot(2,1,2)
plot(sid.w, imag(sid.FexAftPitch))
hold on
plot(hydroWecSimFlapAft.simulation_parameters.w, imag(wecSimFexAftPitch))
ylabel('Fex Pitch Aft (Nm/m)')
xlabel('t (s)')
legend('SID','wecSim')




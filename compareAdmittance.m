% script to compare the admittance (from SID) with the WAMIT coefficients
% the SID admittance is motor torque -> motor angle
% flap torque = N * motor torque
% flap angle = motor angle / N
% flap angle / flap torque = motor angle / N / (N * motor torque) = 1/N^2 * motor angle / motor torque

% JS, last edited 2022-07-20

clearvars; close all; clc

%% === settings & parameters ==============================================
admittanceSidFile = 'AdmittanceTF.mat';
wamitH5File = 'hydroData/foswec.h5';

h5BodyBowName = '/body1';
h5BodyAftName = '/body3';

flapInertia = [1.42 1.19 1.99]; % this is provided in the wecSim input file
flapDamping = 4.7; % linear damping in pitch

fSid = 0.01:0.01:2;
wSid = 2*pi*fSid;

PITCH = 5; % pitch index in 6-DoF
RY = 2; % pitch index in rotational (3x1) vector

rho = 1000;
g = 9.81;

lw = 1.8;

N = 3.75;
% =========================================================================


%% === obtain the SID admittance ==========================================

% TODO - Check with Ryan if the order 1/2 is correct
admittanceSid = load(admittanceSidFile);
admittanceSid = admittanceSid.admittance;

aftAftAdmittanceSid = admittanceSid(1,1);
[aftAftAdmittanceSidRe, aftAftAdmittanceSidIm] = nyquist(aftAftAdmittanceSid, wSid);
aftAftAdmittanceSidMag = (abs((squeeze(aftAftAdmittanceSidRe) + 1i*squeeze(aftAftAdmittanceSidIm))));
aftAftAdmittanceSidPhase = angle((squeeze(aftAftAdmittanceSidRe) + 1i*squeeze(aftAftAdmittanceSidIm)));

aftBowAdmittanceSid = admittanceSid(1,2);
[aftBowAdmittanceSidRe, aftBowAdmittanceSidIm] = nyquist(aftBowAdmittanceSid, wSid);
aftBowAdmittanceSidMag = (abs((squeeze(aftBowAdmittanceSidRe) + 1i*squeeze(aftBowAdmittanceSidIm))));
aftBowAdmittanceSidPhase = angle((squeeze(aftBowAdmittanceSidRe) + 1i*squeeze(aftBowAdmittanceSidIm)));

bowBowAdmittanceSid = admittanceSid(2,2);
[bowBowAdmittanceSidRe, bowBowAdmittanceSidIm] = nyquist(bowBowAdmittanceSid, wSid);
bowBowAdmittanceSidMag = (abs((squeeze(bowBowAdmittanceSidRe) + 1i*squeeze(bowBowAdmittanceSidIm))));
bowBowAdmittanceSidPhase = angle((squeeze(bowBowAdmittanceSidRe) + 1i*squeeze(bowBowAdmittanceSidIm)));

bowAftAdmittanceSid = admittanceSid(2,1);
[bowAftAdmittanceSidRe, bowAftAdmittanceSidIm] = nyquist(bowAftAdmittanceSid, wSid);
bowAftAdmittanceSidMag = (abs((squeeze(bowAftAdmittanceSidRe) + 1i*squeeze(bowAftAdmittanceSidIm))));
bowAftAdmittanceSidPhase = angle((squeeze(bowAftAdmittanceSidRe) + 1i*squeeze(bowAftAdmittanceSidIm)));
% =========================================================================


%% === obtain the WAMIT admittance via the h5 data ========================

wWamit= h5read(wamitH5File,'/simulation_parameters/w');
fWamit = wWamit/(2*pi);

bodyNameBow = h5read(wamitH5File,[h5BodyBowName '/properties/name']);
bodyNameAft = h5read(wamitH5File,[h5BodyAftName '/properties/name']);

fprintf('Bow body name in h5: %s\n',bodyNameBow)
fprintf('Aft body name in h5: %s\n',bodyNameAft)

% Read added mass coefficients
bowAddedMass = reverseDimensionOrder(h5read(wamitH5File, [h5BodyBowName '/hydro_coeffs/added_mass/all']));
bowAddedMassInf = reverseDimensionOrder(h5read(wamitH5File, [h5BodyBowName '/hydro_coeffs/added_mass/inf_freq'])) ;
bowRadDamping = reverseDimensionOrder(h5read(wamitH5File, [h5BodyBowName '/hydro_coeffs/radiation_damping/all']));
bowStiffness = reverseDimensionOrder(h5read(wamitH5File, [h5BodyBowName '/hydro_coeffs/linear_restoring_stiffness']));

aftAddedMass = reverseDimensionOrder(h5read(wamitH5File, [h5BodyAftName '/hydro_coeffs/added_mass/all']));
aftAddedMassInf = reverseDimensionOrder(h5read(wamitH5File, [h5BodyAftName '/hydro_coeffs/added_mass/inf_freq']));
aftRadDamping = reverseDimensionOrder(h5read(wamitH5File, [h5BodyAftName '/hydro_coeffs/radiation_damping/all']));
aftStiffness = reverseDimensionOrder(h5read(wamitH5File, [h5BodyAftName '/hydro_coeffs/linear_restoring_stiffness']));

% bow is body 1 - TODO - check this with Bret & Ryan
bowBowAddedMass = squeeze(bowAddedMass(PITCH, PITCH + 0*6, :))' * rho;
bowBowRadDamping = squeeze(bowRadDamping(PITCH, PITCH + 0*6, :))' * rho .* wWamit;
bowBowStiffness = bowStiffness(PITCH, PITCH) * rho * g;

bowAftAddedMass = squeeze(bowAddedMass(PITCH, PITCH + 2*6, :))' * rho;
bowAftRadDamping = squeeze(bowRadDamping(PITCH, PITCH + 2*6, :))' * rho .* wWamit;
bowAftStiffness = 0; % TODO - what should the be?

% aft is body 3 - TODO - check this with Bret & Ryan
aftAftAddedMass = squeeze(aftAddedMass(PITCH, PITCH + 2*6, :))' * rho;
aftAftRadDamping = squeeze(aftRadDamping(PITCH, PITCH + 2*6, :))' * rho .* wWamit;
aftAftStiffness =  aftStiffness(PITCH, PITCH) * rho * g;

aftBowAddedMass = squeeze(aftAddedMass(PITCH, PITCH + 0*6, :))' * rho;
aftBowRadDamping = squeeze(aftRadDamping(PITCH, PITCH + 0*6, :))' * rho .* wWamit;
aftBowStiffness = 0; % TODO - what should the be?

% the admittance is in terms of position (not velocity)
bowBowAdmittanceWamit = N^2* 1./((1i*wWamit).^2.* (bowBowAddedMass+flapInertia(RY)) + 1i*wWamit .* (bowBowRadDamping + flapDamping) + bowBowStiffness);
aftAftAdmittanceWamit = N^2* 1./((1i*wWamit).^2.* (aftAftAddedMass+flapInertia(RY)) + 1i*wWamit .* (aftAftRadDamping + flapDamping) + aftAftStiffness);

bowAftAdmittanceWamit = N^2* 1./((1i*wWamit).^2.* (bowAftAddedMass + 0) + 1i*wWamit .* (bowAftRadDamping) + bowAftStiffness);
aftBowAdmittanceWamit = N^2* 1./((1i*wWamit).^2.* (aftBowAddedMass + 0) + 1i*wWamit .* (aftBowRadDamping) + aftBowStiffness);

% =========================================================================

%% === process the WAMIT phase ============================================
aftAftAdmittanceWamitPhase = angle(aftAftAdmittanceWamit);
aftAftAdmittanceWamitPhase(aftAftAdmittanceWamitPhase>0) = aftAftAdmittanceWamitPhase(aftAftAdmittanceWamitPhase>0) - 2*pi;

bowBowAdmittanceWamitPhase = angle(bowBowAdmittanceWamit);
bowBowAdmittanceWamitPhase(bowBowAdmittanceWamitPhase>0) = bowBowAdmittanceWamitPhase(bowBowAdmittanceWamitPhase>0) - 2*pi;

bowAftAdmittanceWamitPhase = angle(bowAftAdmittanceWamit);
%bowAftAdmittanceWamitPhase(bowAftAdmittanceWamitPhase>0) = bowAftAdmittanceWamitPhase(bowAftAdmittanceWamitPhase>0) - 2*pi;

aftBowAdmittanceWamitPhase = angle(aftBowAdmittanceWamit);
%aftBowAdmittanceWamitPhase(aftBowAdmittanceWamitPhase>0) = aftBowAdmittanceWamitPhase(aftBowAdmittanceWamitPhase>0) - 2*pi;


% =========================================================================

% bow-bow
figure
subplot(2,1,1)
semilogy(fSid, bowBowAdmittanceSidMag,'LineWidth',lw)
hold on
semilogy(fWamit, abs(bowBowAdmittanceWamit),'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Mag')
title('Bow-bow')
xlim([0.1 2])
grid on
legend('SID','WAMIT')

subplot(2,1,2)
plot(fSid, bowBowAdmittanceSidPhase*180/pi,'LineWidth',lw)
hold on
plot(fWamit, bowBowAdmittanceWamitPhase*180/pi,'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Phase (deg)')
xlim([0.1 2])
grid on
legend('SID','WAMIT')

%aft-aft
figure
subplot(2,1,1)
semilogy(fSid, aftAftAdmittanceSidMag,'LineWidth',lw)
hold on
semilogy(fWamit, abs(aftAftAdmittanceWamit),'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Mag')
title('Aft-aft')
xlim([0.1 2])
grid on
legend('SID','WAMIT')

subplot(2,1,2)
plot(fSid, aftAftAdmittanceSidPhase*180/pi,'LineWidth',lw)
hold on
plot(fWamit, aftAftAdmittanceWamitPhase*180/pi,'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Phase (deg)')
xlim([0.1 2])
grid on
legend('SID','WAMIT')

% aft-bow
figure
subplot(2,1,1)
semilogy(fSid, aftBowAdmittanceSidMag,'LineWidth',lw)
hold on
semilogy(fWamit, abs(aftBowAdmittanceWamit),'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Mag')
title('Aft-bow')
xlim([0.1 2])
grid on
legend('SID','WAMIT')

subplot(2,1,2)
plot(fSid, aftBowAdmittanceSidPhase*180/pi,'LineWidth',lw)
hold on
plot(fWamit, aftBowAdmittanceWamitPhase*180/pi,'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Phase (db)')
xlim([0.1 2])
grid on
legend('SID','WAMIT')

% bow-aft
figure
subplot(2,1,1)
semilogy(fSid, bowAftAdmittanceSidMag,'LineWidth',lw)
hold on
semilogy(fWamit, abs(bowAftAdmittanceWamit),'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Mag')
title('Bow-aft')
xlim([0.1 2])
grid on
legend('SID','WAMIT')

subplot(2,1,2)
plot(fSid, bowAftAdmittanceSidPhase*180/pi,'LineWidth',lw)
hold on
plot(fWamit, bowAftAdmittanceWamitPhase*180/pi,'LineWidth',lw)
xlabel('f (Hz)')
ylabel('Phase (db)')
xlim([0.1 2])
grid on
legend('SID','WAMIT')



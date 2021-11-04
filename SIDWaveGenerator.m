function [Fexin, FexcAft, FexcBow, admittance_ss, Ef] = SIDWaveGenerator(TsTwin,duration,admittanceModel,excitationModel,waveH,waveT,wavetype)
%SIDWAVEGENERATOR Generates excitation force time series for importing into
%simulink.  'irregular' or 'regular' waves are wavetype options

%% constants
rho = 999.1033;
g = 9.8056;
h = 1.36; 

%% load transfer function data
wamit = load(excitationModel);
load(admittanceModel,'admittance');
% assignin('base', 'wamit', wamit);
% convert tf to ss models
admittance_ss = idss(admittance);
admittance_ss = c2d(admittance_ss,TsTwin);

duration = str2num(duration);


if strcmp(wavetype,'irregular')
    %% JONSWAP wave parameters
    
    Hm0 = 1; % waveH;  Normalizing Hm0 so we can scale linearly in real-time
    Tp = waveT;
    gamma = 3.3;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % build ideal PM spectrum
    f = linspace(0,16,2^20+1); % 2^20+1 frequencies in 0-16 Hz range
    fp = 1/Tp; % peak frequency
    S = 5/16*Hm0^2*fp^4./f.^5.*exp(-1.25*(f/fp).^(-4)); % Stansberg (2002) Table A.3
    sigma = ones(size(f)) * 0.07; % sigma = 0.07 (f<=fp) or 0.09 (f>fp)
    sigma(f>fp) = 0.09;
    S = S .* gamma.^exp(-(f/fp - 1).^2 ./ (2*sigma.^2));
    Sp = max(S); % peak energy
    
    % find highest frequency we want to resolve
    fN_min = 2*f(find(S>=Sp*0.01,1,'last')); % at least 2x highest frequency with energy at least 1% of the peak
    fN_min = max(fN_min,2); % at least 2Hz
    
    % build spectrum
    df = 1/duration; % spectral resolution
    Nf = 2^nextpow2(fN_min/df)+1; % number of frequencies
    fN = df*(Nf-1); % Nyquist frequency
    f = linspace(0,fN,Nf); % frequencies
    w = 2*pi*f;
    fp = 1/Tp; % peak frequency
    S = 5/16*Hm0^2*fp^4./f.^5.*exp(-1.25*(f/fp).^(-4));  % Pierson-Moskowitz
    S(1)=0;
    sigma = ones(size(f)) * 0.07; % sigma = 0.07 (f<=fp) or 0.09 (f>fp)
    sigma(f>fp) = 0.09;
    S = S .* gamma.^exp(-(f/fp - 1).^2 ./ (2*sigma.^2)); % JONSWAP
    N = 2*(Nf-1); % number of timesteps
    t = linspace(0,duration,N); % time - much corser than 1/1000
   
    % generate complex spectrum with random phases
    phi = 2*pi*rand(size(S)); % random phases
    A = sqrt(2*S*df).*exp(1i*phi); % complex A
    
    % figure
    % subplot(211)
    % plot(w,abs(A))
    % ylabel('Amplitude (m)')
    % grid on
    %
    % subplot(212)
    % plot(w,angle(A))
    % ylabel('Angle (rad)')
    % xlabel('\omega (rad/sec)')
    %
    %
    % sgtitle('JONSWAP amplitude spectrum with random phases')
    % grid on
    
    
    % interpolate wamit results to fit spectral frequency
    wamitExAft = interp1(wamit.w,wamit.FexAftPitch,w,'spline','extrap');
    wamitExBow = interp1(wamit.w,wamit.FexBowPitch,w,'spline','extrap');
    
    % multiply JONSWAP amplitude spectrum and wamit excitation spectrum
    FexAft_w = A .* wamitExAft;
    FexBow_w = A .* wamitExBow;
    
    argAft = [0, FexAft_w(2:Nf-1), 2*real(FexAft_w(Nf)), conj(FexAft_w(Nf-1:-1:2))];
    argBow = [0, FexBow_w(2:Nf-1), 2*real(FexBow_w(Nf)), conj(FexBow_w(Nf-1:-1:2))];
    
    FexAft(1:N) = real(N/2*ifft(argAft)); % generate timeseries
    FexBow(1:N) = real(N/2*ifft(argBow)); % generate timeseries
%     TsTwin = TsTwin * 10;
    tnew = 0:TsTwin:duration; % around 100 hz for tsTwin
    FexAftnew = interp1(t,FexAft,tnew,'spline','extrap');
    FexBownew = interp1(t,FexBow,tnew,'spline','extrap');
    
    % figure
    % plot(t,FexAft)
    % hold on
    % plot(t,FexBow)
    % plot(tnew,FexAftnew,'--')
    % plot(tnew,FexBownew,'--')
    % legend('Aft','Bow','Aft New','Bow New')
    
    t = tnew;
    FexAft = FexAftnew;
    FexBow = FexBownew;
    
    % tukey window on the first and last 20 seconds
    r = 40/duration;
    r_win = tukeywin(length(t),r).';
    
    FexAft = FexAft .* r_win;
    FexBow = FexBow .* r_win;
    
    % plot WAMIT excitation spectrum
    % figure
    % subplot(211)
    % plot(wamit.w,abs(wamit.FexAftPitch))
    % hold on
    % plot(wamit.w,abs(wamit.FexBowPitch))
    % legend('Aft','Bow')
    % ylabel('Excitation (Nm/m)')
    %
    % subplot(212)
    % plot(wamit.w,angle(wamit.FexAftPitch))
    % hold on
    % plot(wamit.w,angle(wamit.FexBowPitch))
    % xlabel('\omega (rad/s)')
    % ylabel('angle (rad)')
    % sgtitle('Normalized Excitation Spectrum (WAMIT)')
    %
    % % plot magnitude with interpolated
    % figure
    % plot(wamit.w,abs(wamit.FexAftPitch),'-')
    % hold on
    % plot(w,abs(wamitExAft),'*')
    % xlabel('\omega(rad/s)')
    % ylabel('Excitation spectrum magnitude')
    % legend('WAMIT','Interpolated')
    
    FexcAft = timeseries(FexAft,t);
    FexcBow = timeseries(FexBow,t);
    
    Fexc.Aft = timeseries(FexAft,t);
    Fexc.Bow = timeseries(FexBow,t);
    busInfo = Simulink.Bus.createObject(Fexc);
    
    % generate time series of Excitation Force for bow and aft
    % figure
    % plot(t,FexAft)
    % hold on
    % plot(t,FexBow)
    % legend('Aft','Bow')
    % grid on
    % xlabel('time (s)')
    % ylabel('Fex (Nm)')
    % title('Excitation force input time series')
    
    Fexin = Simulink.SimulationData.Dataset;
    Fexin = Fexin.addElement(Fexc.Aft,'FexAft');
    Fexin = Fexin.addElement(Fexc.Bow,'FexBow');
    
    %% calculate energy flux from Dean and Dalrymple pg 98 (4.81)
    [~,cg] = phase_speed(h,1./f);
    cg(1) = 0;  % avoid NaN from divide by zero
    Ef = rho*g*trapz(f',cg'.*S');
    Ef = Ef.*waveH^2;
elseif strcmp(wavetype,'regular')
%     TsTwin = TsTwin * 10;
    t = 0:TsTwin:duration;
    H = 1; % Normalizing H so we can scale linearly in real-time
    
    Faftabs = interp1(wamit.w,H/2*abs(wamit.FexAftPitch),2*pi/waveT,'spline');
    Fbowabs = interp1(wamit.w,H/2*abs(wamit.FexBowPitch),2*pi/waveT,'spline');
    Faftangle = interp1(wamit.w,angle(wamit.FexAftPitch),2*pi/waveT,'spline');
    Fbowangle = interp1(wamit.w,angle(wamit.FexBowPitch),2*pi/waveT,'spline');
    
    FexAft = Faftabs .* sin(2*pi./waveT * t + Faftangle);
    FexBow = Fbowabs .* sin(2*pi./waveT * t + Fbowangle);
    
    % tukey window on the first and last 20 seconds
    r = 40/duration;
    r_win = tukeywin(length(t),r).';
    
    FexAft = FexAft .* r_win;
    FexBow = FexBow .* r_win;
    
    FexcAft = timeseries(FexAft,t);
    FexcBow = timeseries(FexBow,t);
    
    Fexc.Aft = timeseries(FexAft,t);
    Fexc.Bow = timeseries(FexBow,t);
    busInfo = Simulink.Bus.createObject(Fexc);
    
    Fexin = Simulink.SimulationData.Dataset;
    Fexin = Fexin.addElement(Fexc.Aft,'FexAft');
    Fexin = Fexin.addElement(Fexc.Bow,'FexBow');
    
    %% calculate wave energy flux from Falnes pg 78
    [L,~,~] = dispersion(h,waveT);
    k = 2*pi/L;
    D = (1+2*k*h/(sinh(2*k*h)))*tanh(k*h);
    A = H/2;
    w = 2*pi/waveT;
    Ef = rho*g^2*D*A^2/(4*w);  % Energy flux in W/m
    Ef = Ef.*waveH^2;


end


end


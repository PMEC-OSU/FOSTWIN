function [FexcAft, FexcBow, wave, admittance_ss, Ef] = SIDWaveGenerator(TsTwin,duration,admittanceModel,excitationModel,waveH,waveT,wavetype)
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
    
    Hm0 = waveH;  
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

    C = 1 - 0.287*log(gamma); % normalizing factor
    S = C * S .* gamma.^exp(-(f/fp - 1).^2 ./ (2*sigma.^2)); % JONSWAP

    m0 = trapz(f,S);
    Hs = 4*sqrt(m0);
    %fprintf('Target Hs = %4.3f, actual Hs = %4.3f \n',Hm0, Hs)

    % generate spectrum with random phases
    phi = 2*pi*rand(size(S)); % random phases
    A = sqrt(2*S*df); %NOT complex A - phase is dealt with further below .*exp(1i*phi);
    
    % interpolate wamit results to fit spectral frequency
    wamitExAft = interp1(wamit.w,wamit.FexAftPitch,w,'spline','extrap');
    wamitExBow = interp1(wamit.w,wamit.FexBowPitch,w,'spline','extrap');
    
    % multiply JONSWAP amplitude spectrum and wamit excitation spectrum
    FexAft_w = A .* wamitExAft;
    FexBow_w = A .* wamitExBow;

    t = 0:TsTwin:duration; % time vector

    % Note: WecSim uses Re*cos(x) - Im*sin(x), which corresponds to
    % real(A*exp(-ix))
    FexAft = zeros(size(t));
    FexBow = zeros(size(t));
    for n=1:length(w)
        arg = -1i*(w(n)*t + phi(n));
        FexAft = FexAft + real(FexAft_w(n)*exp(arg));  
        FexBow = FexBow + real(FexBow_w(n)*exp(arg));  
    end

    eta = zeros(size(t));
    for n=1:length(w)
        arg = -1i*(w(n)*t + phi(n));
        eta = eta + real(A(n)*exp(arg));  
    end

    wave.A = A;
    wave.phi = phi;
    wave.eta = eta;
    wave.w = w;

    % figure
    % plot(t,FexAft)
    % hold on
    % plot(t,FexBow)
    % plot(tnew,FexAftnew,'--')
    % plot(tnew,FexBownew,'--')
    % legend('Aft','Bow','Aft New','Bow New')
    
    % tukey window on the first and last 10 seconds; Note: 20s is quite long
    r = 20/duration;
    r_win = tukeywin(length(t),r).'; 
    
    FexAft = FexAft .* r_win;
    FexBow = FexBow .* r_win;
    
    FexcAft = timeseries(FexAft,t);
    FexcBow = timeseries(FexBow,t);
   
    %% calculate energy flux from Dean and Dalrymple pg 98 (4.81)
    [~,cg] = phase_speed(h,1./f);
    cg(1) = 0;  % avoid NaN from divide by zero
    Ef = rho*g*trapz(f',cg'.*S');
%     Ef = Ef.*waveH^2;
elseif strcmp(wavetype,'regular')
%     TsTwin = TsTwin * 10;
    t = 0:TsTwin:duration;
    waveH= 1; % Normalizing H so we can scale linearly in real-time
    
    Faftabs = interp1(wamit.w,waveH/2*abs(wamit.FexAftPitch),2*pi/waveT,'spline');
    Fbowabs = interp1(wamit.w,waveH/2*abs(wamit.FexBowPitch),2*pi/waveT,'spline');
    Faftangle = interp1(wamit.w,angle(wamit.FexAftPitch),2*pi/waveT,'spline');
    Fbowangle = interp1(wamit.w,angle(wamit.FexBowPitch),2*pi/waveT,'spline');
    
    FexAft = Faftabs .* sin(2*pi./waveT * t + Faftangle);
    FexBow = Fbowabs .* sin(2*pi./waveT * t + Fbowangle);
    
    % tukey window on the first and last 20 seconds
    r = 40/duration;
    r_win = tukeywin(length(t),r).';
    
    FexAft = FexAft .* r_win;
    FexBow = FexBow .* r_win;
    
    % TODO - Bret, are these timeseries used for anything?
    FexcAft = timeseries(FexAft,t);
    FexcBow = timeseries(FexBow,t);
    
%     Fexc.Aft = timeseries(FexAft,t);
%     Fexc.Bow = timeseries(FexBow,t);
%     busInfo = Simulink.Bus.createObject(Fexc); %
%     
%     Fexin = Simulink.SimulationData.Dataset;
%     Fexin = Fexin.addElement(Fexc.Aft,'FexAft');
%     Fexin = Fexin.addElement(Fexc.Bow,'FexBow');
    
    %% calculate wave energy flux from Falnes pg 78
    [L,~,~] = dispersion(h,waveT);
    k = 2*pi/L;
    D = (1+2*k*h/(sinh(2*k*h)))*tanh(k*h);
    A = waveH/2;
    w = 2*pi/waveT;
    Ef = rho*g^2*D*A^2/(4*w);  % Energy flux in W/m
%     Ef = Ef.*waveH^2;
    wave.A = A;
    wave.w = w;

end


end


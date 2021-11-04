function [L,error,count] = dispersion(h,T)

% DISPERSION
%
% [L,error,count] = dispersion(h,T);
%
% Numerically solves the linear dispersion relationship for water waves.  
% omega^2=gk*tanh(kh); where omega = 2*pi/T; k=2*pi/L; g=9.81; 
% T and h provided as inputs.  Can handle T and/or h as vector inputs, for
% which the resulting size is L(m,n) for h(1,m) and T(1,n).
%
% Iterates using Newton-Raphson initialized with Guo (2002), which
% converges in under 1/2 the iterations of starting with deep water.
% 
% Returns the error array and iteration count along with the wavelength.
%
% See also: DISPERSION_RESIDUAL_CHECK

% setup
g = 9.80665;
omega = repmat(2*pi./T,length(h),1);
hh = repmat(h',1,length(T));

% initial guess
k = omega.^2 / g .* (1 - exp(-(omega.*sqrt(hh/g)).^(5/2))).^(-2/5);

% iterate until error converges
error = ones(size(omega));
count = 0;
while max(max(error)) > 10*eps
    f = omega.^2 - g*k.*tanh(k.*hh);
    dfdk = - g*tanh(k.*hh) - g*hh.*k.*(sech(k.*hh)).^2;
    k1 = k - f./dfdk;
    error = abs((k1-k)./k1);
    k = k1;
    count = count+1;
end

% wavelength
L = 2*pi./k;

% done
return

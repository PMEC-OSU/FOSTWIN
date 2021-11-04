function [c,cg] = phase_speed(h,T)

% PHASE_SPEED
%
% [c,cg] = phase_speed(h,T);
%
% Numerically solves the linear dispersion relationship for water waves,
% and uses the result to calculate the phase speed c = L/T in water depth
% h (m), where T is wave period (s) and L (m) is a solution from the 
% dispersion relationship.  Also solves for the group velocity, cg.
%
% Can handle T and/or h as vector inputs, for which the resulting size of
% c (and cg) is c(m,n) for h(1,m) and T(1,n).
%
% See also: DISPERSION

% dispersion for each frequency and depth
[L,~,~] = dispersion(h,T); 

% wavenumber
k = 2*pi./L;

% phase velocity
omega = repmat(2*pi./T,length(h),1);
c = omega ./ k;

% relative depth
kh = k .* repmat(h',1,length(T)); 

% group velocity
cg = 0.5*c.*(1 + 2*kh ./ sinh(2*kh)); 

% done
end
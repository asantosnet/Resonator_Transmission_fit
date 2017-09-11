function [ frequency,S21 ] = fitS21ResonTiN_Assymetric( Q0,f0,Qc,Xe,rangeMin,rangeMax)
%fitS21(Q0,f0,Qc) This function plots the S21 equation to fit the
%experimental result
%   Q0 is the internal quality factor
%   f0 is the measured resonance frequency
%   rangeMin,rangeMax is the range of frequency to be plotted
%   Qc is the coupling quality factor
%   Xe is the assymetric reactive element
%   The formula used for S21 is (Z0V./(Z0V+1i.*XeV)).*...
%   ((1 + 2.*1i.*QoV.*Deltaf0_f0.)/(1 + (Q0V./(QcV.*Z0V)).*(Z0V + 1i.*XeV) +
%   2.*1i.*Q0V.*Deltaf0_f0))


Npoints = 4000;
frequency = rangeMin:(rangeMax-rangeMin)/(Npoints-1):rangeMax;

Deltaf0_f0 = (frequency - f0.*ones(1,Npoints))./(f0.*ones(1,Npoints));

Q0V = Q0.*ones(1,Npoints);
QcV = Qc.*ones(1,Npoints); 
XeV = Xe.*ones(1,Npoints);
%Z0V = 50.*ones(1,Npoints);
Z0V = 140.*ones(1,Npoints);

Aterm = Z0V./(Z0V+1i.*XeV);

Btermnume = ones(1,Npoints) + 2.*1i.*Q0V.*Deltaf0_f0;

Btermdeno = ones(1,Npoints) + (Q0V./(QcV.*Z0V)).*(Z0V + 1i.*XeV) + 2.*1i.*Q0V.*Deltaf0_f0;

S21 = Aterm.*(Btermnume./Btermdeno);




%figure('name','Series LC')

% plot(frequency,log(abs(S21)));

% title(['fit with : ', ' - Q0 = ',num2str(Q0), '  - Qc = ', num2str(Qc), ...
%                ' - f0 = ', num2str(f0)]);




end


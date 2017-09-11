function F = root2d(x,slope1,intercept1,slope2,intercept2,Z0)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% Ca = x(1); omegar = x(2); Zr = x(3); Cetoile = x(4)

F(1) = (x(1).*x(3))./(2.*x(2))-slope1;
F(2) = (1./x(2)).*(1+((x(4).*x(3))./2))-intercept1;
F(3) = sqrt(x(3).*Z0).*(x(1)./sqrt(2))-slope2;
F(4) = sqrt(x(3).*Z0).*(x(4)./sqrt(2))-intercept2;

end


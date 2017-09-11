function [ CA,CAvect ] = find_CA( sortedexpfitparam,Zr,Z0 )
%[ CA,CAvect ] = find_CA( sortedexpfitparam ) Find CA [= CAvect] and
%average it [= CA]. 

nPsivect = [1 2 3 4];  % to avoind a for ^^
nPlus1Psivect = [2 3 4 5];

psiN = sqrt(2./(sortedexpfitparam(nPsivect,3).*Z0.*...
            ((sortedexpfitparam(nPsivect,1)./(2.*pi)).^2)));
        
psiNplus1 = sqrt(2./(sortedexpfitparam(nPlus1Psivect,3).*Z0.*...
            ((sortedexpfitparam(nPlus1Psivect,1)./(2.*pi)).^2)));
        

CAvect = (psiNplus1-psiN)./sqrt(Zr);
CA = sum(CAvect)/size(CAvect,1);


end


function [f Z EoS] = fugF(EoS,T,P,mix,phase,varargin)
%Calculates the fugacity and compressibility coefficient of mixture mix at temperature T
%and pressure P using GC EoS
%
%Parameters:
%EoS: Equation of state used for calculations
%T: Temperature(K)
%P: Pressure (K)
%mix: cMixture object
%phase: set phase = 'liq' to calculate the fugacity of a liquid phase or
%   phase = 'gas' to calculate the fugacity of a gas phase
%
%Optional parameters (set [] to keep default value)
%Z_ini: Initial guess for the compressibility coefficient
%   If not defined, the program uses an initial guess Z_ini = 0.8 for gas
%   phase and a Z_ini corresponding to a liquid density of 800 kg/m3 for
%   the liquid phase
%options: parameters of the fzero numerical resolution method (structure
%   generated with "optimset")
%
%Results:
%f: fugacity coefficient
%Z: compressibility coefficient
%EoS: returns EoS used for calculations

%Copyright (c) 2011 �ngel Mart�n, University of Valladolid (Spain)
%This program is free software: you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%You should have received a copy of the GNU General Public License
%along with this program.  If not, see <http://www.gnu.org/licenses/>.

if (nargin == 5) || (nargin > 5 && isempty(varargin{1}))
    if strcmp(phase,'gas') == 1
        Z_ini = 0.8;
    elseif strcmp(phase, 'liq') == 1
        V = 1/(800*1000/mix.MW);
        Z_ini = P*V/(8.31*T);
    else
        error('Undefined type of phase in GCEoS');
    end
else
    Z_ini = varargin{1};
end

if nargin == 7
    OPTIONS = varargin{2};
else
	if length(ver('MATLAB')) == 1
		OPTIONS = optimset('Display','off','TolX',1e-6,'TolFun',1e-6,'MaxIter',50,'MaxFunEvals',50);
	else
		OPTIONS = optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',50,'MaxFunEvals',50);  %For compatibility with octave which does not support 'Display' option
	end
end

[Z FVAL FLAG] = fsolve(@(Z) obj_GC_EOS(Z,EoS,T,P,mix), Z_ini, OPTIONS);

if FLAG < 1
    warning('MATLAB:EoS', 'Convergence error in GCEoS. FSOLVE flag: %d, FSOLVE final value: %f', FLAG, FVAL);
end

[FVAL Z f] = obj_GC_EOS(Z,EoS,T,P,mix);
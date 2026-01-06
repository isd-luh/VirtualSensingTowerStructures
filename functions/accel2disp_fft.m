% Copyright 2026 Institute of Structural Analysis, Leibniz University Hannover
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

function disp = accel2disp_fft(accel,m,fs)
    % accel2disp_fft return a displacement time series calculated from an
    % acceleration time series using the combined tilt error compensation
    % and integration (Equation 9). The tilt constant m is extracted from
    % the FE model. 
    %
    % INPUT
    % - accel (vector of double)
    %   acceleration time series
    % - m (double) 
    %   tilt constant
    % - fs (double) 
    %   sampling frequency
    % OUTPUT
    % - disp (vector of double) 
    %   predicted diplacement time series
    
    g=9.81;
    zero_flag=false;
    % calculate Fourier transform of acceleration signal
    if  mod(length(accel),2)
        X=fft(accel(1:end-1,1));
        zero_flag=true;
    else
        X=fft(accel(1:end,1));
    end
    % 
    f_fft = fs/numel(X)*(-numel(X)/2:numel(X)/2-1);

    % calculate combined tilt error and integration factor
    factor = (2*pi*f_fft).^(-2) ./ ((2*pi*f_fft).^(-2) * g * m + 1);
    % replace value at f=0
    factor(isnan(factor))=1/(g*m);
    
    % calculate displacement from acceleration
    X_comp = fftshift((factor').*fftshift(X));

    % calculate inverse Fourier transform of displacement signal
    disp = -ifft(X_comp);
    if zero_flag
        disp=[disp; 0];
    end
end



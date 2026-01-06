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

function strain = disp2strain_fft(disp,fs,freq,H)
    % disp2strain_fft return a strain time series calculated from an
    % displacement time series based on the modal decomposition and
    % expansion using N = length(H) supporting mode shapes / Ritz vectors
    % (Equation 21).
    % 
    % INPUT
    % - disp (vector of double)
    %   displacement time series
    % - fs (double)
    %   sample rate of disp
    % - freq (vector of double) 
    %   frequencies at which H is sampled
    % - H (vector of double)
    %   samples of H at freq (H = strain/displacement)
    % output
    % - strain (vector of double)
    %   predicted strain time series
    
    g=9.81;
    zero_flag=false;
    % calculate Fourier transform of displacement signal
    if  mod(length(disp),2)
        X=fft(disp(1:end-1));
        zero_flag=true;
    else
        X=fft(disp(1:end));
    end
    f_fft = fs/numel(X)*(-numel(X)/2:numel(X)/2-1);
    
    % interpolate H for all frequencies in spectrum
    freq = freq(2:end);
    H = H(2:end);
    H_interpolated = interp1([-flip(freq'); freq'],[flip(H'); H'],f_fft);
        
    % calculate strain from displacements
    X_comp = fftshift((H_interpolated').*fftshift(X));

    % calculate inverse Fourier transform of strain signal
    strain = ifft(X_comp);
    if zero_flag
        strain=[strain; 0];
    end
    strain = real(strain);
end



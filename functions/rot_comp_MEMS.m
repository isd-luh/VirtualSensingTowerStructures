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

function [Data_accel_rot]= rot_comp_MEMS(Data_accel,Data_start,Data_end)
    % rot_comp_MEMS returns the acceleration measurements rotated to the
    % gravitational field based on the acceleration signal during a specified 
    % period (Equation 11). 
    %
    % INPUT
    % - Data_accel (array of double) 
    %   measured acceleration time series
    % - Data_start (integer)
    %   start index to calculate mean gravitational vector
    % - Data_end (integer)
    %   end index to calculate mean gravitational vector
    % OUTPUT
    % - Data_accel_rot (array of double)
    %   rotated acceleration time series

    g=9.81;
    % calculate mean angle in specified period
    Data_angle=mean(Data_accel(Data_start:Data_end,:));
    phi=asin(-(Data_angle(3)/norm(Data_angle)));
    zeta=asin(-(Data_angle(1)/(norm(Data_angle)*cos(phi))));
    phi=-phi;
    
    % calculate rotation matrix 
    R=[cos(zeta) -cos(phi)*sin(zeta) sin(phi)*sin(zeta)
        sin(zeta) cos(phi)*cos(zeta) -sin(phi)*cos(zeta)
        0 sin(phi) cos(phi)];

    % calculate roated accleration
    Data_accel_rot=((R)*Data_accel')';
end



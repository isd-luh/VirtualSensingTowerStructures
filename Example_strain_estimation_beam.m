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

% Preparation
close all; clear; clc
addpath(genpath('.\functions'))
addpath(genpath('.\plots'))
addpath(genpath('.\Data'))

% Measurement levels for accelerometers and DMS
MP_accel_array = ["MP1", "MP2", "MP3"]'; % MP1 = 146.2, MP2 = 109.8, MP3 = 82.9
MP_strain_array = ["MP4", "MP5"];        % MP4 = 79.8, MP5 = 39.3

% Filter and data settings
f_LP = 12; 
Data_start = 1;
Data_end = 6000;

% Levels for strain and acceleration
level_strain = [0.393, 0.798];
level_accel = [0.829, 1.098, 1.462];

% Define FE model distance from ground
FE_model.distance = [0:0.001:1.523]';

% Load data from repository
url = 'https://data.uni-hannover.de/dataset/3aceac8e-e8ee-4497-8ea1-90acaa57dda0/resource/0afe150f-df81-41f6-82a2-a4c53f597b8f/download/measurement_data_virtual_sensing_benchmark_beam.mat';
filename = 'Data_strain_estimation_laboratory_beam.mat';
websave(filename,url);
load(filename);
delete Data_strain_estimation_laboratory_beam.mat

% Find indices for strain and acceleration levels
[~, index_strain] = min(abs(FE_model.distance - level_strain));
[~, index_accel] = min(abs(FE_model.distance - level_accel));

% Initialize structures
strain_m = struct();
strain_p = struct();
disp_m = struct();
disp_p = struct();

% Sampling frequency and time vector
Fs = Dat.Fs;
time = (0:size(Dat.Data,1)-1) ./ Fs;

% Gravitational constant
g = 9.81;

% Index for specific time sections
[~, index_section] = min(abs(time' - [0, 310, 395, 505]));

for jj = 1:length(MP_strain_array)
    MP_strain = MP_strain_array(jj);

    for ii = 1:length(MP_accel_array)
        MP_accel = MP_accel_array(ii);
        
        % select appropriate m and H (sampled from FE model)
        switch MP_accel
            case "MP1"
                m = 1.0342;
                switch MP_strain
                    case "MP4"
                        H = [0.00176	0.00176	0.00139	0.00139	0.0308	0.0308];
                    case "MP5"
                        H = [0.00274	0.00274	0.00277	0.00277	0.00549	0.00549];
                end
            case "MP2"
                m = 1.5106;
                switch MP_strain
                    case "MP4"
                        H = [0.00277	0.00277	0.00212	0.00212	-0.0434	-0.0434];
                    case "MP5"
                        H = [0.00432	0.00432	0.00422	0.00422	-0.00773	-0.00773];
                end
            case "MP3"
                m = 2.1096;
                switch MP_strain
                    case "MP4"
                        H = [0.00448	0.00448	0.00333	0.00333	-0.0232	-0.0232];
                    case "MP5"
                        H = [0.00698	0.00698	0.00664	0.00664	-0.00414	-0.00414];
                end
        end 
        freq_MDE = [0.001	0.79	0.7901401	5.99	5.9901	20.0];


        % select correct channel and load measured data
        switch MP_accel
            case "MP1"
                laser_channel=[10];
                laser_lag = 0;
                accel_channel=7:9;
            case "MP2"
                laser_channel=12;
                laser_lag = 6;
                accel_channel=4:6;
            case "MP3"
                laser_channel=11; 
                laser_lag = 6;
                accel_channel=1:3;
        end 
        switch MP_strain
            case "MP4"
                strain_m.(MP_strain) = [- Dat.Data(:,13), Dat.Data(:,14)];
            case "MP5"
                strain_m.(MP_strain) = [- Dat.Data(:,15), Dat.Data(:,16)];
        end
        disp_m.(MP_accel) = -(Dat.Data(:,laser_channel)) / 1000;
        disp_m.(MP_accel) = [disp_m.(MP_accel)(laser_lag+1:end); zeros(laser_lag,1)];
        strain_m.(MP_strain) = strain_m.(MP_strain)(:,2) / 10^6;
        accel_m=Dat.Data(:,accel_channel)*g;
        accel_m=accel_m(:,[3 1 2]);
        accel_m(:,2)=-accel_m(:,2);
        accel_m(:,3)=-accel_m(:,3);
        
        
        % remove rotation
        accel_rot = rot_comp_MEMS(accel_m, Data_start, Data_end);
        
        % displacement estimation
        disp_p.(MP_accel) = accel2disp_fft(accel_rot,m,Dat.Fs);
        [disp_p.(MP_accel),~] = lowpass(disp_p.(MP_accel),f_LP,Fs,ImpulseResponse="iir",Steepness=0.95);
        [disp_m.(MP_accel),~] = lowpass(disp_m.(MP_accel),f_LP,Fs,ImpulseResponse="iir",Steepness=0.95);
        
        % strain estimation 
        strain_p.(MP_strain)(:,ii) = disp2strain_fft(disp_p.(MP_accel),Fs,[freq_MDE 300],[H 0]);
        [strain_p.(MP_strain),~] = lowpass(strain_p.(MP_strain),f_LP,Fs,ImpulseResponse="iir",Steepness=0.95);
        [strain_m.(MP_strain),~] = lowpass(strain_m.(MP_strain),f_LP,Fs,ImpulseResponse="iir",Steepness=0.95);
        
        % remove linear drift
        p = polyfit([Data_start:Data_end, length(disp_m.(MP_accel))-Data_end:length(disp_m.(MP_accel))], disp_m.(MP_accel)([Data_start:Data_end, length(disp_m.(MP_accel))-Data_end:length(disp_m.(MP_accel))]),1);
        disp_m.(MP_accel) = disp_m.(MP_accel) - polyval(p, 1:length(disp_m.(MP_accel)))';
        p = polyfit([Data_start:Data_end, length(disp_p.(MP_accel))-Data_end:length(disp_p.(MP_accel))], disp_p.(MP_accel)([Data_start:Data_end, length(disp_p.(MP_accel))-Data_end:length(disp_p.(MP_accel))]),1);
        disp_p.(MP_accel) = disp_p.(MP_accel) - polyval(p, 1:length(disp_p.(MP_accel)))';
        p = polyfit([Data_start:Data_end, length(strain_m.(MP_strain))-Data_end:length(strain_m.(MP_strain))], strain_m.(MP_strain)([Data_start:Data_end, length(strain_m.(MP_strain))-Data_end:length(strain_m.(MP_strain))]),1);
        strain_m.(MP_strain) = strain_m.(MP_strain) - polyval(p, 1:length(strain_m.(MP_strain)))';
        p = polyfit([Data_start:Data_end, length(strain_p.(MP_strain)(:,ii))-Data_end:length(strain_p.(MP_strain)(:,ii))], strain_p.(MP_strain)([Data_start:Data_end, length(strain_p.(MP_strain))-Data_end:length(strain_p.(MP_strain))],ii),1);
        strain_p.(MP_strain)(:,ii) = strain_p.(MP_strain)(:,ii) - polyval(p, 1:length(strain_p.(MP_strain)(:,ii)))';
    
        
    end

end

% visualise results
plot_displacement_estimation(time, disp_p, disp_m, Fs ,[0 515],[0 f_LP])
plot_strain_estimation(time, strain_p, strain_m, Fs, [0 515], [0, f_LP])




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

function [] = plot_displacement_estimation(time, disp_p, disp_m, Fs, varargin)
    % plot_displacement_estimation creates plots from the measured and 
    % estimated displacement time series (compare Fig. 9-11)
    % 
    % INPUT
    % - time (vector of double)
    %   vector containing time stamps
    % - disp_p (struct containing vector of double)
    %   struct containing estimated displacement time series for each predicted MP
    % - disp_m (struct containing vector of double)
    %   struct containing measured displacement time series for each predicted MP
    % - Fs (double)
    %   sampling frequency
    % - varargin{1} (vector of double)
    %   x-limits time series plot
    % - varargin{2} (vector of double)
    %   x-limits spectrum
    % OUTPUT


% Setting optional parameters
default_xlim_time = [min(time), max(time)];
default_xlim_spectrum = [0, Fs/2];
    
nArgs = length(varargin);
if nArgs >= 1
    xlim_time = varargin{1};
else
    xlim_time = default_xlim_time;
end
if nArgs >= 2
    xlim_spectrum = varargin{2};
else
    xlim_spectrum = default_xlim_spectrum;
end

% Load fieldnames (= measuring points)
accel_pos = fieldnames(disp_p);

% Plot size
if length(accel_pos) == 1
    plot_height = 235;
elseif length(accel_pos) == 2
    plot_height = 350;
else
    plot_height = 420;
end

% Convert units
for ii = 1:length(accel_pos)
    field = accel_pos{ii};
    disp_p.(field) = 1000.*disp_p.(field);
    disp_m.(field) = 1000.*disp_m.(field);
end


%% Plot estimation + zoom
fig_estimation_zoom = figure;
t = tiledlayout(2*length(accel_pos),3,'TileSpacing','Compact');
inset_xlims = [255 265; 330 340; 430 440];
inset_positions_x = [0.4, 0.65, 0.8];
inset_positions_y = [0.83, 0.56, 0.29];
inset_scale = 0.1; 
legend_array = ["Measured"];
for ii = 1:length(accel_pos)
    ax_primary = nexttile(t,[1 3]);
    hold on
    if ii == length(accel_pos)
        plot(NaN,NaN,'color', [0.3,0.3,0.3])
        for jj = 1:length(accel_pos)
            if accel_pos{jj} == "MP3"
                colorRGB = [0, 0.4470, 0.7410];        
                legend_array = [legend_array; 'MP3_{accel}'];
            elseif accel_pos{jj} == "MP2"
                colorRGB = [0.8500, 0.3250, 0.0980];        
                legend_array = [legend_array; 'MP2_{accel}'];
            elseif accel_pos{jj} == "MP1"
                colorRGB = [0.9290, 0.6940, 0.1250];        
                legend_array = [legend_array; 'MP1_{accel}'];
            end
            plot(NaN,NaN, 'color', colorRGB)
        end
    end
    if accel_pos{ii} == "MP3"
        colorRGB = [0, 0.4470, 0.7410];
    elseif accel_pos{ii} == "MP2"
        colorRGB = [0.8500, 0.3250, 0.0980];
    elseif accel_pos{ii} == "MP1"
        colorRGB = [0.9290, 0.6940, 0.1250];
    end

    plot(time,disp_m.(accel_pos{ii}),'color', [0.3,0.3,0.3])
    plot(time, disp_p.(accel_pos{ii}), 'color', colorRGB)
    yl = ylim;
    yl = [-max(abs(disp_p.(accel_pos{ii})))*1.2 max(abs(disp_p.(accel_pos{ii})))*1.2];
    ylim(yl);
    xlim(xlim_time)

    if length(accel_pos) ~= 1
        title(['Displacement estimation at MP' + string(ii)])
    end

    for inset = 1:length(inset_positions_x)
        xl_inset = inset_xlims(inset,1:2);
        [~,index_inset(1)] = min(abs(time - xl_inset(1)));
        [~,index_inset(2)] = min(abs(time - xl_inset(2)));
        yl_inset = [min(disp_p.(accel_pos{ii})(index_inset(1):index_inset(2))) max(disp_p.(accel_pos{ii})(index_inset(1):index_inset(2)))];
        yl_inset = yl_inset + 0.1*yl;
        rectangle(ax_primary,'Position', [xl_inset(1),yl_inset(1),xl_inset(2)-xl_inset(1),yl_inset(2)-yl_inset(1)],'EdgeColor','k')
        text(ax_primary,xl_inset(1),yl_inset(2),string(inset),'VerticalAlignment','bottom')
    end
    
end

inset_xlims = [255 265; 330 340; 430 440];
inset_positions_x = [0.4, 0.65, 0.8];
inset_positions_y = [0.83, 0.56, 0.29];
inset_scale = 0.1; 
legend_array = ["Measured"];

for ii = 1:length(accel_pos)
    if accel_pos{ii} == "MP3"
        colorRGB = [0, 0.4470, 0.7410];
    elseif accel_pos{ii} == "MP2"
        colorRGB = [0.8500, 0.3250, 0.0980];
    elseif accel_pos{ii} == "MP1"
        colorRGB = [0.9290, 0.6940, 0.1250];
    end

    for jj = 1:size(inset_xlims,1)
        ax_primary = nexttile(t,3*(ii-1)+jj+3*length(accel_pos));
        hold on
        if ii == length(accel_pos) && jj == size(inset_xlims,1)
            plot(NaN,NaN,'color', [0.3,0.3,0.3])
            for kk = 1:length(accel_pos)
                if accel_pos{kk} == "MP3"
                    colorRGB = [0, 0.4470, 0.7410];
                    legend_array = [legend_array; 'MP3_{accel}'];
                elseif accel_pos{kk} == "MP2"
                    colorRGB = [0.8500, 0.3250, 0.0980];
                    legend_array = [legend_array; 'MP2_{accel}'];
                elseif accel_pos{kk} == "MP1"
                    colorRGB = [0.9290, 0.6940, 0.1250];
                    legend_array = [legend_array; 'MP1_{accel}'];
                end
                plot(NaN,NaN, 'color', colorRGB)
            end
        end
        if accel_pos{ii} == "MP3"
            colorRGB = [0, 0.4470, 0.7410];
        elseif accel_pos{ii} == "MP2"
            colorRGB = [0.8500, 0.3250, 0.0980];
        elseif accel_pos{ii} == "MP1"
            colorRGB = [0.9290, 0.6940, 0.1250];
        end

        plot(time,disp_m.(accel_pos{ii}),'color', [0.3,0.3,0.3])
        plot(time, disp_p.(accel_pos{ii}), 'color', colorRGB)
        xlim(ax_primary, [inset_xlims(jj,1) inset_xlims(jj,2)])

        if length(accel_pos) ~= 1
            title(['MP' + string(ii) + ' , Zoom ' + string(jj)])
        else
            title(['Zoom ' + string(jj)])
        end


    end

end


lgd = legend(ax_primary,legend_array,'Orientation','Horizontal');
lgd.Layout.Tile = 'south';
ylabel(t, 'Displacement (mm)');
xlabel(t, 'Time (s)');

%% Plot absolute error
fig_error = figure;
legend_array = [];

t = tiledlayout(1,1,'TileSpacing','Compact');
nexttile
hold on
for ii = 1:length(accel_pos)
    if accel_pos{ii} == "MP3"
        colorRGB = [0, 0.4470, 0.7410];
        legend_array = [legend_array; 'MP3_{accel}'];
    elseif accel_pos{ii} == "MP2"
        colorRGB = [0.8500, 0.3250, 0.0980];
        legend_array = [legend_array; 'MP2_{accel}'];
    elseif accel_pos{ii} == "MP1"
        colorRGB = [0.9290, 0.6940, 0.1250];
        legend_array = [legend_array; 'MP1_{accel}'];
    end
    
    plot(time, disp_p.(accel_pos{ii})-disp_m.(accel_pos{ii}), 'color', colorRGB)
    xlim(xlim_time)
    % ylim(yl./5)
    % title('Difference')
end
lgd = legend(legend_array,'Orientation','Horizontal','Location','southoutside');
ylabel({'Absolute error', '(mm)'});
xlabel('Time (s)');
fig_error.Position(4) = 200;


%% Plot spectrum
fig_spectrum = figure;
legend_array = ["Measured"];

T = tiledlayout(length(accel_pos),1,'TileSpacing','Compact');
inset_xlims = [0 0.3];
for ii = 1:length(accel_pos)
    t = tiledlayout(T,1,3,'TileSpacing','Compact');
    t.Layout.Tile = ii;
    ax_primary = nexttile(t,[1 2]);
    hold on

    if accel_pos{ii} == "MP3"
        colorRGB = [0, 0.4470, 0.7410];
    elseif accel_pos{ii} == "MP2"
        colorRGB = [0.8500, 0.3250, 0.0980];
    elseif accel_pos{ii} == "MP1"
        colorRGB = [0.9290, 0.6940, 0.1250];
    end
    [pxx,f] = pwelch(disp_m.(accel_pos{ii}),[],[],[],Fs);
    plot(f,10*log10(pxx),'color', [0.3,0.3,0.3])
    [pxx,f] = pwelch(disp_p.(accel_pos{ii}),[],[],[],Fs);
    plot(f,10*log10(pxx), 'color', colorRGB)
    xlim(xlim_spectrum)

    [~,xlims_index] = min(abs(f - inset_xlims));
    yl_inset = [min(10*log10(pxx(xlims_index))), max(10*log10(pxx(xlims_index)))];
    yl_inset = yl_inset  + 0.1*ylim;
    % xl_inset = xlim;
    rectangle(ax_primary,'Position', [xl_inset(1),yl_inset(1),xl_inset(2)-xl_inset(1),yl_inset(2)-yl_inset(1)],'EdgeColor','k')


    ax_primary = nexttile(t);
    hold on
    if ii == length(accel_pos)
        plot(NaN,NaN,'color', [0.3,0.3,0.3])
        for jj = 1:length(accel_pos)
            if accel_pos{jj} == "MP3"
                colorRGB = [0, 0.4470, 0.7410];        
                legend_array = [legend_array; 'MP3_{accel}'];
            elseif accel_pos{jj} == "MP2"
                colorRGB = [0.8500, 0.3250, 0.0980];        
                legend_array = [legend_array; 'MP2_{accel}'];
            elseif accel_pos{jj} == "MP1"
                colorRGB = [0.9290, 0.6940, 0.1250];        
                legend_array = [legend_array; 'MP1_{accel}'];
            end
            % ax_primary.ColorOrderIndex = length(accel_pos)+1-jj;
            plot(NaN,NaN, 'color', colorRGB)
        end
    end
    if accel_pos{ii} == "MP3"
        colorRGB = [0, 0.4470, 0.7410];
    elseif accel_pos{ii} == "MP2"
        colorRGB = [0.8500, 0.3250, 0.0980];
    elseif accel_pos{ii} == "MP1"
        colorRGB = [0.9290, 0.6940, 0.1250];
    end
    hold on
    if ii == length(accel_pos)
        plot(NaN,NaN,'color', [0.3,0.3,0.3])
        for jj = 1:ii
            ax_primary.ColorOrderIndex = length(accel_pos)+1-jj;
            plot(NaN,NaN)
        end
    end
    [pxx,f] = pwelch(disp_m.(accel_pos{ii}),[],[],[],Fs);
    plot(f,10*log10(pxx),'color', [0.3,0.3,0.3])
    [pxx,f] = pwelch(disp_p.(accel_pos{ii}),[],[],[],Fs);
    plot(f,10*log10(pxx), 'color', colorRGB)
    xlim(xlim_spectrum)

    xlim(inset_xlims)

    if length(accel_pos) ~= 1
        t.Title.String = ['Spectrum of the displacement estimation at MP' + string(ii)];
    end 

end


lgd = legend(ax_primary,legend_array,'Orientation','Horizontal');
lgd.Layout.Tile = 'south';
if length(accel_pos) == 1
    ylabel(T,{'Power/Frequency','(dB/Hz)'});
else 
    ylabel(T,'Power/Frequency (dB/Hz)');
end
xlabel(T,'Frequency (Hz)');
fig_spectrum.Position(4) = plot_height;

end



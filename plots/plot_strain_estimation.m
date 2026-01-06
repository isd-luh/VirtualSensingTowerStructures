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
 
function [] = plot_strain_estimation(time, strain_p, strain_m, Fs, varargin)
    % plot_strain_estimation creates plots from the measured and 
    % estimated strain time series (compare Fig. 12-13)
    % 
    % INPUT
    % - time (vector of double)
    %   vector containing time stamps
    % - strain_p (struct containing vector of double)
    %   struct containing estimated strain time series for each predicted MP
    % - strain_m (struct containing vector of double)
    %   struct containing measured strain time series for each predicted MP
    % - Fs (double)
    %   sampling frequency
    % - varargin{1} (vector of double)
    %   x-limits time series plot
    % - varargin{2} (vector of double)
    %   x-limits spectrum
    % OUTPUT

% % Setting optional parameters
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
strain_pos = fieldnames(strain_p);

% Plot size
if length(strain_pos) > 1
    plot_height = 350;
else
    plot_height = 235;
end

% Convert units
for ii = 1:length(strain_pos)
    field = strain_pos{ii};
    strain_p.(field) = 10^6.*strain_p.(field);
    strain_m.(field) = 10^6.*strain_m.(field);
end



%% Plot estimation + zoom
fig_estimation_zoom = figure;
t = tiledlayout(2*length(strain_pos),3,'TileSpacing','Compact');
inset_xlims = [255 265; 330 340; 430 440];
inset_positions_x = [0.4, 0.65, 0.8];
inset_positions_y = [0.83, 0.43];
inset_scale = 0.1; 

for ii = 1:length(strain_pos)
    ax_primary = nexttile(t,[1 3]);
    hold on
    plot(time,strain_m.(strain_pos{ii}),'color', "#000000")
    for col = 1:size(strain_p.(strain_pos{ii}),2)
        ax_primary.ColorOrderIndex = size(strain_p.(strain_pos{ii}),2)+1-col;
        plot(time, strain_p.(strain_pos{ii})(:,col))
    end
    xlim(xlim_time)
    yl = ylim();
    yl = [-max(abs(strain_m.(strain_pos{ii})))*1.2 max(abs(strain_m.(strain_pos{ii})))*1.2];
    ylim(yl);

    if length(strain_pos) ~= 1
        if strain_pos{ii} == "MP5"
            title('Strain estimation at MP5')
        elseif strain_pos{ii} == "MP4"
            title('Strain estimation at MP4')
        end
    end

    for inset = 1:length(inset_positions_x)
        xl_inset = inset_xlims(inset,1:2);
        [~,index_inset(1)] = min(abs(time - xl_inset(1)));
        [~,index_inset(2)] = min(abs(time - xl_inset(2)));
        yl_inset = [min(strain_m.(strain_pos{ii})(index_inset(1):index_inset(2))) max(strain_m.(strain_pos{ii})(index_inset(1):index_inset(2)))];
        yl_inset = yl_inset + 0.1*yl;
        rectangle(ax_primary, 'Position', [xl_inset(1),yl_inset(1),xl_inset(2)-xl_inset(1),yl_inset(2)-yl_inset(1)],'EdgeColor','k')
        text(ax_primary, xl_inset(1),yl_inset(2),string(inset),'VerticalAlignment','bottom')
    end
end

inset_xlims = [255 265, 330 340, 430 440];
inset_positions_x = [0.4, 0.65, 0.8];
inset_positions_y = [0.83, 0.43];
inset_scale = 0.1; 

for ii = 1:length(strain_pos)
    for jj = 1:length(inset_xlims)/2
        ax_primary = nexttile(t,3*(ii-1)+jj+3*length(strain_pos));
        hold on
        plot(time,strain_m.(strain_pos{ii}),'color', "#000000")
        for col = 1:size(strain_p.(strain_pos{ii}),2)
            ax_primary.ColorOrderIndex = size(strain_p.(strain_pos{ii}),2)+1-col;
            plot(time, strain_p.(strain_pos{ii})(:,col))
        end
        xlim(ax_primary, [inset_xlims(jj*2-1) inset_xlims(jj*2)])
        
        if length(strain_pos) ~= 1
            if strain_pos{ii} == "MP5"
                title(['MP5 , Zoom ' + string(jj)])
            elseif strain_pos{ii} == "MP4"
                title(['MP4 , Zoom ' + string(jj)])
            end
        else
            if strain_pos{ii} == "MP5"
                title(['Zoom ' + string(jj)])
            elseif strain_pos{ii} == "MP4"
                title(['Zoom ' + string(jj)])
            end
        end

    end
end
lgd = legend(ax_primary,'Measured ', 'MP1_{accel}', 'MP2_{accel}', 'MP3_{accel}','Orientation','Horizontal');
lgd.Layout.Tile = 'south';
ylabel(t,'Strain (\mum/m)');
xlabel(t,'Time (s)');



%% Plot spectrum
fig_spectrum = figure;
T = tiledlayout(length(strain_pos),1,'TileSpacing','Compact');
inset_xlims = [0 0.3];
for ii = 1:length(strain_pos)
    t = tiledlayout(T,1,3,'TileSpacing','Compact');
    t.Layout.Tile = ii;
    ax_primary = nexttile(t,[1 2]);
    hold on
    [pxx,f] = pwelch(strain_m.(strain_pos{ii}),[],[],[],Fs);
    plot(f,10*log10(pxx),'color', "#000000")
    for col = 1:size(strain_p.(strain_pos{ii}),2)
        ax_primary.ColorOrderIndex = size(strain_p.(strain_pos{ii}),2)+1-col;
        [pxx,f] = pwelch(strain_p.(strain_pos{ii})(:,col),[],[],[],Fs);
        plot(f,10*log10(pxx))
    end

    xlim(xlim_spectrum)

    yl_inset = ylim;
    [~,xlims_index] = min(abs(f - inset_xlims));
    yl_inset = [min(10*log10(pxx(xlims_index))), max(10*log10(pxx(xlims_index)))];
    yl_inset = yl_inset  + 0.1*ylim;
    rectangle(ax_primary,'Position', [xl_inset(1),yl_inset(1),xl_inset(2)-xl_inset(1),yl_inset(2)-yl_inset(1)],'EdgeColor','k')


    ax_primary = nexttile(t);
    hold on
    [pxx,f] = pwelch(strain_m.(strain_pos{ii}),[],[],[],Fs);
    plot(f,10*log10(pxx),'color', "#000000")
    for col = 1:size(strain_p.(strain_pos{ii}),2)
        ax_primary.ColorOrderIndex = size(strain_p.(strain_pos{ii}),2)+1-col;
        [pxx,f] = pwelch(strain_p.(strain_pos{ii})(:,col),[],[],[],Fs);
        plot(f,10*log10(pxx))
    end

    xlim(inset_xlims)

    if length(strain_pos) ~= 1
        if strain_pos{ii} == "MP5"
            t.Title.String = ('Spectrum of the strain estimation at MP5');
        elseif strain_pos{ii} == "MP4"
            t.Title.String = ('Spectrum of the strain estimation at MP4');
        end
    end

end


lgd = legend(ax_primary,'Measured ', 'MP1_{accel}', 'MP2_{accel}', 'MP3_{accel}','Orientation','Horizontal');
lgd.Layout.Tile = 'south';
if length(strain_pos) == 1
    ylabel(T,{'Power/Frequency','(dB/Hz)'});
else 
    ylabel(T,'Power/Frequency (dB/Hz)');
end
xlabel(T,'Frequency (Hz)');
fig_spectrum.Position(4) = plot_height;



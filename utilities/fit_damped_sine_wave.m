function [lambda,fit_parameters,r_squared,y_fit]= ...
    fit_damped_sine_wave(varargin)
% Functions fits damped sine wave

params.x_data=[];
params.y_data=[];
params.min_x_index_spacing=[];
params.min_lambda=[];
params.max_lambda=[];

params=parse_pv_pairs(params,varargin);

x_data=params.x_data;
y_data=params.y_data;

% plot(y_data)
% Some error checking
no_of_points=length(x_data);
if (length(y_data)~=no_of_points)
    error('No of points in x and y data sets differ (fit_sine_wave)');
end

% Find first two peaks
pd=find_peaks('x',x_data,'y',y_data, ...
    'min_x_index_spacing',params.min_x_index_spacing, ...
    'min_rel_delta_y',0.1);

xd=x_data;

% Initial guess
p(1)=0.01;
p(2)=0.5*(max(y_data)-min(y_data));
p(4)=NaN;
peak_indices = x_data(pd.max_indices);
if (numel(peak_indices>2))
    diff_peak_indices=diff(peak_indices);
    min_lambda = 0.5*median(diff_peak_indices);
    max_lambda = 1.25*median(diff_peak_indices);
    p(4)=median(diff_peak_indices);
    p(3) = p(4) + p(4)/4 - peak_indices(1);
    if ((p(3)<0)||(p(3)>p(4)))
        p(3)=p(4)/2;
    end
else
    lambda=NaN;
    fit_parameters=NaN*ones(1,4);
    r_squared=NaN;
    y_fit=NaN;
    return;
end

p=p;
lower_bounds=[0 0.25*(max(y_data)-min(y_data)) 0 min_lambda];
upper_bounds=[1 0.75*(max(y_data)-min(y_data)) max_lambda max_lambda];

draw_graph=0;
if (draw_graph)
of=gcf;
end

draw_graph2=0;
if (draw_graph2)
    of=gcf;
    figure(13);
    clf;
    hold on;
    fit=p(1)+p(2)*sin(2*pi*(x_data+p(3))./p(4));
    plot(x_data,fit,'r-s');
    plot(x_data,y_data,'bo');
    figure(of);
end

% Fit
p=fminsearchbnd(@sine_wave_fit,p,lower_bounds,upper_bounds, ...
    [],x_data,y_data,draw_graph);

fit=exp(-p(1)*x_data).*p(2).*sin(2*pi*(x_data+p(3))./p(4));

lambda=p(4);
fit_parameters=p;
r_squared=calculate_r_squared(y_data,fit);
y_fit=fit;

if (draw_graph)
figure(of);
end


function error = sine_wave_fit(p,x,y,draw_graph)

fit=exp(-p(1)*x).*p(2).*sin(2*pi*(x+p(3))./p(4));
error=sum((fit-y).^2);

if (draw_graph)
figure(10);
plot(x,y,'b-',x,fit,'r-');
pause(0.2)
end

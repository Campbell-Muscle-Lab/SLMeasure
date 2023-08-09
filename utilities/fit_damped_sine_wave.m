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
% pd=find_peaks('x',x_data,'y',y_data, ...
%     'min_x_index_spacing',params.min_x_index_spacing, ...
%     'min_rel_delta_y',0.05);

[pks,locs] = findpeaks(y_data);

pd.max_indices = locs;
xd=x_data;

% Initial guess
p(1) = 0.2;
p(2) = 1;
p(3) = 0;
if (length(pd.max_indices)>=2)
    peak_diff = diff(pd.max_indices);
    p(4) = median(peak_diff);
else 
    p(4) = 15;
end

p=p;
lower_bounds=[0 0 -inf eps];
upper_bounds=[inf inf inf inf];

% Fit
p=fminsearchbnd(@sine_wave_fit,p,lower_bounds,upper_bounds, ...
    [],x_data,y_data);

fit=exp(-p(1)*x_data).*p(2).*sin(2*pi*(x_data+p(3))./p(4));

lambda=p(4);
fit_parameters=p;
r_squared=calculate_r_squared(y_data,fit);
y_fit=fit;

end


function error = sine_wave_fit(p,x,y)

fit=exp(-p(1)*x).*p(2).*sin(2*pi*(x+p(3))./p(4));
error=sum((fit-y).^2);

end

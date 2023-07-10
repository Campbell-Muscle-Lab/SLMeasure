function [r_auto,sl_ac,fit_parameters] = sarcomere_autoc(z_profile,px_cal)


Y = im2double(z_profile);
n = length(Y(1,:));
lags = length(Y(1,:))/2;

for m = 1 : size(Y,1)
    Y_bar = mean(Y(m,:));
    Y_rss = sum((Y(m,:)-Y_bar).^2);
    for k = 1 : lags
        Y_sum_num = 0;
        for i = k+1 : n
            Y_sum_num = Y_sum_num + (Y(m,i) - Y_bar) .* (Y(m,i-k) - Y_bar);
        end
        autoc(:,k+1) = Y_sum_num./Y_rss;
    end
    r_auto(m,:) = autoc;
    r_auto(m,1) = sum((Y(m,:)-Y_bar).*(Y(m,:)-Y_bar))/Y_rss;

end

if size(Y,1) ~= 1
r_auto = mean(r_auto);
end

[lambda,fit_parameters,r_squared,y_fit] = fit_sine_wave('y_data',r_auto,...
    'x_data',0:lags, 'min_x_index_spacing',1);
sl_ac = fit_parameters(4) * px_cal;

end
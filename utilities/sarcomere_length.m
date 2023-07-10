function [sl_fft, sl_ac] = sarcomere_length(varargin)

p = inputParser;
addOptional(p,'image',zeros(256,64,3,'uint8'))
addOptional(p,'pos',[])
addOptional(p,'px_cal', 0.2110)

parse(p,varargin{:});
p = p.Results;


% p.image = imread('imagesutku2.tif');
% p.image = rgb2gray(p.image)

pos = [150 150 200 100]

%pos = round(p.pos);

h_line_1 = pos(2);
h_line_2 = pos(2) + pos(4);
ROI_start = pos(1);
ROI_end = pos(1) + pos(3);

z_profile = p.image(h_line_1:h_line_2,ROI_start:ROI_end);
x = 1:pos(3)+1;

[Z, sl_fft, fft_ix] = sarcomere_fft('input', z_profile, ...
    'cal_cst', p.px_cal, 'fft_direction', 2);

[r_auto,sl_ac,fit_parameters] = sarcomere_autoc(z_profile,p.px_cal);


fprintf('Sarcomere length from FFT: %0.4f um\n', sl_fft)
fprintf('Sarcomere length  from AC: %0.4f um\n', sl_ac)

figure(1)
clf

subplot(3,1,1)
imagesc(p.image)
hold on
drawrectangle('Position',[ROI_start,h_line_1, ...
    ROI_end-ROI_start,h_line_2-h_line_1],'Color','r');

subplot(3,1,2)
plot(x,mean(z_profile),'Color','b','LineWidth',1.15)
xlabel('Pixel')
ylabel('Intensity')

% subplot(3,1,2)
% plot(0:numel(Z)-1,abs(Z),'LineWidth',1.15)
% xlabel('Frequency Bins')
% ylabel('FFT Magnitude')
% text(150,10*max_mag,sprintf('Sarcomere length is %0.4f um',sl_fft))
% axes('Position',[.28 .28 .15 .15])
% box on
% plot(fft_ix(2:70),abs(Z(2:70)),'LineWidth',1.15);
% xlabel('Frequency (Pixel^{-1})')
% ylabel('FFT Magnitude')
% xlim([fft_ix(2) fft_ix(70)])
% 
% 
% subplot(3,1,3)
% plot(0:numel(r_auto)-1,r_auto, 'LineWidth',1.15)
% hold on
% plot(0:numel(r_auto)-1, y_fit,'LineWidth',1.15)
% xlabel('Delay (Pixel)')
% ylabel('Autocorrelation Coefficient')
% xlim([1 numel(z_profile)])
% eqn = sprintf('AC Fit = %0.2f e^{ %0.2f x} * sin(2pi(x + %0.2f)/%0.2f)', ...
%     fit_parameters(1),...
%     fit_parameters(2),fit_parameters(3),fit_parameters(4));
% text(numel(z_profile)-300,0.9,eqn)
% text(numel(z_profile)-300,0.7,sprintf('Sarcomere length is %0.4f um',sl_ac))
% legend('AC','Damped Sine Fit','Location','southeast')

end


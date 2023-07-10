function [Z, sl_fft, fft_ix] = sarcomere_fft(varargin)

p = inputParser;
addOptional(p,'fft_direction',1)
addOptional(p,'input',[])
addOptional(p,'cal_cst',1)

parse(p,varargin{:});
p = p.Results;

if p.fft_direction ~= 1
Z = fft(p.input,[],p.fft_direction);
Z = mean(Z);
else
Z = fft(p.input);
end

fft_ix = (1:numel(Z)-1)/(numel(Z)*p.cal_cst);
fft_ix = [0 fft_ix];

[max_mag, max_ix] = max(abs(Z(2:end/2+1)));
sl_fft = numel(Z)*p.cal_cst/max_ix;

end
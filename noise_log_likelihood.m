function [logp, location_score] = noise_log_likelihood(residual, noise_std, distribution)
% Gaussian/Laplace additive noise adapted from rhymesg/MC_CRB_nonGaussian/loglikelihood_TRN.m.
% Scale, score convention, and upstream attribution: docs/statistical-information.md.
validateattributes(residual, {'double'}, {'real', 'finite', '2d', 'nonempty'});
validateattributes(noise_std, {'double'}, {'real', 'finite', '2d', 'positive', 'nonempty'});
if ~isscalar(noise_std) && ~isequal(size(noise_std), size(residual))
    error('tracking:NoiseShape', 'Noise standard deviation must be scalar or match the residual array.');
end
scaled = residual ./ noise_std;
switch distribution
    case 'gaussian'
        logp = -0.5*log(2*pi) - log(noise_std) - (scaled/sqrt(2)).^2;
        location_score = scaled ./ noise_std;
    case 'laplace'
        logp = -0.5*log(2) - log(noise_std) - sqrt(2)*abs(scaled);
        location_score = sign(residual) .* (sqrt(2) ./ noise_std);
    otherwise
        error('tracking:NoiseDistribution', 'Distribution must be gaussian or laplace.');
end
if any(~isfinite(logp(:))) || any(~isfinite(location_score(:)))
    error('tracking:NumericalRange', 'Log density or score is outside the finite numerical range.');
end
end

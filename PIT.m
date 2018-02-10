function [varargout] = PIT( x, ens )
% function [pitvals,Alpha,Xi] = pit( x, ens )
% Compute PIT (Probability Integral Transform) of observation for k time
% steps
%
%   INPUTS:
%       x     - target values series [k,1]
%       ens   - predictive ensembles series [k,m]
%
%   OUTPUTS:
%       varargout = 1 > pitvals - individual PIT values [k2,1]: k2 = number
%                                 of non-missing data
%       varargout = 2 > Alpha   - complement of area between the cdf of PIT
%                                 values and the bisector (optimal Alpha=1) [1,1]
%       varargout = 3 > Xi      - complement of Xi' (fraction of observations
%                                 located outside of the ensemble range) (optimal Xi=1) [1,1]
%
%   References:
%       [1] Diebold F.X., Gunther, T.A., Tay, A.S.,1998. Evaluating Density
%           Forecasts with Applications to Financial Risk Management.
%           Internationa1 Economic Review, Vol. 39, No. 4, Symposium on
%           Forecasting and Empirical Methods in Macroeconomics and Finance
%            pp. 863-883.
%       [2] Laio F., Tamea, S.,2007. Verification tools for probabilistic
%           forecasts of continuous hydrological variables. Hydrology and
%           Earth System Sciences 11, 1267-1277.
%       [3] Renard B., Kavetski, D., Kuczera, G., Thyer, M., Franks, S.W.,2010.
%	    Understanding predictive uncertainty in hydrologic modeling: The
%	    challenge of identifying input and structural errors. Water 
%	    Resources Research, Vol. 46., W05521, 22 pages
%
%% Exemple :
% clear, clc, close all
% % Size data
% ndata = 500;
% nens = 50;
% nmiss = ceil(0.05*ndata);
% % target
% x = 50*cos(linspace(0, 16*pi, ndata))'+100;
% % target with NaN values
% x(ceil(ndata*rand(round(nmiss/2),1))) = NaN;
% % ensemble with noise
% ens  = repmat(x,1,nens) + 20* (0.5-rand(ndata,nens));
% % compute PIT
% [pitvals,Alpha,Xi] = PIT(x, ens);
% % plot (PIT diagram)
% pitvals_sorted = sort(pitvals);
% [~, rnk] = ismember(pitvals,pitvals_sorted);
% scatter(pitvals,rnk/size(pitvals,1));hold on;grid on;xlimits = [0 1];
% ylimits = [0 1];ylim manual;ylim(ylimits);xlim manual;xlim(xlimits);
% plot([0 1],[0 1],'red','LineWidth',2); hold off
% title( ['PIT diagram, alpha = ' sprintf('%3.2f',Alpha) ', xi = ' sprintf('%3.2f',Xi)] )
%
%
%   Revision: 0.0 Date: 2018/02/05 Carine Poncelet
%           original function


%% Clean data

% Check for coherent data dimensions
if size(x,1) ~= size(ens,1); error('Mismatch of x and ens dimensions'); end
if sum(any(~isnan(ens),2))==0; error('The ensemble contains NaNs for every time steps'); end

% Identify no data values
idxPos = x >= 0; % indices where x is positive
idxNotNaN = ~isnan(x); % indices where x is not a NaN
idensPos = all(ens >= 0, 2); % indices where ens is positive
idensNotNaN = all(~isnan(ens), 2); % indices where ens is not a NaN
idKeep = idxPos & idxNotNaN & idensPos & idensNotNaN;

% Clean data
x = x(idKeep);
ens = ens(idKeep,:);

%% Compute PIT values

% Initialize objects
pitvals = nan(size(x,1),1);

% Time steps loop
for t=1:size(x,1)
    [F, X] = ecdf( ens(t,:) );     % compute ensemble ecdf
    
    % retrieve PIT of observation
    if x(t,1) >= min(ens(t,:)) && x(t,1) <= max(ens(t,:))
        pitvals(t,1) = max( F(X<=x(t,1)) ); 
    elseif x(t,1) <= min(ens(t,:))
        pitvals(t,1) = 0;
    elseif x(t,1) >= max(ens(t,:))
        pitvals(t,1) = 1;
    end
end

%% Compute additionnal outputs

% Alpha
pitvals_sorted = sort(pitvals);
[~, rnk] = ismember(pitvals,pitvals_sorted);
Alpha = 1 - 2 * mean( abs( rnk/size(pitvals,1) - pitvals ) ) ;

% Xi
xi_cmplt = zeros(size(pitvals,1),1);
xi_cmplt(pitvals == 0) = 1;
xi_cmplt(pitvals == 1) = 1;
Xi = 1 - mean(xi_cmplt(:)) ;

%% Export results
nout = max(nargout,1);

if nout > 0, varargout(1) = {pitvals}; end
if nout > 1, varargout(2) = {Alpha};   end
if nout > 2, varargout(3) = {Xi};  end

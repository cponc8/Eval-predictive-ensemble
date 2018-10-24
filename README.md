# eval-predict-ens

## Overview
This project aims at providing some functions to evaluate the performance of predicitive ensembles.

## Prerequisites
* Matlab software

## Content
* _PIT.m_ a function to compute the Probability Interval Transform of the predictive ensemble


## Working example
```matlab
%% Produce synthetic data
% Size data
ndata = 500;
nens = 50;
nmiss = ceil(0.05*ndata);
% target
x = 50*cos(linspace(0, 16*pi, ndata))'+100;
% target with NaN values
x(ceil(ndata*rand(round(nmiss/2),1))) = NaN;
% ensemble with noise
ens  = repmat(x,1,nens) + 20* (0.5-rand(ndata,nens));

%% Compute PIT
[pitvals,Alpha,Xi] = PIT(x, ens);

%% plot (PIT diagram)
pitvals_sorted = sort(pitvals);
[~, rnk] = ismember(pitvals,pitvals_sorted);
scatter(pitvals,rnk/size(pitvals,1));hold on;grid on;xlimits = [0 1];
ylimits = [0 1];ylim manual;ylim(ylimits);xlim manual;xlim(xlimits);
plot([0 1],[0 1],'red','LineWidth',2); hold off
title( ['PIT diagram, alpha = ' sprintf('%3.2f',Alpha) ', xi = ' sprintf('%3.2f',Xi)] )

```

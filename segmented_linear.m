function [i_knee, varargout] = segmented_linear(roc, knee_range, doplot)
%
% by Jeff Weiler, Paul Gribble, Andrew Pruzynski
% 
% This function takes the area under an ROC curve as a function of time (roc), and a time 
% range to search for the knee point (knee_range = [start, stop]).  The function
% finds the knee point that minimizes the sum of squared error between the
% roc and a segmented linear function which is defined by
%   the mean of the roc up to the knee point,
%   and after the knee point, a linear function starting at the mean and rising
% to the point on the roc where it first rises above UB or below LB for 3 consecutive samples
%
% if doplot==1, a plot will be generated to visualize the result
% 
% the function will return the index into the roc corresponding to the knee
% point (this is called i_knee)


i_knee = NaN;
varargout = {nan, nan};
window_width = 3;

%%
% find first index into roc where the roc rises above UB OR falls below
% LB; this index is called first_reliable_departure_from_chance
%
[LB,UB] = deal(.25, .75);
n_samples = numel(roc);

first_reliable_departure_from_chance = find((roc(knee_range(1):knee_range(2)) >= UB) | (roc(knee_range(1):knee_range(2)) <= LB),1);
if isempty(first_reliable_departure_from_chance) % if we didn't find any, stop and return NaN
    % if doplot==1, generate a plot to visualize the result
    if (doplot)
        plot(roc, 'r.-')
        hold on
        plot([knee_range(1), knee_range(1)], [0 1], 'k-')
        plot([knee_range(2), knee_range(2)], [0 1], 'k-')
        plot([knee_range(1), knee_range(2)], [0.5 0.5], 'k--')
        plot([knee_range(1), knee_range(2)], [LB LB], 'k--')
        plot([knee_range(1), knee_range(2)], [UB UB], 'k--')
        ylim([0 1])
        xlim([1 n_samples])
    end
    
    return
end

%%
% find the first index into the roc where the roc stays above UB (or below LB) for three
% consecutive samples. This index is called i7525
% search for i7525 between sample_range(1) and sample_range(2)
%
i7525 = knee_range(1) + first_reliable_departure_from_chance - 1;
window = i7525 : (i7525+window_width-1);
found = false;

while (found==false && window(end)<(knee_range(2)))
    
    window = i7525 : (i7525+window_width-1);

    if ( all(roc(window)>UB) || all(roc(window)<LB) )
        found = true;
    else
        i7525 = i7525 + 1;
    end
end
if (found==false) % if we didn't find any, stop and return NaN
    
    % if doplot==1, generate a plot to visualize the result
    if (doplot)
        plot(roc, 'r.-')
        hold on
        plot([knee_range(1), knee_range(1)], [0 1], 'k-')
        plot([knee_range(2), knee_range(2)], [0 1], 'k-')
        plot([knee_range(1), knee_range(2)], [0.5 0.5], 'k--')
        plot([knee_range(1), knee_range(2)], [LB LB], 'k--')
        plot([knee_range(1), knee_range(2)], [UB UB], 'k--')
        ylim([0 1])
        xlim([1 n_samples])
    end
    
    return
end

%%
% for every possible knee point between knee_range(1) and i75,
% compute the SSE between the roc curve and the corresponding segmented 
% linear function
% 
tstart = knee_range(1);             % the first possible knee point
tstop = i7525;                      % the last possible knee point
bestline_y = zeros(1,tstop-tstart+1);% initialize segmented fit to vector of zeroes
SSE = zeros(1,tstop-tstart);        % initialize a vector to store SSEs to zeroes
for i = 1:(tstop-tstart+1)          % for every potential knee point
    bestline_y(1:i) = mean(roc(tstart:tstart+i));
    bestline_y(i:end) = linspace(bestline_y(i), roc(tstop), length(bestline_y(i:end)));
    SSE(i) = sum((roc(tstart:tstop) - bestline_y).^2);
end

%%
% find the index into SSE vector corresponding to the minimum SSE
% this is called i_min. Add it to tstart to get the knee point.
% this is called i_knee
%
[SSEmin,i_min] = min(SSE);
i_knee = i_min + tstart - 1;
        
%%
% if doplot==1, generate a plot to visualize the result
%
bestline_y = zeros(1,tstop-tstart+1);
bestline_y(1:i_min) = mean(roc(tstart:i_knee));
bestline_y(i_min:end) = linspace(bestline_y(i_min), roc(tstop), length(bestline_y(i_min:end)));
bestline_x = (1:length(bestline_y))+tstart-1;
varargout = {bestline_x, bestline_y};

if (doplot)
    plot(roc, 'r.-')
    hold on
    plot(bestline_x, bestline_y, 'b-', 'linewidth',2)
    plot([knee_range(1), knee_range(1)], [0 1], 'k-')
    plot([knee_range(2), knee_range(2)], [0 1], 'k-')
    plot([knee_range(1), knee_range(2)], [0.5 0.5], 'k--')
    plot([knee_range(1), knee_range(2)], [LB LB], 'k--')
    plot([knee_range(1), knee_range(2)], [UB UB], 'k--')
    plot([i_knee i_knee], get(gca,'ylim'), 'b--')
    text(i_knee-30,0.92,num2str(i_knee),'color','b')
    ylim([0 1])
end
   
end

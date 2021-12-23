clearvars
close all

n_t = 200; % number of timesteps
n_s = 15; % number of signals per group

slope_array = 0.005 * randn(n_s, 1); % random distribution of slopes

% let's say all group 1 signals have slope > 0 (ROC can handle non-equal group sizes)
% let's say all group 2 signals have slope < 0 
labels = sign(slope_array) == 1;

signals = create_dummy_signal(n_s, n_t, 0.3, floor(n_t/2), slope_array);

figure(1); clf;
h(1) = subplot(1,3,1);
plot(signals( labels,:)', 'color', [1 0 0]); hold on
plot(signals(~labels,:)', 'color', [0 0 0]);
h(1).Title.String = 'raw signals';
h(1).XLabel.String = 'timestep';
h(1).YLabel.String = '(signal unit)';


% let's get the area under the true positive rate (TPR) against
% the false positive rate (FPR) curve. This is usually called the 'area
% under curve' (AUC)
h(2) = subplot(1,3,2);
[AUC,fpr,tpr] = fastAUC( repmat(labels,[1,n_t]) ,signals ,true );


% let's find the divergence point (the 'knee') of the area under curve using a two-line regression fit
h(3) = subplot(1,3,3);
knee_range = [50, n_t]; % let's say we know the divergence is somewhere between the 50th and last timestep, but not before
[i_knee , bestfit_x , bestfit_y] = segmented_linear( AUC, knee_range, 1 );
h(3).XLabel.String = 'timestep';
h(3).YLabel.String = 'area under curve';

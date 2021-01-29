function dummy_signal = create_dummy_signal(n_signals, n_time_steps, noise, divergence_point, divergence_slope)

if divergence_point > n_time_steps
    error('The divergence point should be smaller than the total number of timesteps.')
end

random_walk = noise * randn(n_signals, n_time_steps);

divergence_ramp = 0 : (n_time_steps - divergence_point);
diverging_segment = random_walk(:, divergence_point:end) + divergence_slope .* divergence_ramp;

dummy_signal = cat(2, random_walk(:, 1:(divergence_point-1)), diverging_segment);

end
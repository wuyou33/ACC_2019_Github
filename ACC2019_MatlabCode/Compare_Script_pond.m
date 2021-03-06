%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Analysis of results, pond example
% AUTHOR: Margaret Chapman
% DATE: September 6, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Compare [Monte Carlo, max] vs. [Dynamic Programming, soft-max], improved P & ws

close all; clearvars; clc;

load('Pond_Results\more_accurate_probdist\monte_carlo\monte_carlo_max_sept112018.mat');
% Results from Main_MonteCarlo_Pond.m, type_sum = 0, g(x) = x - 5, nt = 100,000, improved P & ws 
% J0(x,y) := min_pi CVaR_y[ max{ g(xk) : k = 0,...,N } | x0 = x, pi ] via Monte Carlo for pond example

J0_cost_max = J0_MonteCarlo;

load('Pond_Results\more_accurate_probdist\dyn_prog\dyn_prog_results_sept112018.mat');
% Results from Main_DynProgram_Pond.m, m = 10, beta = 10^(-3), g(x) = x - 5, improved P & ws
% J0(x,y) := min_pi CVaR_y[ beta*exp(m*g(x0)) + ... + beta*exp(m*g(xN)) | x0 = x, pi ] via dyn. prog. for pond example

J0_cost_sum = Js{1}; beta = 10^(-3); % see stage_cost_pond.m

rs = linspace( 1.5, 0.25, 6 ); % risk levels to be plotted, choose min to be slightly bigger than min(min(J0_cost_max))
rs = [rs(1), rs(4), rs(2), rs(5), rs(3), rs(6)]; % so risk levels decrease sequentially along each column in figure

[ U, S ] = getRiskySets_pond( ls, xs, rs, m, J0_cost_sum, J0_cost_max, beta, 2 );

%% Compare [Monte Carlo, soft-max] vs. Dynamic Programming, soft-max] to justify nt = 100,000

% m = 10, beta = 10^(-3), g(x) = x - 5, improved P & ws
% J0(x,y) := min_pi CVaR_y[ beta*exp(m*g(x0)) + ... + beta*exp(m*g(xN)) | x0 = x, pi ]

close all; clearvars; clc;

load('Pond_Results\more_accurate_probdist\dyn_prog\dyn_prog_results_sept112018.mat');
% Results from Main_DynProgram_Pond.m
J0_DP = Js{1};

load('Pond_Results\more_accurate_probdist\monte_carlo\monte_carlo_sum_sept112018.mat');
% Results from Main_MonteCarlo_Pond.m, nt = 100000; ~N(0, small_sd = 10^(-7)), add small Gaussian noise 
J0_MC = J0_MonteCarlo;

diff_mc = abs( J0_DP - J0_MC )./J0_MC;      % element-wise difference normalized by mc estimate

avg_diff_mc = mean( diff_mc(:) );           % 1.4027

max_diff_mc = max( diff_mc(:) );            % 18.6943

diff_dp = abs( J0_DP - J0_MC )./J0_DP;      % element-wise difference normalized by dp estimate

avg_diff_dp = mean( diff_dp(:) );           % 0.2331

max_diff_dp = max( diff_dp(:) );            % 0.9492

%% OLD: Compares [Monte Carlo, max] vs. [Dynamic Programming, soft-max] 

close all; clearvars; clc;

% Results from Main_MonteCarlo_Pond.m, type_sum = 0, g(x) = x - 5 
% J0(x,y) := min_pi CVaR_y[ max{ g(xk) : k = 0,...,N } | x0 = x, pi ] via Monte Carlo for pond example
% Added zero-mean Gaussian noise with small standard deviation (10^-12) to cost realization 
load('Pond_Results\monte_carlo_max_pond_results\monte_carlo_max_nt1million.mat'); 
J0_cost_max_MORE = J0_MonteCarlo; % nt = 10^6, trials per (x,y)

load('Pond_Results\monte_carlo_max_pond_results\monte_carlo_nt100000\monte_carlo_max_nt100000.mat');
J0_cost_max_LESS = J0_MonteCarlo; % nt = 100 thousand, trials per (x,y) 

diff_mc = abs( J0_cost_max_MORE - J0_cost_max_LESS ); mc_max_diff = max( diff_mc(:) ); % is equal to 0.0272


% Results from Main_DynamicProgramming_Pond.m, m = 10, beta = 10^(-3), g(x) = x - 5
% J0(x,y) := min_pi CVaR_y[ beta*exp(m*g(x0)) + ... + beta*exp(m*g(xN)) | x0 = x, pi ] via dynamic programming for pond example
load('Pond_Results\dyn_prog_m10_beta10minus3_mosektry\dyn_prog_m10_beta10minus3_gline.mat');
J0_cost_sum = Js{1}; beta = 10^(-3); % see stage_cost_pond.m

rs = [ 1, 0.5, 0.25, 0, -0.25, -0.5 ]; % risk levels to be plotted

[ U, S_MORE ] = getRiskySets_pond( ls, xs, rs, m, J0_cost_sum, J0_cost_max_MORE, beta, 1 );

[ U, S_LESS ] = getRiskySets_pond( ls, xs, rs, m, J0_cost_sum, J0_cost_max_LESS, beta, 2 );

for r_index = 1 : length(rs) 
    for l_index = 1 : length(ls)
        if ~isequal( S_MORE{r_index}{l_index}, S_LESS{r_index}{l_index} ) 
            disp( ['S_MORE, S_LESS do not match at y = ', num2str(ls(l_index)), ' r = ', num2str(rs(r_index))] );
            state_diff = setdiff( S_LESS{r_index}{l_index}, S_MORE{r_index}{l_index} ); 
            disp( ['S_LESS contains x = ', num2str(state_diff), ' but, S_MORE does not.'] );
        end
    end
end
% Risk-sensitive safe sets generated by Monte Carlo (S_MORE: nt = 1 million; S_LESS: nt = 100 thousand )
% are quite similar. So, we will report the results for the fewer iterations.
% In particular, for our risk levels and confidence levels, they differed at one state.
% x = 1.6 \in risk-sensitive set, nt = 100 thousand, r = 1, y = 0.001
% x = 1.6 \notin risk-sensitive safe set, nt = 1 million, r = 1, y = 0.001




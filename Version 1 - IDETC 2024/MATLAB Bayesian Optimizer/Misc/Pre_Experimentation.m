%Pre_Experimentation.m
%This was just testing on the adjusted Latin Hypercube Sampling System
%And I guess this was how I pulled

format compact
rng default
%Part 1: Sampling for the Synthetic

CC = 4:2:30;
S = 200:10:280;

initial_design_points = Adjusted_LHS(8, CC,S)


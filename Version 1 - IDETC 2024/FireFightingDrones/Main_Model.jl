# This file initializes the model using the
# It can then be called by other files for analysis
# includes logic to allow for the model to be initialized for the purpose of tuning only (IE only patch agents)

using Agents, Random

include("Model_Agents.jl")


function forest_fire(; 
    n_uav = 25, #number of uav
    uav_speed = 200, # m/min (m/step)       
    n_x_cells = 100, #number of cells in x direction (use 50 for the figure in the paper but mention that the actual one uses more but that's impossible to see)
    radius_burn = 5.0, # distance between cells (use 100 for the figure)
    burn_time = 60, # mean min (steps) for burning
    prob_burn = 0.016*2.5, # mean prob it will catch fire next to a burning tree (let's change this later)
    first_burn = :center, #scenario
    fire_delay = 10, #adding delay into simulation before coordinator "notices" fire
    tree_UQ = (6, 0.004), #uncertainty in tree parameters 
    seed = 2, #random seed for repeatable results
    tune_model = false, #keyword to just look at model for tuning purposes
    battery_max = 120, #des
    battery_recharge = 30, #note, for this experiment, we're going to assume that reset time and recharge time are proportionally the same
    suppressant_max = 300, 
    suppressant_rate = 40, #essentiall how many minutes it reduces the burn time by
    suppressant_recharge = 120,
    )

    #initialize based on dimensions and
    rng = MersenneTwister(seed)    
    dims = (2*Int(n_x_cells*radius_burn), Int(n_x_cells*radius_burn))    
    space = ContinuousSpace(dims; spacing = radius_burn, periodic = false)
    base_location = (dims[1]*0.05, dims[2]*0.5)
    #note: status method for scheduling is needed 
    order = Dict("green" => 1, "burning" => 2, "burnt" => 3, "coord" => 4, "uav" => 5)
    model_params = Dict(:battery_max => battery_max, :battery_recharge => battery_recharge, :n_uav => n_uav,
     :suppressant_max => suppressant_max, :suppressant_recharge => suppressant_recharge,
     :suppressant_rate => suppressant_rate, :base_location => base_location, :dims => dims)
    if tune_model
        forest = ABM(Patch, space; rng, scheduler = Schedulers.ByProperty(:sched), container = Vector)
    else
        forest = ABM(Union{Patch,UAV,Coord}, space; rng, properties = model_params, scheduler = Schedulers.ByProperty(:sched), container = Vector)
    end
    


    # Establish  scenarios, need to change this and add more. Could be a good idea to create other functions outside of this
    if first_burn == :center
        x_min = dims[1]*0.775
        x_max = dims[1]*0.8
        y_min = dims[2]*0.475
        y_max = dims[2]*0.525
        
    elseif first_burn == :left
        x_min = 0
        x_max = dims[1]*0.05
        y_min = 0
        y_max = dims[2]
        
    elseif first_burn == :lowerleft
        x_min = dims[1]*0.24
        x_max = dims[1]*0.26
        y_min = x_min
        y_max = x_max
    else
        error("Invalid Scenario, :center or :left only at this moment")
    end

    #add in cells, odd vs even used for putting in hexagonal "cells"
    n_y_cells = floor(Integer, n_x_cells/(sqrt(3)/2))        
    x_p = []
    y_p = []

    #as a rush solution for now, simply do this twice, once for each side
    for row in 1:n_y_cells
        Y = radius_burn * ( 0.5 + (row - 1)*sqrt(3)/2)
        if isodd(row)
            for col in 1:n_x_cells
                push!(x_p, Float64(radius_burn*(col-0.5)) )#dims[1]/2)
                push!(y_p, Y)
            end           
        else
            for col in 1:(n_x_cells-1)
                push!(x_p, Float64(radius_burn*col))#+dims[1]/2)
                push!(y_p, Y)
            end
        end       
    end

    for row in 1:n_y_cells
        Y = radius_burn * ( 0.5 + (row - 1)*sqrt(3)/2)
        if isodd(row)
            for col in 1:n_x_cells
                push!(x_p, Float64(radius_burn*(col-0.5)) + dims[1]/2)
                push!(y_p, Y)
            end           
        else
            for col in 1:(n_x_cells-1)
                push!(x_p, Float64(radius_burn*col)+dims[1]/2)
                push!(y_p, Y)
            end
        end       
    end
    
    for row in 1:(n_y_cells/2)
        Y = radius_burn * ( 0.5 + (row*2 - 1)*sqrt(3)/2)
        push!(x_p, dims[1]/2)
        push!(y_p, Y)
    end

    #if the goal isn't to tune the model, then make room for home base and add in other agents
    if !tune_model
        in_rmv = []
        
        for ind in 1:length(x_p)
            if x_p[ind] < dims[1]*0.1 && (y_p[ind] > dims[2]*0.4 && y_p[ind] < dims[2]*0.6)
                push!(in_rmv,ind)
            end
        end

        deleteat!(x_p, in_rmv)
        deleteat!(y_p, in_rmv)

    end

    #add in the forest patches 
    for ind in 1:size(x_p)[1]
        pos = (x_p[ind], y_p[ind]) 
        dist = sqrt((pos[1] - base_location[1])^2 + (pos[2] - base_location[2])^2)
        
        if x_min <= pos[1] <= x_max && y_min <= pos[2] <= y_max
            add_agent!(pos, Patch, forest, (0,0), order["burning"], burn_time, prob_burn, radius_burn, :burning, dist, true,Vector{Int}[],false)
        else
            add_agent!(pos, Patch, forest, (0,0), order["green"], 
            burn_time + rand(forest.rng,(-tree_UQ[1]:1:tree_UQ[1])),
            prob_burn + rand(forest.rng,(-tree_UQ[2]:0.0001:tree_UQ[2])),
            radius_burn, :green, dist, false,Vector{Int}[],false)   
        end
    end
    
    #after creating the patches, go through and assign the neighbor_ids for each patch (this speeds up the program and used to detect if its an edge)
    edge_count = 0
    for ind in 1:size(x_p)[1]
        patch = forest.agents[ind]
        for neighbor in nearby_agents(patch, forest, radius_burn)
            if euclidean_distance(patch, neighbor, forest) <= radius_burn * 1.05 #weird glitch where it was adding in neighbors that were too far away
                push!(patch.neighbor_ids, neighbor.id)
            end
        end
        if length(patch.neighbor_ids) < 6
            edge_count += 1
            patch.simulation_edge = true
        end
    end

    # Add in coordinator and UAV agents. Needs to be done at the end for plotting purposes
    if !tune_model

        for _ in 1:n_uav #note, change initial position to be better distributed with the base_location
            add_agent!(base_location,
             UAV, forest, (0,0), order["uav"], battery_max, suppressant_max,uav_speed,:idle, (0,0), 0)
        end

        add_agent!(base_location, Coord, forest, (0,0), order["coord"],fire_delay,0,false,false,0) 
       
    end

    return forest
end

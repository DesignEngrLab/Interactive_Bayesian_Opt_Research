#=
List of Functions Designed For Tracking Data during the Simulation runs

Includes functions for both Model_Tuning.jl and Model_Analysis.jl

Functions used for both:
    to_collect along with it's subfunctions (burning, burnt, green)


=#

#Functions used for Model_Tuning.jl
    burning(x) = count(i == :on_fire for i in x)
    burnt(x) = count(i == :burnt for i in x)
    green(x) = count(i == :green for i in x)
    to_collect = [(:status, f) for f in (burning, burnt, green)]




    function approx_advancement(model,first_burn)
        # runs and approximation of the model fire perimeter using a convex hull
        # data can then be used to track the change in perimeter for calibration
        # note: will need to modify this method later when adding in additional agents such as control and drones
        
        # gather relevant nodes and find convex hull
        points = []
        center = [250, 250] #generalize this later

        for a in model.agents
            if a isa Patch

            if a.status == :burnt || a.status == :on_fire
                    push!(points, convert(Vector{Float64},[a.pos[1],a.pos[2]]))
                end 
            end
        end

        points = convert(Vector{Vector{Float64}}, points)
        hull = LazySets.convex_hull(points)
        if first_burn == :center
            dist = 0 
            for point in 1:1:length(hull)
                dist += sqrt((hull[point][1] - center[1])^2 + (hull[point][2] - center[2])^2)        
            end
            
        elseif first_burn == :left
            dist = 0
                
            for point in 1:1:length(hull)
                # track distance away from starting points on the perimeter of the fire using the x position
                if hull[point][1] > 5
                    dist += hull[point][1]
                end
                
                
            end
                
        end

        return mean(dist)
    end

    function assets_tune(model)
        advancement(model) = approx_advancement(model,:left) #this is stupid, julia is unbelievable unclear
            
        return [advancement]
    end

    function track_advancement(mdataf)
        #very simple way to track change in perimeter for fire advancement for tuning model
        t_adv = [0.0]
        for i in 2:1:length(mdataf[:,2])

            push!(t_adv, mdataf[i,2] - mdataf[i-1,2])
        end
        
        return t_adv   
    end



#Functions used for Model_Analysis.jl

#need to collect the following data
    #number of trees burnt at end of the simulation (use the adata one)
    #whether or not the fire was contained (check edges of the map, if it went there, it wasn't contained)
    #how long it took to contain the fire (steps, check when "fire was contained!" signal went off)

function assets_analysis(model)
    #this is a bad way of recording, but works for now
    count_burnt = 0
    is_contained = false
    steps = 0
    for agent in model.agents
        if agent isa Patch
            if agent.status == :burnt
                count_burnt += 1
            end       
        elseif agent isa Coord

            is_contained = agent.fire_out
            steps = agent.steps_out

        end
        test = 10
    end

    data(model) = (count_burnt, is_contained, steps)

    return data
end

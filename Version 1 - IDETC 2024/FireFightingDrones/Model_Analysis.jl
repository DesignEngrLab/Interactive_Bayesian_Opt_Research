using Agents, Random
using InteractiveDynamics
using CairoMakie
using LazySets
using Statistics
using CurveFit
using DelimitedFiles

include("Main_Model.jl")
include("Model_Agents.jl")
include("Model_Plotting.jl")
include("Tracking_Functions.jl")

#this code up here is just for initial experimentaiton and plotting, the bulk of the actual analysis (running and saving) is below


#forest2 = forest_fire(first_burn = :left,n_uav = 10, suppressant_max = 300, fire_delay = 100, uav_speed = 20)#, n_x_cells = 100, radius_burn = 5)
#forest2 = forest_fire(seed = 5,n_uav = 25, uav_speed = 2000, suppressant_max = 270, battery_max =30)
#forest2 = forest_fire(fire_delay = 240, first_burn = :center, seed = 7,n_uav = 5, uav_speed = 200, n_x_cells = 20, suppressant_max = 120, battery_max = 60)
#battery_recharge = ceil(in_air_t_i[i]/reset_t_i[i]), suppressant_recharge = ceil(reset_t_i[i]/suppr_i[i])
#forest2 = forest_fire(seed = 3, n_uav = 90, uav_speed = 900,suppressant_max = 270, battery_max = 15, battery_recharge = 3, suppressant_recharge = 54)

#@time step!(forest2, agent_step!, 3000)
#fig = call_fig(forest2)

#save("idetc_figure.png", fig, px_per_unit = 6)


seconds = 5
spf = 20
framerate = 10
frames = framerate*seconds



#@time call_video(forest2, "testing spread reruns.mp4", framerate, frames, spf)


#now i am running them in a loop

#=
@time begin

while !(forest2.agents[end].fire_out_of_control || forest2.agents[end].fire_contained)
    step!(forest2, agent_step!, 1)
    #step!(forest2, agent_step!, 10000)
end

end
=#


##this section here is for 

function count_burn(model)
    #this function counts the number of burnt (and burning in the case of unconttrees in the model.
    #this is used as the objective function
    #yes, this setup is just two lines and not needed
    patches = [p for p in allagents(model) if p isa Patch]
    return length([p for p in patches if p.status == :burnt || p.status == :burning])

end


#=

#data storage initialization
s_in = 30;
s_uq = 30;

timing_data = zeros(s_in, s_uq) #timing data for additional information
final_tree_data = zeros(s_in, s_uq) #final tree data for the objective funciton
containment_data = zeros(s_in, s_uq) #containment data for the binary classificaiton constraint

#design solution information (this first part is from LHS)
speed_i = [650	1900	1150	1650	1650	1900	650	900	1400	400	900	1400	400	1150]
in_air_t_i = [9	15	7	15	11	7	13	11	5	9	13	17	5	17]
reset_t_i = [13	3	11	5	13	9	15	11	7	5	7	9	3	15]
suppr_i = [450	390	210	270	270	150	390	330	510	450	150	330	210	510]
n_u_i = [95	35	105	55	85	90	95	90	70	80	90	60	105	65]

#adding in the extremes
speed_i = [speed_i [400 1900 400 1900 400 1900 400 1900 400 1900 400 1900 400 1900 400 1900]] 
in_air_t_i = [in_air_t_i [5 5 17 17 5 5 17 17 5 5 17 17 5 5 17 17]]
reset_t_i = [reset_t_i [3 3 3 3 15 15 15 15 3 3 3 3 15 15 15 15]]
suppr_i = [suppr_i [150 150 150 150 150 150 150 150 510 510 510 510 510 510 510 510]]
n_u_i = [n_u_i [110	80	80	50	140	110	110	80	80	50	50	20	110	80	80	50]]#maybe decrease later?



#actually running the model and storing data (for initial samples)

#for each row, I will store the time it took the contain the fire, how many were burnt and if it was containment_data



#forest2 = forest_fire(n_uav = 20, uav_speed = 900, n_x_cells = 100, suppressant_max = 120, battery_max = 15)
@time begin

for i in 1:s_in
    for j in 1:s_uq
        #NOTE: need to modify this later when I'm examining the initial samples
        #Note: since I used reset time instead of refill for both battery and suppressant, I have to use an adjustment factor 
        forest_ij = forest_fire(seed = j,n_uav = n_u_i[i], uav_speed = speed_i[i], suppressant_max = suppr_i[i], battery_max = in_air_t_i[i], battery_recharge = ceil(in_air_t_i[i]/reset_t_i[i]), suppressant_recharge = ceil(reset_t_i[i]/suppr_i[i]))

        while !(forest_ij.agents[end].fire_out_of_control || forest_ij.agents[end].fire_contained)
            step!(forest_ij, agent_step!, 1)
        end

        #store the results from the testing
        timing_data[i,j] = forest_ij.agents[end].internal_step_counter
        
 
        final_tree_data[i,j] = count_burn(forest_ij)
        
        if forest_ij.agents[end].fire_contained
            containment_data[i,j] = 1
        else
            containment_data[i,j] = -1 #the use of negative one is for fitting the model
        end

    end
end

end

#saving the data
writedlm("timing_data_initial.csv", timing_data, ',')
writedlm("final_tree_data_initial.csv", final_tree_data, ',')
writedlm("containment_data_initial.csv", containment_data, ',')
=#

#running the data and storing the results (for the additional samples)
s_in = 1;
s_uq = 30;

timing_data = zeros(s_in, s_uq) #timing data for additional information
final_tree_data = zeros(s_in, s_uq) #final tree data for the objective funciton
containment_data = zeros(s_in, s_uq) #containment data for the binary classificaiton constraint


speed_i = [1150]
in_air_t_i =[15]
reset_t_i = [15]
suppr_i = [330]
n_u_i = [85]

for i in 1:s_in
    for j in 1:s_uq
        #NOTE: need to modify this later when I'm examining the initial samples
        #Note: since I used reset time instead of refill for both battery and suppressant, I have to use an adjustment factor 
        forest_ij = forest_fire(seed = j,n_uav = n_u_i[i], uav_speed = speed_i[i], suppressant_max = suppr_i[i], battery_max = in_air_t_i[i], battery_recharge = ceil(in_air_t_i[i]/reset_t_i[i]), suppressant_recharge = ceil(reset_t_i[i]/suppr_i[i]))

        while !(forest_ij.agents[end].fire_out_of_control || forest_ij.agents[end].fire_contained)
            step!(forest_ij, agent_step!, 1)
        end

        #store the results from the testing
        timing_data[i,j] = forest_ij.agents[end].internal_step_counter
        
 
        final_tree_data[i,j] = count_burn(forest_ij)
        
        if forest_ij.agents[end].fire_contained
            containment_data[i,j] = 1
        else
            containment_data[i,j] = -1 #the use of negative one is for fitting the model
        end

    end
end


writedlm("timing_data_current_iter.csv", timing_data, ',')
writedlm("final_tree_data_current_iter.csv", final_tree_data, ',')
writedlm("containment_data_current_iter.csv", containment_data, ',')
print(mean(final_tree_data))
print(mean(containment_data))


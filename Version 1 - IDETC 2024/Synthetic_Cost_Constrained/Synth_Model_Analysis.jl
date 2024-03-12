using Agents, Random, InteractiveDynamics, CairoMakie, FileIO, DelimitedFiles

include("Synth_Model_Agents.jl")
include("Synth_Main_Model.jl")
include("Synth_Model_Plotting.jl")

design_vars = [7,250,75]
synth = Synth_Example(n_devices = design_vars[1], s_devices = design_vars[2], items_max = design_vars[3],n_targets = 500)

seconds = 20
spf = 2
framerate = 24
frames = framerate*seconds

#call_vid(synth, "test5.mp4", framerate, frames, spf)

@time step!(synth, agent_step!, 660)

fig = call_fig(synth)



#=
speed = [200,210, 220,230,240,250,260,270,280]#[220,230,240,250,260,270,280,290,300]
capacity = [4,6,8,10,12,14,16,18,20,22,24,26,28,30]
n_devices = [22,21,20,19,18,17,16,15,17,13,12,11,10,9,
            21,20,19,18,17,16,15,14,13,12,11,10,9,8,
            20,19,18,17,16,15,14,13,12,11,10,9,8,7,
            19,18,17,16,15,14,13,12,11,10,9,8,7,6,
            18,17,16,15,14,13,12,11,10,9,8,7,6,5,
            17,16,15,14,13,12,11,10,9,8,7,6,5,4,
            16,15,14,13,12,11,10,9,8,7,6,5,4,3,
            15,14,13,12,11,10,9,8,7,6,5,4,3,2,
            14,13,12,11,10,9,8,7,6,5,4,3,2,1].+2

designs = zeros(length(speed)*length(capacity),3)

for i in 1:1:length(speed)
    for j in 1:1:length(capacity)
        designs[(i-1)*length(capacity)+j,1] = speed[i]
        designs[(i-1)*length(capacity)+j,2] = capacity[j]
        designs[(i-1)*length(capacity)+j,3] = n_devices[(i-1)*length(capacity)+j]
    end
end

data = zeros(length(designs[:,1]),1)

for i in 1:1:length(designs[:,1])

    print(designs[i,:])
    synth_n = Synth_Example(n_devices = designs[i,3], s_devices = designs[i,1], items_max = designs[i,2],n_targets = 1000)
    step!(synth_n, agent_step!, 10000)
    
    data[i] = synth_n.agents[end].steps_capture

end

data = reshape(data,length(capacity),length(speed))

dcheck = reshape(designs[:,3],length(capacity),length(speed))

writedlm("synth_data.csv", data, ',')
writedlm("synth_designs.csv", dcheck, ',')
=#

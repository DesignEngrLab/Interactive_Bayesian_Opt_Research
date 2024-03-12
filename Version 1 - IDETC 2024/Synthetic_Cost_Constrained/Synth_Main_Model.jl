#thei file initializes the model
#it can then be called by other ufnctions for analysis


using Agents, Random

include("Synth_Model_Agents.jl")


function Synth_Example(;
    n_devices = 10, #number of devices
    s_devices = 100.0, #speed of devices
    n_targets = 50, #number of targets

    n_packages = 5, #maximum number of packages it can hold
    device_move_time = 180, #maximum flight time for devices
    device_recharge_time = 10, #maximum recharge time for devices
    seed = 2, #random seed
    items_max = 5, #maximum number of items a target can hold
    )

    rng = MersenneTwister(seed)
    dims = (10000,5000) #dimensions of the space
    space = ContinuousSpace(dims, periodic = false) #create the space
    coord_pos = (dims[1]*0.05,dims[2]*0.05) #coordinator position
    #status used for scheduling, unsure if needed but added now just in case
    order = Dict("targ"=>1, "coord"=>2, "dev"=>5) #order of agent types
    #model parameters for global variables, reduces need to assign to each drones   
        #idk if this is faster or not
    model_params = Dict("device_move_time"=>device_move_time, "device_recharge_time"=>device_recharge_time,"s_devices"=>s_devices,
        "n_packages"=>n_packages, "items_max"=>items_max)

    #making the model (it will yell at you for using a union)
    model = ABM(Union{Device, Target, Coordinator}, space; rng = rng, properties = model_params, scheduler = Schedulers.ByProperty(:sched), container = Vector)


    iv = (0,0) #in,itial velocity, just makes it easier to code
 

    #place the target agents further away from the coordinator, give then a preassigned priority and time step to start
        #note: will need to think about this.
        #also note: will need to think about actual units for designing how to chose it.

    for _ in 1:n_targets
        #randomly place the device agents around the coordinator
        pos = (rand(model.rng, (dims[1]*0.2):0.5:(dims[1]*0.95)), rand(model.rng, (dims[2]*0.2):0.5:(dims[2]*0.95)))

        add_agent!(pos, Target, model, iv, order["targ"], :waiting, rand(model.rng, 5:1:500))
    end

    #place the device agents around the coordinator
    for _ in 1:n_devices
        #randomly place the device agents around the coordinator
        pos = (rand(model.rng, 1:0.5:(dims[1]*0.1)), rand(model.rng, 1:0.5:(dims[2]*0.1)))

        add_agent!(pos, Device, model, iv, order["dev"],:ready,device_move_time, device_recharge_time,0,(0,0),0)
    end

   #place the coordinator agent
   add_agent!(coord_pos, Coordinator, model, iv,order["coord"],0,n_targets,0)


    return model
end
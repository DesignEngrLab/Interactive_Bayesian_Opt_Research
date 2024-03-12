using Agents, Random

#making agents for the synthetic example of the paper
#there will be three agents: 1) the Device, 2) the target, and the 3) the coordinator

#note: all agents in continuous space have a location and a speed, 

@agent Device ContinuousAgent{2} begin
    #= The device agent is a continuous agent with two attributes: flight time and recharge time.
    Maximum flight and recharge times are set globally and the drones only need to know their own.
    move_time_remain will decrease on each time step
    when status = "recharging" the recharge_time will start based on global, then decrease. When 0, status is set to "ready"
    it also also a scheduling function to help the model run =#
    sched::Int
    status::Symbol

    #internal variables for the device.
    move_time_remain::Int
    recharge_time_remain::Int    
    items_holding::Int

    target_pos::Tuple
    target_id::Int
end


@agent Target ContinuousAgent{2} begin
    #= The target agent is a continuous agent with a single status: was it reached? =#
    sched::Int
    status::Symbol #if the target is now available to be assigned, if it has been reached, or if it is still waiting (:assigned, :reached, :waiting)
    t_step_start::Int #time step when the target was created, helpful for dynamic task allocation. It is also the priority of the target
end

@agent Coordinator ContinuousAgent{2} begin
    #= The coordinator agent is a continuous agent with a single status: was it reached? =#
    sched::Int
    int_ticker::Int
    t_targs::Int
    steps_capture::Int
end



#agent steps 

function agent_step!(device::Device, model)
    #= device does things based on its status =#

    if device.status == :ready
        #do nothing/wait for an assignment

    elseif device.status == :returning
        #go back to home because it's out of packages or out of flight time

        if device.pos == model.agents[end].pos
            #if at home, start recharging and making sure that recharge time is set correctly 
            device.status = :recharging
            device.recharge_time_remain = model.properties["device_recharge_time"]
            device.vel = (0,0)
        else
            #move towards base
            if euclidean_distance(device, model.agents[end], model) < sqrt(device.vel[1]^2 + device.vel[2]^2)
                device.pos = model.agents[end].pos
                device.vel = (0,0) #this may be redundant
            else
                try
                    move_agent!(device, model, 1)
                catch MethodError
                    device.pos = (device.pos[1] + device.vel[1], device.pos[2] + device.vel[2])
                end
            end
        end

    elseif device.status == :recharging
        #reduce the recharge time which is essentially recharging it. Then if if that's done, it's ready  to go
        device.recharge_time_remain -= 1
        if device.recharge_time_remain == 0
            device.move_time_remain = model.properties["device_move_time"]
            device.items_holding = 0
            device.status = :ready
        end

    elseif device.status == :assigned

        #if the device has reached the target, change the status of the target and the device
        #else, continue to move towards the target
        if device.pos == device.target_pos
            device.items_holding += 1
            device.status = :ready
            target_assigned = model.agents[device.target_id]
            target_assigned.status = :reached
        
        else

            if euclidean_distance(device, model.agents[device.target_id], model) < sqrt(device.vel[1]^2 + device.vel[2]^2)
                #if the device is close enough to the target (IE would overshoot), just set the position to the target position
                device.pos = device.target_pos
                device.vel = (0,0)
            else
                #otherwise, move towards the target
                #NOTE: ran into this issue before, unsure why sometimes the "move_agent!" function doesn't work
                #this is a temporary fix, but it's not ideal, but catch is faster than device.pos updating each time
                try
                    move_agent!(device, model, 1)
                catch MethodError
                    device.pos = (device.pos[1] + device.vel[1], device.pos[2] + device.vel[2])
                end
            end


        end
        
        
        
        #reduce the flight time which is essentially flying it. Then if if that's done, it's recharging
        #note that, if this is the case, the target should no longer be assigned to the device and it is up for grabs again
        device.move_time_remain -= 1

        
        if (euclidean_distance(device,model.agents[end],model) > model.properties["s_devices"]*device.move_time_remain) || device.items_holding == model.properties["items_max"] 
            device.status = :returning
            device.target_pos = model.agents[end].pos
            device.target_id = 0
            ratio = model.properties["s_devices"]/euclidean_distance(device, model.agents[end], model) #ratio of speed to distance because of how velocity works in agents.jl
            device.vel = ((model.agents[end].pos[1] - device.pos[1])*ratio, (model.agents[end].pos[2] - device.pos[2])*ratio) #new velocity based on ratio
        end
       
        #=
        if device.move_time_remain == 0
            device.recharge_time_remain = model.properties["device_recharge_time"]
            device.status = :recharging
            target_assigned = model.agents[device.target_id]
            target_assigned.status = :available

            #reset the device attributes
            device.target_pos = (0,0)
            device.target_id = 0
            device.vel = (0,0)
        end
        =#

    else
        print("error: device status not recognized")
    end
    

end


function agent_step!(targ::Target, model)
    #= target does things based on its status =#

    if targ.status == :waiting
        #reduce intern t_step_start value allow it to eventually become available
        targ.t_step_start -= 1
        if targ.t_step_start == 0
            targ.status = :available
        end

    else
        # do nothing, nothing should be needed to do. IE  the drone being there should be able to reassign the status from that code
    end
    
end


function agent_step!(coord::Coordinator, model)
    #= coordinator agent takes in statuses of targets and then assigns them to devices bsaed on the priority. It also doesn't do it every time step??
    
    =#
    coord.int_ticker += 1 #increase the internal ticker that way it's not constantly assigning things

    if rem(coord.int_ticker, 5) == 0 #no need to constantly confuse the targets, only update every 5 time steps
        #use the patch prioritization function to find and rank available targets
        targets = [a for a in allagents(model) if a isa Target]
        
        t_reached = [a for a in targets if a.status == :reached]
        if length(t_reached) == coord.t_targs
            #all targets have been reached, end the model
            if coord.steps_capture == 0
                print("all targets reached", coord.int_ticker,"\n")
                coord.steps_capture = coord.int_ticker
            end
            #println("all targets reached", coord.int_ticker,"\n")

        end

        available_targets = [a for a in targets if a.status == :available]
        #print("av ",length(available_targets),"\n")
        prioritized_targets = sort(available_targets, by = x -> euclidean_distance(x,model.agents[end],model), rev = false) #rev used to put highest priority first

        #second loop to assign targets to devices, this is done via an auction algorithm. 
        #the highest priority target is assigned to the highest bidder, where highest bidder is the device that can get there the fastest. 
        #find free drones
        free_divs = [a for a in allagents(model) if a isa Device && a.status == :ready]  #unsure if this works, not how I did it before
        #print("fd ", length(free_divs),"\n")
        if length(free_divs) > 0
            for i in 1:length(prioritized_targets)
                
                #break if no more free devices, there will probably always be free devices though
                if length(free_divs) == 0
                    break
                end
                #bidding based on euclidean distance and flight time and recharge time. 
                # eq: D - BR + RT Seems to prioritize things correctly
                free_divs = sort(free_divs, by = a -> (ceil(euclidean_distance(a,prioritized_targets[i],model) / model.properties["s_devices"]) - a.move_time_remain + model.properties["device_recharge_time"]))
             
                assign_device = popfirst!(free_divs) #assign the device to the highest bidder
                #print("bd pp ", length(free_divs),"\n")
                assign_device.target_pos = prioritized_targets[i].pos #assign the target position to the device
                assign_device.target_id = prioritized_targets[i].id #assign the target id to the device

                ratio = model.properties["s_devices"]/euclidean_distance(assign_device, prioritized_targets[i], model) #ratio of speed to distance because of how velocity works in agents.jl
                assign_device.vel = (prioritized_targets[i].pos[1] - assign_device.pos[1])*ratio, (prioritized_targets[i].pos[2] - assign_device.pos[2])*ratio #new velocity based on ratio
                assign_device.status = :assigned #change the status of the device to assigned
           
            end
       
        end

    end
 
end


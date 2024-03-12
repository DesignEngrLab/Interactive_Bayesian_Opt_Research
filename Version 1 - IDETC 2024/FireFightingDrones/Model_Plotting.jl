#support functions for plotting model in the analysis 


function patch_color(pf)
    # quick work around for a scale based on probability of catching fire...
    # I wish I could figure out how to scale this better
    colors = ("#0c7504","#0A7F00", "#0C9300", "#0EAF00")
    pr = [0, 0.0035, 0.004, 0.0045]

    if pr[1] < pf <= pr[2]
        color = colors[1]

    elseif pr[2] < pf <= pr[3]
        color = colors[2]

    elseif pr[3]< pf <= pr[4]
        color = colors[3]

    else 
        color = colors[4]
        
    end
    
    return color
end

function agent_color(a)
    if a isa Patch
        if a.status == :burning
            color = :crimson
        elseif a.status == :burnt
            color = :gray75
        else
            color = patch_color(a.prob_burn)            
        end
    elseif a isa UAV
        color = :purple4 #:magenta3#
    else
        color = :blue
    end
    color
end

function agent_size(a)
    if a isa Patch
        if a.status == :burning
            sz = 18
            #sz = 10
        elseif a.status == :green
            sz = 20
            #sz = 9
        else
            sz = 15
            #sz = 8
        end
        
    elseif a isa UAV
        sz = 12#32

    else 
        sz = 17
    end

end


#const coord_polygon = Makie.Polygon(Point2f[(-.65,-1), (-.65,0), (-1,0), (0,1), (1, 0), (0.65, 0), (0.65, -1)])
const coord_polygon = Makie.Polygon(Point2f[(	-0.4	,	0.5	),(	-0.55	,	-1.5	),(	-0.75	,	-1.5	),(	-0.6	,	0.6	),(	-0.8	,	0.6	),(	-0.8	,	0.85	),(	-0.6	,	0.85
),(	-0.6	,	1.5	),(	-0.8	,	1.5	),(	0	,	2.2	),(	0.8	,	1.5	),(	0.6	,	1.5	),(	0.6	,	0.85	),(	0.8	,	0.85
),(	0.8	,	0.6	),(	0.6	,	0.6	),(	0.75	,	-1.5	),(	0.55	,	-1.5	),(	0.4	,	0.5	)])							


const uav_polygon = Makie.Polygon(Point2f[(-0.5,-0.25),(-1.5,-1.25),(-1.25,-1.5),(-0.25,-0.5),(0.25,-0.5),(1.25,-1.5),(1.5,-1.25),(0.5,-0.25),(0.5,0.25),(1.5,1.25),(1.25,1.5),(0.25,0.5),(-0.25,0.5),(-1.25,1.5),(-1.5,1.25),(-0.5,0.25)])

function agent_shape(a)
    if a isa Patch
        shape = :hexagon
        if a.status == :burning
            shape = :star8
        elseif a.status == :burnt
            shape = :rect
        end
        
    elseif a isa UAV
        shape = uav_polygon#:xcross 

    else
        shape = coord_polygon
    end
    shape
end

function static_preplot!(ax,model)
    hidedecorations!(ax)
end

function call_fig(model)
    figure, _ = Agents.abmplot(model; ac = agent_color,as = agent_size, am = agent_shape, scatterkwargs = (strokewidth = 0.1,), static_preplot!, figure = (;resolution = (600,300)))
    return figure

end

function call_video(model, filename,  framerate, frames, spf)
    Agents.abmvideo(filename, model, agent_step!;
     ac = agent_color,as = agent_size, am = agent_shape, scatterkwargs = (strokewidth = 0.1,), 
     static_preplot!, figure = (;resolution = (1000,500)),
     spf = spf, framerate = framerate, frames = frames)

end
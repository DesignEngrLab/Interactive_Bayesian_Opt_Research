function agent_color(a)
    if a isa Device
        color = "#d11b66"#:purple4
    elseif a isa Target
        if a.status == :waiting
            color =  "#d7ffff"#waiting targets are white so they don't show up on the map (I could make them gray later)
        elseif a.status == :available || a.status == :assigned
            color = :orange
        else #means its been reached (:reached)
            color = :green
        end
    else 
        color = :blue
    end
    color

end

const boat_polygon = Makie.Polygon(Point2f[(-1.5,0),(-1.2,-0.5),(-0.75,-0.7),(-0.5,-0.75),(	1.5	,	-0.75	),(	1.5	,	0	),(	0.25,0),(0.25,0.5),(	1.1	,0.5),(0.25,2),(0,2),(0,1.75),(-0.75,0.35),(0,0.35),(0,0)])

function agent_shape(a)
    if a isa Device
        shape = boat_polygon#:xcross
    elseif a isa Target
        shape = :circle
    else 
        shape = boat_polygon#:rect
    end
    shape
end

function agent_size(a)
    if a isa Device
        size = 15
    elseif a isa Target
        size = 10
    else
        size = 25
    end
end


function static_preplot!(ax, model)
    img = load("Synth_Background.png")
    image!(ax, rotr90(img), intterpoate = false)
    hidedecorations!(ax)
end


function call_fig(model)
    #make figure based on current iteration of model
    figure, _ = Agents.abmplot(model; ac = agent_color, am = agent_shape, as = agent_size,scatterkwargs = (strokewidth = 0.5,), static_preplot!, figure = (;resolution = (750,750)))#, scatterkwargs = (strokewidth = 0.1), figure = (;resolution = (1000,1000)))
    return figure
end

function call_vid(model, filename, framerate, frames, spf)
    #make and save the video
    Agents.abmvideo(filename, model, agent_step!;
    ac = agent_color, am = agent_shape, as = agent_size, scatterkwargs = (strokewidth = 0.,), 
    spf = spf, framerate = framerate, frames = frames)


end
using Agents
using InteractiveDynamics
using GLMakie

@agent RPS GridAgent{2} begin
    type::Symbol
end

function init(grid_size = 50)

    model = ABM(RPS, GridSpace((grid_size, grid_size), metric=:euclidean); scheduler = Schedulers.randomly)

    num_agents_per_type = floor(Int, ((grid_size^2)*0.8)/3)
    for _ in 1:num_agents_per_type
        add_agent_single!(model, :rock)
        add_agent_single!(model, :paper)
        add_agent_single!(model, :scissors)
    end

    return model
end

function agent_step!(agent, model)
    nearby = rand(model.rng, collect(nearby_positions(agent, model)))

    roll = rand(model.rng, 1:3)
    if roll == 1
        #Fight
        isempty(nearby, model) && return
        neighbour = first(agents_in_position(nearby, model))
        fight!(agent, neighbour, model)
    elseif roll == 2
        #Reproduce
        isempty(nearby, model) && add_agent!(nearby, model, agent.type)
    else
        #Move
        if !isempty(nearby, model)
            neighbour = first(agents_in_position(nearby, model))
            move_agent!(neighbour, agent.pos, model)
        end
        move_agent!(agent, nearby, model)
    end
end

function fight!(agent, neighbour, model)
    agent.type == neighbour.type && return
    # Looking for the winner 
    agent_wins = (agent.type == :rock && neighbour.type == :scissors) ||
                 (agent.type == :paper && neighbour.type == :rock) ||
                 (agent.type == :scissors && neighbour.type == :paper)
    
    if agent_wins
        kill_agent!(neighbour, model)
    else
        kill_agent!(agent, model)
    end
end

function typecolor(a) 
    if a.type == :rock
        return :black
    elseif a.type == :paper
        return :blue
    else
        return :red
    end
end

fig, _ = abm_play(model, agent_step!, dummystep; ac = typecolor)

abm_video(
    "rps.mp4", model, agent_step!, dummystep;
    framerate = 15, frames = 400, ac=typecolor
)
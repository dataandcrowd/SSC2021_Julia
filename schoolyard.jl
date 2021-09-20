using Agents
using SparseArrays
using SimpleWeightedGraphs

using InteractiveDynamics
using GLMakie

mutable struct Student <: AbstractAgent
    id::Int
    pos::Tuple{Float64,Float64}
    class::Symbol
end

function schoolyard(;
    numStudents = 50,
    teacher_attractor = 0.15,
    noise = 0.1,
    max_force = 1.7,
    )

    properties = Dict(
        :teacher_attractor => teacher_attractor,
        :noise => noise,
        :max_force => max_force,
        :buddies => SimpleWeightedDiGraph(numStudents)
    )

    model = ABM(
        Student,
        ContinuousSpace((100, 100), 4.0; periodic = false);
        properties
    )

    for student in 1:numStudents
        add_agent!(model.space.extent .* 0.5 .+ Tuple(rand(model.rng, 2)) .- 0.5, model, rand(model.rng, (:A, :B)))
        friend = rand(model.rng, filter(s -> s != student, 1:numStudents))
        add_edge!(model.buddies, student, friend, rand(model.rng))
        foe = rand(model.rng, filter(s -> s != student, 1:numStudents))
        add_edge!(model.buddies, student, foe, -rand(model.rng))
    end

    return model
end

distance(pos) = sqrt(pos[1]^2 + pos[2]^2)
force_scale(L, force) = (L / distance(force)) .* force

function agent_step!(student, model)
    teacher = (model.space.extent .* 0.5 .- student.pos) .* model.teacher_attractor

    noise = model.noise .* (Tuple(rand(model.rng, 2)) .- 0.5)

    network = model.buddies.weights[student.id, :]
    tidxs, tweights = findnz(network)
    network_force = (0.0, 0.0)
    for (widx, tidx) in enumerate(tidxs)
        buddieness = tweights[widx]
        force = (student.pos .- model[tidx].pos) .* buddieness
        if buddieness >= 0
            if distance(force) > model.max_force
                force = force_scale(model.max_force, force)
            end
        else
            if distance(force) > model.max_force
                force = (0.0, 0.0)
            else
                L = model.max_force - distance(force)
                force = force_scale(L, force)
            end
        end
        network_force = network_force .+ force
    end

    new_pos = student.pos .+ noise .+ teacher .+ network_force
    move_agent!(student, new_pos, model)
end

function static_preplot!(ax, model)
    obj = scatter!([50 50]; color = :red)
    hidedecorations!(ax)
    translate!(obj, 0, 0, 5)
end

sliders = Dict(
    :teacher_attractor => 0:0.05:1,
    :noise => 0:0.1:1,
    :max_force => 1:0.1:3
    )
fig, _, _ = abm_data_exploration(model, agent_step!, dummystep, sliders; static_preplot!)


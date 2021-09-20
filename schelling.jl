### Step 1: decide space
using Agents

space = GridSpace((10, 10); periodic = false)

### Step 2: make agent type
mutable struct SchellingAgent <: AbstractAgent
    id::Int            
    pos::NTuple{2, Int} 
    group::Int        
    happy::Bool
end

### Step 3: make model

properties = Dict(:min_to_be_happy => 3)
scheduler = Schedulers.by_property(:group)

schelling = ABM(SchellingAgent, space; properties)

using Random # for reproducibility
function initialize(; N = 320, M = 20, min_to_be_happy = 3, seed = 125)
    space = GridSpace((M, M), periodic = false)
    properties = Dict(:min_to_be_happy => min_to_be_happy)
    rng = Random.MersenneTwister(seed)
    model = ABM(
        SchellingAgent, space;
        properties, rng, scheduler = Schedulers.randomly
    )

    for n in 1:N
        agent = SchellingAgent(n, (1, 1), n < N / 2 ? 1 : 2, false)
        add_agent_single!(agent, model)
    end
    return model
end


### Step 4: Agent stepping function and step!
function agent_step!(agent, model)
    minhappy = model.min_to_be_happy
    count_neighbors_same_group = 0
    for neighbor in nearby_agents(agent, model)
        if agent.group == neighbor.group
            count_neighbors_same_group += 1
        end
    end
    if count_neighbors_same_group ≥ minhappy
        agent.happy = true
    else
        move_agent_single!(agent, model)
    end
    return
end

model = initialize()

step!(model, agent_step!)

step!(model, agent_step!, 3)

n(model, s) = s == 5

step!(mode, agent_step!, dummystep, n)

### Step 5: visualization
using InteractiveDynamics, GLMakie

groupcolor(a) = a.group == 1 ? :blue : :orange
groupmarker(a) = a.group == 1 ? :circle : :rect
fig, _ = abm_plot(model; ac = groupcolor, am = groupmarker, as = 10)
display(fig)

model = initialize();
abm_play(
    model, agent_step!;
    ac = groupcolor, am = groupmarker, as = 10,
)

### Step 6: Collecting data
adata = [:happy, :group]
model = initialize()
data, _ = run!(model, agent_step!, 5; adata)

x(agent) = agent.pos[1]
model = initialize()
adata = [x, :happy]
data, _ = run!(model, agent_step!, 5; adata)

using Statistics: mean
model = initialize();
adata = [(:happy, sum), (x, mean)]
data, _ = run!(model, agent_step!, 5; adata)

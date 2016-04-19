# MDPRolloutSimulator
# maintained by @zsunberg

"""
a fast MDP simulator that just returns the reward
"""
type MDPRolloutSimulator <: Simulator
    rng::AbstractRNG

    # optional: if these are null, they will be ignored
    eps::Nullable{Float64}
    max_steps::Nullable{Int}
end
MDPRolloutSimulator(rng::AbstractRNG) = MDPRolloutSimulator(rng, Nullable{Float64}(), Nullable{Int}())
MDPRolloutSimulator() = MDPRolloutSimulator(MersenneTwister(rand(UInt32)))
function MDPRolloutSimulator(;rng=MersenneTwister(rand(UInt32)),
                           eps=Nullable{Float64}(),
                           max_steps=Nullable{Int}())
    return MDPRolloutSimulator(rng, eps, max_steps)
end

"""
Return the reward for a single simulation of the mdp.

The simulation will be terminated when either
1) a terminal state is reached (as determined by `isterminal()` or
2) the discount factor is as small as `eps` or
3) max_steps have been executed
"""
function simulate{S,A}(sim::MDPRolloutSimulator, mdp::MDP{S,A}, policy::Policy, initial_state::S)

    eps = get(sim.eps, 0.0)
    max_steps = get(sim.max_steps, typemax(Int))

    disc = 1.0
    r_total = 0.0

    # I think this deepcopy is necessary because the memory will be reused
    s = deepcopy(initial_state)
    a = create_action(mdp)
    sp = create_state(mdp)

    step = 1

    while disc > eps && !isterminal(mdp, s) && step <= max_steps
        a = action(policy, s, a)

        sp, r = generate_sr(mdp, s, a, sim.rng, sp)

        r_total += disc*r

        # alternates using the memory allocated for s and sp so nothing new has to be allocated
        tmp = s
        s = sp
        sp = tmp

        disc *= discount(mdp)
        step += 1
    end

    return r_total
end


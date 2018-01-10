using POMDPToolbox
using POMDPModels
using Base.Test

using FIB

pomdp = BabyPOMDP()

# testing constructor
b0 = DiscreteBelief(pomdp, [0.5,0.5])
@test pdf(b0,true) == 0.5
@test pdf(b0,false) == 0.5

# testing uniform belief
b1 = uniform_belief(pomdp)
@test pdf(b1,true) == 0.5
@test pdf(b1,false) == 0.5

# testing equality (== function)
b2 = uniform_belief(pomdp)
@test b2 == b1
@test b2 == b0

# testing hashing
@test hash(b0) == hash(b0.b)    # hashing only depends on belief
@test hash(b0) == hash(b1)      # same beliefs should hash equally
@test hash(b1) == hash(b2)

# testing updater initialization
up = DiscreteUpdater(pomdp)
isd = initial_state_distribution(pomdp)
b4 = initialize_belief(up, isd)
@test pdf(b4,true) == pdf(isd,true)
@test pdf(b4,false) == pdf(isd,false)

# testing update function; if we feed baby, it won't be hungry
a = true
o = true
b4p = update(up, b4, a, o)
@test pdf(b4p,true) == 0.0
@test pdf(b4p,false) == 1.0

# if we don't feed the baby and observe crying
a = false
o = true
b4p = update(up, b4, false, true)
@test isapprox(pdf(b4p,true), 0.470588, atol=1e-4)
@test isapprox(pdf(b4p,false), 0.52941, atol=1e-4)

# testing that it works in a solve/simulation loop
# I'm not sure I need this test (could eliminate FIB dependency if not)
r = test_solver(FIBSolver(), pomdp, max_steps=100)
@test isapprox(r, -20.414855)

# Some more tests with tiger problem (old tests, but still work)
pomdp = TigerPOMDP()
up = DiscreteUpdater(pomdp)
bold = initialize_belief(up, initial_state_distribution(pomdp))

a = 0
o = true
bnew = update(up, bold, a, o)
@test isapprox(bnew.b, [0.15, 0.85])
@test isapprox(pdf(bnew, 1), 0.15)
@test isapprox(pdf(bnew, 2), 0.85)

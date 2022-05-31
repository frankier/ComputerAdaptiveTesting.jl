#md # How abilities converge on simulated 3PL data

# # Running a CAT based on a synthetic correct/incorrect 3PL IRT model
#
# This example shows how to run a CAT based on a synthetic correct/incorrect 3PL
# IRT model.

# Import order is important. We put ComputerAdaptiveTesting last so we get the
# extra dependencies.
using Makie
import Pkg
if isdefined(Main, :IJulia) && Main.IJulia.inited
    using WGLMakie
elseif "GLMakie" in keys(Pkg.project().dependencies)
    using GLMakie
else
    using CairoMakie
end
import Random
using Distributions: Normal, cdf
using AlgebraOfGraphics
using ComputerAdaptiveTesting
using ComputerAdaptiveTesting.ExtraDistributions: NormalScaledLogistic
using ComputerAdaptiveTesting.Sim: auto_responder
using ComputerAdaptiveTesting.NextItemRules: AbilityVarianceStateCriterion
using ComputerAdaptiveTesting.TerminationConditions: FixedItemsTerminationCondition
using ComputerAdaptiveTesting.Aggregators: PriorAbilityEstimator, MeanAbilityEstimator, LikelihoodAbilityEstimator
using ComputerAdaptiveTesting.Plots
using ComputerAdaptiveTesting.ItemBanks
using ComputerAdaptiveTesting.Integrators
import ComputerAdaptiveTesting.IntegralCoeffs

# Now we are read to generate our synthetic data using the supplied DummyData
# module. We generate an item bank with 100 items and fake responses for 3
# testees.
using ComputerAdaptiveTesting.DummyData: dummy_3pl, std_normal
Random.seed!(42)
(item_bank, question_labels, abilities, responses) = dummy_3pl(;num_questions=100, num_testees=3)

# Simulate a CAT for each testee and record it using CatRecorder.
# CatRecorder collects information which can be used to draw different types of plots.
const max_questions = 99
const integrator = FixedGKIntegrator(-6, 6, 80)
const dist_ability_est = PriorAbilityEstimator(std_normal)
const ability_estimator = MeanAbilityEstimator(dist_ability_est, integrator)
const rules = CatRules(
    ability_estimator,
    AbilityVarianceStateCriterion(dist_ability_est, integrator),
    FixedItemsTerminationCondition(max_questions)
)

const points = 500
xs = range(-2.5, 2.5, length=points)
raw_estimator = LikelihoodAbilityEstimator()
recorder = CatRecorder(xs, responses, integrator, raw_estimator, ability_estimator)
for testee_idx in axes(responses, 2)
    tracked_responses, θ = run_cat(
        CatLoopConfig(
            rules=rules,
            get_response=auto_responder(@view responses[:, testee_idx]),
            new_response_callback=(tracked_responses, terminating) -> recorder(tracked_responses, testee_idx, terminating),
        ),
        item_bank
    )
    true_θ = abilities[testee_idx]
    abs_err = abs(θ - true_θ)
end

# Make a plot showing how the estimated value evolves during the CAT.
# We also plot the 'true' values used to generate the responses.
conv_lines_fig = ability_evolution_lines(recorder; abilities=abilities)
conv_lines_fig 

# Make an interactive plot, showing how the distribution of the ability
# likelihood evolves.

conv_dist_fig = lh_evoluation_interactive(recorder; abilities=abilities)
conv_dist_fig
#md # Item Response Functions for IRT/CAT
#
#md # [![](https://mybinder.org/badge_logo.svg)](@__BINDER_ROOT_URL__/generated/ability_convergence_3pl.ipynb)

include("./import_makie.jl")
using Distributions: Normal, cdf
using ComputerAdaptiveTesting.ExtraDistributions: NormalScaledLogistic

# Typically, the logistic c.d.f. is used as the transfer function in IRT.
# However, it in an IRT context, a scaled version intended to be close to a
# normal c.d.f. is often used. The main advantage is that this is usually faster
# to compute. ComputerAdaptiveTesting provides NormalScaledLogistic, which is
# also used by default, for this purpose:

xs = -8:0.05:8
lines(xs, cdf.(Normal(), xs))
lines!(xs, cdf.(NormalScaledLogistic(), xs))
current_figure()
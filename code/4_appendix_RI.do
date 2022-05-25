*Visualize permutation test
clear all

import delimited "randomization_rep5000.csv"

rename x beta

gr tw kdensity beta, graphregion(color(white)) xline(-0.0082) title("Placebo test", size(small)) range(-0.01 0.01) ///
text(400 -0.0082 "{&beta}=-0.0082 (p-value=0.000)", place(se)) ytitle("Density") xtitle("Coefficients")
graph export placebo.eps, replace

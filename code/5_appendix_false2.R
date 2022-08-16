library(did)
library(tidyverse)
library(foreign)
library(plm)
library(lmtest)
library(xtable)
#Stata code for generating the falsification data
#use "/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/main_sample.dta", clear
#cumul pastureshare2002, gen(c_pasture)
#gen new_pasture_g=0 
#replace new_pasture_g=2007 if c_pasture>.75
#replace new_pasture_g=2008 if c_pasture<.75 & c_pasture>.50
#replace new_pasture_g=2009 if c_pasture<.5 & c_pasture>.25
#saveold "/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/main_sample_false2.dta", replace version(12)

#read data
prf_data<-read.dta("/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/main_sample_false2.dta")

##CS DID##
# Main
# estimate group-time average treatment effects using att_gt method
prf_attgt1 <- att_gt(yname = "crp_share",
                     tname = "t",
                     idname = "fips",
                     gname = "new_pasture_g",
                     panel = TRUE,
                     xformla = ~1+prec2006+temp2006+crpshare2006+pastureshare2002+totalacre2002,
                     allow_unbalanced_panel = TRUE,
                     control_group = c("nevertreated"),
                     clustervar = c("fips"),
                     est_method = "dr",
                     anticipation=0,
                     data = prf_data
)

# summarize the results
summary(prf_attgt1)
# plot
ggdid(prf_attgt1, title = "")
ggsave("raw_att_false2.eps", width = 10, height = 8)
# simple aggregation
agg.sim1 <- aggte(prf_attgt1, type = "simple", alp=0.01)
summary(agg.sim1)

# group-specific effects
agg.gs1 <- aggte(prf_attgt1, type = "group")
summary(agg.gs1)
# plot
ggdid(agg.gs1)

# dynamic effects
agg.es1 <- aggte(prf_attgt1, type = "dynamic", alp=0.01)
summary(agg.es1)
# plot
ggdid(agg.es1)
ggsave("dynamic_main_false2.eps")

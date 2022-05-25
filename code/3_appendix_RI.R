library(did)
library(tidyverse)
library(foreign)
library(plm)
library(lmtest)
library(xtable)

#read data
prf_data<-read.dta("/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/main_sample.dta")

#fips and group
fips.group<-data.frame(prf_data$year, prf_data$fips, prf_data$g)
fips.group<-fips.group %>%
  filter(prf_data.year==2006)
names(fips.group)[1]<-'year'
names(fips.group)[2]<-'fips'
names(fips.group)[3]<-'g'
fips.group<-subset(fips.group, select=c(fips,g))

#number of repetitions
R<-5000

#result table
attsimple<-rep(0,R)

#shuffle g
set.seed(11123)
for(i in 1:R){
  print(i)
fips.group_shuffle=transform(fips.group, g=sample(g))

prf_data<-subset(prf_data, select=-c(g))
prf_data<-merge(prf_data, fips.group_shuffle, by="fips")

##CS DID##
# Main
# estimate group-time average treatment effects using att_gt method
prf_attgt1 <- att_gt(yname = "crp_share",
                     tname = "t",
                     idname = "fips",
                     gname = "g",
                     panel = TRUE,
                     xformla = ~1+prec2006+temp2006+crpshare2006+pastureshare2002+totalacre2002,
                     allow_unbalanced_panel = TRUE,
                     control_group = c("nevertreated"),
                     clustervar = c("fips"),
                     est_method = "dr",
                     anticipation=0,
                     data = prf_data
)

# simple aggregation
agg.sim1 <- aggte(prf_attgt1, type = "simple", alp=0.01)
attsimple[i]<-agg.sim1$overall.att
}
write.table(attsimple,"/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/randomization_rep5000.csv",row.names=FALSE,sep = ",")



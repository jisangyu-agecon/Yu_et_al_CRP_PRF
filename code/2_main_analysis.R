library(did)
library(tidyverse)
library(foreign)
library(plm)
library(lmtest)
library(xtable)

#read data
prf_data<-read.dta("/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/main_sample.dta")
prf_data2<-read.dta("/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/rent_subsample.dta")
prf_data3<-read.dta("/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/full_sample.dta")

##TWFE##
#Main sample
TWFE<-plm(crp_share ~ prf_available + as.factor(year),
          data=prf_data,
          index=c("fips"),
          model="within")
twferesult1<-coeftest(TWFE, vcov=function(x) vcovHC(x, cluster=c("group")))

#Rent subsample
TWFE2<-plm(crp_share ~ prf_available + avg_rent + as.factor(year),
           data=prf_data2,
           index=c("fips"),
           model="within")
twferesult2<-coeftest(TWFE2, vcov=function(x) vcovHC(x, cluster=c("group")))

#Full sample
TWFE3<-plm(crp_share ~ prf_available + as.factor(year),
           data=prf_data3,
           index=c("fips"),
           model="within")
twferesult3<-coeftest(TWFE3, vcov=function(x) vcovHC(x, cluster=c("group")))


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

# summarize the results
summary(prf_attgt1)
# plot
ggdid(prf_attgt1, ylim=c(-0.04,0.02), title = "")
ggsave("raw_att.eps", width = 10, height = 8)
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
ggsave("dynamic_main.eps")

# Rent
# estimate group-time average treatment effects using att_gt method
prf_attgt2 <- att_gt(yname = "crp_share",
                     tname = "t",
                     idname = "fips",
                     gname = "g",
                     panel = TRUE,
                     xformla = ~1+prec2006+temp2006+crpshare2006+pastureshare2002+crprent2006+totalacre2002,
                     allow_unbalanced_panel = TRUE,
                     control_group = c("nevertreated"),
                     clustervar = c("fips"),
                     anticipation=0,
                     data = prf_data2
)

# summarize the results
summary(prf_attgt2)
# plot
ggdid(prf_attgt2, ylim=c(-0.04,0.02))
ggsave("raw_att_rent.eps", width = 10, height = 8)
# simple aggregation
agg.sim2 <- aggte(prf_attgt2, type = "simple", alp=0.01)
summary(agg.sim2)

# group-specific effects
agg.gs2 <- aggte(prf_attgt2, type = "group")
summary(agg.gs2)
# plot
ggdid(agg.gs2)

# dynamic effects
agg.es2 <- aggte(prf_attgt2, type = "dynamic", alp=0.01)
summary(agg.es2)
# plot
ggdid(agg.es2)
ggsave("dynamic_rent.eps")

# Full
# estimate group-time average treatment effects using att_gt method
prf_attgt3 <- att_gt(yname = "crp_share",
                     tname = "t",
                     idname = "fips",
                     gname = "g",
                     panel = TRUE,
                     xformla = ~1+prec2006+temp2006+crpshare2006+pastureshare2002+totalacre2002,
                     control_group = c("nevertreated"),
                     clustervar = c("fips"),
                     anticipation=0,
                     data = prf_data3
)

# summarize the results
summary(prf_attgt3)
# plot
ggdid(prf_attgt3, ncol=2, ylim=c(-0.04,0.02))
ggsave("raw_att_full.eps", width = 10, height = 8)
# simple aggregation
agg.sim3 <- aggte(prf_attgt3, type = "simple")
summary(agg.sim3)

# group-specific effects
agg.gs3 <- aggte(prf_attgt3, type = "group")
summary(agg.gs3)
# plot
ggdid(agg.gs3)

# dynamic effects
agg.es3 <- aggte(prf_attgt3, type = "dynamic")
summary(agg.es3)
# plot
ggdid(agg.es3)
ggsave("dynamic_full.eps")

#Result Table
addparentheses <- function(x){paste("(",x,")")}

twferesult<-matrix(NA,2,3)
twferesult[1,1]<-twferesult1[1,1]
twferesult[2,1]<-twferesult1[1,2]
twferesult[1,2]<-twferesult2[1,1]
twferesult[2,2]<-twferesult2[1,2]
twferesult[1,3]<-twferesult3[1,1]
twferesult[2,3]<-twferesult3[1,2]

attsimple<-matrix(NA,2,3)
attsimple[1,1]<-agg.sim1$overall.att
attsimple[2,1]<-agg.sim1$overall.se
attsimple[1,2]<-agg.sim2$overall.att
attsimple[2,2]<-agg.sim2$overall.se
attsimple[1,3]<-agg.sim3$overall.att
attsimple[2,3]<-agg.sim3$overall.se

attdynamic<-matrix(NA,2,3)
attdynamic[1,1]<-agg.es1$overall.att
attdynamic[2,1]<-agg.es1$overall.se
attdynamic[1,2]<-agg.es2$overall.att
attdynamic[2,2]<-agg.es2$overall.se
attdynamic[1,3]<-agg.es3$overall.att
attdynamic[2,3]<-agg.es3$overall.se

samplesize<-matrix(NA, 1,3)
samplesize[1,1]<-length(prf_data$crp_share)
samplesize[1,2]<-length(prf_data2$crp_share)
samplesize[1,3]<-length(prf_data3$crp_share)


twferesult<-signif(twferesult, c(2,2,2))
attsimple<-signif(attsimple, c(2,2,2))
attdynamic<-signif(attdynamic, c(2,2,2))


twferesult[2,]<-addparentheses(twferesult[2,])
attsimple[2,]<-addparentheses(attsimple[2,])
attdynamic[2,]<-addparentheses(attdynamic[2,])

table1<-rbind(twferesult,attsimple,attdynamic,samplesize)

#Table 1
colnames(table1)<-c("Main Sample","Rent Sample","Full Sample")
rownames(table1)<-c("TWFE", "", "ATT simple", "", "ATT dynamic", "", "N")


print(xtable(table1, type = "latex"), NA.string=TRUE, file = "table1.tex")
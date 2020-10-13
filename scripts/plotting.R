# Requires the "here" library
library(here)
# Requires ggplot2
library(ggplot2)
# A nice ggplot2 theme
source(here("scripts","ggplot_theme.R"))

#--------------------------#
# Load and prepare the data
dataset<-"Maccli" # One of "Maccli", "Machtx", ...

# Load the busco results table
rarefaction_dat<-read.table(here("data",paste(dataset,"_subsampling_rarefaction_dat.csv",sep="")),header=TRUE,sep=",")

#--------------#
# Plot the data
plot1<-ggplot(data=rarefaction_dat)+
  geom_line(aes(x=reads/100000,y=perc_compl))+
  geom_line(aes(x=reads/100000,y=sd_upr_perc_compl),linetype="dashed")+
  geom_line(aes(x=reads/100000,y=sd_lwr_perc_compl),linetype="dashed")+
  geom_line(aes(x=reads/100000,y=max_perc_compl),linetype="dashed",colour="red")+
  geom_hline(yintercept = 30.3,linetype="dotdash")+ # This line is only relevant for my data, I'm
  geom_label(x=-Inf,y=31,hjust=0,label="IsoSeq3 Clusters")+ # This line is only relevant for my data, I'm
  geom_hline(yintercept = 84,linetype="dotdash")+ # This line is only relevant for my data, I'm
  geom_label(x=-Inf,y=85,hjust=0,label="Genome Assembly")+ # This line is only relevant for my data, I'm
  geom_hline(yintercept = 60.1,linetype="dotdash")+ # This line is only relevant for my data, I'm
  geom_label(x=-Inf,y=61,hjust=0,label="Stringtie Genome-Guided Transcriptome Assembly")+ # This line is only relevant for my data, I'm
  ylim(0,100)+
  #  xlim(0,40)+
  #  geom_point(aes(x=size,y=mean,colour=data))+
  xlab(expression(paste("# Subsampled FL CCS Reads (x 10"^5,")")))+
  ylab("% Complete BUSCO Genes")+
  my.theme+
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16))

ggsave(filename=here("figures",paste(dataset,"_plot1.png",sep="")),device = "png",dpi = 300,width = 20,height=15,units="cm")
plot1
dev.off()

plot2<-ggplot()+
  geom_point(data=rarefaction_dat[which(rarefaction_dat$reads>200000),],aes(x=reads/100000, y=perc_compl))+
  geom_smooth(data=rarefaction_dat[which(rarefaction_dat$reads>200000),],aes(x=reads/100000, y=perc_compl),method = "lm")+
  xlab(expression(paste("# Subsampled FL CCS Reads (x 10"^5,")")))+
  ylab("% Complete BUSCO Genes")+
  my.theme

ggsave(filename=here("figures",paste(dataset,"_plot2.png",sep="")),device = "png",dpi = 300,width = 10,height=7,units="cm")
plot2
dev.off()

# Make a linear model based on data from samples with >200k reads where the rate of increase seems more-or-less linear (see plot2).
mod1<-lm(perc_compl~reads,data=rarefaction_dat[which(rarefaction_dat$reads>200000),])
predframe<-data.frame("reads"=seq(2,40)*10^5)
predframe$perc_compl<-predict(mod1,newdata=predframe)

plot1_plus<-plot1<-ggplot(data=rarefaction_dat)+
  geom_line(aes(x=reads/100000,y=perc_compl))+
  geom_line(aes(x=reads/100000,y=sd_upr_perc_compl),linetype="dashed")+
  geom_line(aes(x=reads/100000,y=sd_lwr_perc_compl),linetype="dashed")+
  geom_line(aes(x=reads/100000,y=max_perc_compl),linetype="dashed",colour="red")+
  geom_hline(yintercept = 30.3,linetype="dotdash")+ # This line is only relevant for my data, I'm
  geom_label(x=Inf,y=31,hjust=1,label="IsoSeq3 Clusters")+ # This line is only relevant for my data, I'm
  geom_hline(yintercept = 84,linetype="dotdash")+ # This line is only relevant for my data, I'm
  geom_label(x=-Inf,y=85,hjust=0,label="Genome Assembly")+ # This line is only relevant for my data, I'm
  geom_hline(yintercept = 60.1,linetype="dotdash")+ # This line is only relevant for my data, I'm
  geom_label(x=-Inf,y=61,hjust=0,label="Stringtie Genome-Guided Transcriptome Assembly")+ # This line is only relevant for my data, I'm
  ylim(0,100)+
  #  xlim(0,40)+
  #  geom_point(aes(x=size,y=mean,colour=data))+
  xlab(expression(paste("# Subsampled FL CCS Reads (x 10"^5,")")))+
  ylab("% Complete BUSCO Genes")+
  my.theme+
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16))+
  geom_line(data=predframe,aes(x=reads/100000,y=perc_compl),colour="grey50",linetype="dashed")

ggsave(filename=here("figures",paste(dataset,"_plot1_plus.png",sep="")),device = "png",dpi = 300,width = 15,height=10,units="cm")
plot1_plus
dev.off()

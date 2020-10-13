# Requires ggplot2
library(ggplot2)
# A nice theme
my.theme <- theme(panel.background = element_rect(fill = "white"),
                  panel.grid.major = element_blank(),
                  panel.border = element_rect(colour = "grey50", fill = NA),
                  strip.background = element_rect(colour = "black", fill = "white"), 
                  strip.text = element_text(size = 11),
                  text = element_text(size = 11,colour = "black"),
                  axis.text = element_text(size = 11, colour = "black"))

# Load the busco results table
busco_total<-954 # I'm using the metazoa_odb10 dataset
busco_table<-read.table(
  paste(dir,
        "/rarefaction_test/full_table.tsv",sep=""),header=FALSE,sep="\t",fill = TRUE)
# Subset results to only complete (Single copy) or complete (duplicated) buscos
busco_table<-busco_table[which(busco_table$V2=="Complete" | busco_table$V2=="Duplicated"),]
# this step is unnecessary, just adding a "busco_" tag to the start of each busco ID.
busco_table$V1<-paste("busco_",busco_table$V1,sep="")
head(busco_table)
length(unique(busco_table$V3))

# Read in the cluster report.csv table from the isoseq3 cluster step
trans_read_counts<-read.table(
  paste(dir,
        "/rarefaction_test/m54273_200826_100915.noprimer.ccs.NEB_5p--NEB_Clontech_3p.clustered.cluster_report.csv",
        sep=""),header=TRUE,sep=",")
head(trans_read_counts)
# How many reads per transcript
count<-tapply(trans_read_counts$read_id,INDEX = list(trans_read_counts$cluster_id),length)
transcript<-names(count)
counts_dat<-data.frame("cluster_id"=transcript,"count"=unname(count))
head(counts_dat,n=50)
nrow(counts_dat)
nrow(counts_dat[counts_dat$count >=2,])

trans_read_counts[which(trans_read_counts$cluster_id=="transcript_10037"),]

# Need to rename the transcripts to match the busco output (busco doesn't like the "/" character in names)
trans_read_counts$cluster_id<-gsub("/","_",trans_read_counts$cluster_id)
# Do all transcripts that are identified as BUSCO genes occur in the trans_read_counts table?
length(which(busco_table$V3 %in% trans_read_counts$cluster_id))

# Total number of reads in the trans_read_counts table (each row is matching a read to a transcript)
total_counts<-nrow(trans_read_counts)
# Make a vector of a range of read sample sizes (all the way up to ~100% of reads)
n_reads<-seq(0,10^round(log10(total_counts),digits = 1),by = 1000)
# How many iterations for each read count to do
n_iter<-100

# Vectors to save output
reads<-vector(length=length(n_reads))
mean<-vector(length=length(n_reads))
sd<-vector(length=length(n_reads))
max<-vector(length=length(n_reads))

# Do some sampling (with replacement)
s<-1
for(i in n_reads){
  N_reads<-n_reads[s]
  reads[s]<-N_reads
  iters_n_buscos<-vector(length=n_iter)
  for(j in 1:n_iter){
    # Get a random sample of PBs
    samp<-sample(trans_read_counts$cluster_id,N_reads,replace = TRUE)
    samp<-unique(samp)
    # How many BUSCOs have we samples
    iters_n_buscos[j]<-length(unique(busco_table$V1[which(busco_table$V3 %in% samp)]))
  }
  mean[s]<-mean(iters_n_buscos)
  sd[s]<-sd(iters_n_buscos)
  max[s]<-max(iters_n_buscos)
  s=s+1
}
# Make a dataframe object and some new columns
rarefaction_dat<-data.frame("reads"=reads,"mean"=mean,"sd"=sd,"max"=max)
rarefaction_dat$perc_compl<-(rarefaction_dat$mean/busco_total)*100
rarefaction_dat$sd_upr_perc_compl<-((rarefaction_dat$mean+rarefaction_dat$sd)/busco_total)*100
rarefaction_dat$sd_lwr_perc_compl<-((rarefaction_dat$mean-rarefaction_dat$sd)/busco_total)*100
rarefaction_dat$max_perc_compl<-(rarefaction_dat$max/busco_total)*100

head(rarefaction_dat)

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
  xlab("Number of Subsampled FL CCS Reads (x 10^5)")+
  ylab("Percent Complete BUSCO Genes Detected (%)")+
  my.theme+
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16))
plot1

ggplot()+
  geom_point(data=rarefaction_dat[which(rarefaction_dat$reads>200000),],aes(x=reads/100000, y=perc_compl))+
  geom_smooth(data=rarefaction_dat[which(rarefaction_dat$reads>200000),],aes(x=reads/100000, y=perc_compl),method = "lm")+
  xlab("Number of Subsampled FL CCS Reads (x 10^5)")+
  ylab("Percent Complete BUSCO Genes Detected (%)")+
  my.theme


mod1<-lm(perc_compl~reads,data=rarefaction_dat[which(rarefaction_dat$reads>200000),])
predframe<-data.frame("reads"=seq(2,40)*10^5)
predframe$perc_compl<-predict(mod1,newdata=predframe)

plot1+
  geom_line(data=predframe,aes(x=reads/100000,y=perc_compl),colour="grey50",linetype="dashed")

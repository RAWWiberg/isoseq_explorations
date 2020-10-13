# If you opened this file within the R "Project" all code below should work with the relative file paths

# Requires the "here" library
library(here)
#--------------------------#
# Load and prepare the data
dataset<-"Maccli" # One of "Maccli", "Machtx", ...

# Load the busco results table
busco_table<-read.table(here("data",paste(dataset,"_busco_full_table.tsv",sep="")),header=FALSE,sep="\t",fill = TRUE)
colnames(busco_table)<-c("busco_id","status","transcript","length","length2")
# get the total nr buscos from the busco_table
busco_total<-length(unique(busco_table$busco_id))
# Subset results to only complete (Single copy) or complete (duplicated) buscos
busco_table<-busco_table[which(busco_table$status=="Complete" | busco_table$status=="Duplicated"),]
# this step is unnecessary, just adding a "busco_" tag to the start of each busco ID.
busco_table$busco_id<-paste("busco_",busco_table$busco_id,sep="")

# How many transcripts are in the table
length(unique(busco_table$transcript)) 

# Read in the cluster report.csv table from the isoseq3 cluster step
trans_read_counts<-read.table(here("data",paste(dataset,"_isoseq3_clustered.cluster_report.csv",sep="")),header=TRUE,sep=",")
# Need to rename the transcripts in the trans_read_counts table to match the busco output 
# (busco doesn't like the "/" character in names)
trans_read_counts$cluster_id<-gsub("/","_",trans_read_counts$cluster_id)

# How many reads per transcript
count<-tapply(trans_read_counts$read_id,INDEX = list(trans_read_counts$cluster_id),length)
transcript<-names(count)
counts_dat<-data.frame("cluster_id"=transcript,"count"=unname(count))
nrow(counts_dat)
# How many transcripts with count >= 2
nrow(counts_dat[counts_dat$count >=2,])

# Do all transcripts that are identified as BUSCO genes occur in the trans_read_counts table?
length(which(busco_table$transcript %in% trans_read_counts$cluster_id)) == length(unique(busco_table$transcript)) 

# The number of rows and the counts column should match
nrow(trans_read_counts[which(trans_read_counts$cluster_id=="transcript_10037"),])
counts_dat[which(counts_dat$cluster_id=="transcript_10037"),]

#-----------------------------------#
# Do some down-sampling of CCS reads

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
    # This works because in the cluster_id column the transcript ids occur X number of times, 
    # where X is the number of reads representing that transcript. 
    # Therefore, if we sample with replacement from this column, transcripts with more reads are more likely to be sampled.
    # This kind of assumes that the number of reads representing a transcript is reflective of the true expression level and that
    # the relationship between expression level and the number of sequenced reads will stay the same regardless of sequencing effort.
    samp<-sample(trans_read_counts$cluster_id,N_reads,replace = TRUE)
    samp<-unique(samp)
    # How many BUSCOs have we samples
    iters_n_buscos[j]<-length(unique(busco_table$busco_id[which(busco_table$transcript %in% samp)]))
  }
  mean[s]<-mean(iters_n_buscos)
  sd[s]<-sd(iters_n_buscos)
  max[s]<-max(iters_n_buscos)
  s<-s+1
}

# Make a dataframe object and some new columns
rarefaction_dat<-data.frame("reads"=reads,"mean"=mean,"sd"=sd,"max"=max)
rarefaction_dat$perc_compl<-(rarefaction_dat$mean/busco_total)*100
rarefaction_dat$sd_upr_perc_compl<-((rarefaction_dat$mean+rarefaction_dat$sd)/busco_total)*100
rarefaction_dat$sd_lwr_perc_compl<-((rarefaction_dat$mean-rarefaction_dat$sd)/busco_total)*100
rarefaction_dat$max_perc_compl<-(rarefaction_dat$max/busco_total)*100

head(rarefaction_dat)

# Save this data
write.table(rarefaction_dat,here("data",paste(dataset,"_subsampling_rarefaction_dat.csv",sep="")),
            quote=FALSE,row.names=FALSE,col.names=TRUE,sep=",")


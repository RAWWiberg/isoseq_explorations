
## Some thoughts on IsoSeq data, the isoseq3 pipeline, and the ToFU Cupcake pipeline


# 1. Primer contamination removal
An early step in the isoseq3 analysis pipeline, and indeed any pipeline using isoseq data, is the removal of primer sequences that are left over from the cDNA synthesis steps.

However, it's not immediately obvious what the primer sequences should actually look like. Several "official" sources give somewhat conflicting information.
The result is that there are several sets of primer sequences that one could choose from.

### i) The clustering workflow described on the isoseq3 github repository
The workflow description at [The isoseq3 github repository](https://github.com/PacificBiosciences/IsoSeq/blob/master/isoseq-clustering.md) gives the following option:

"Example 1: Following is the primer.fasta for the Clontech SMARTer and NEB cDNA library prep, which are the officially recommended protocols:"

>NEB_5p
GCAATGAAGTCGCAGGGTTGGG
>Clontech_5p
AAGCAGTGGTATCAACGCAGAGTACATGGGG
>NEB_Clontech_3p
GTACTCTGCGTTGATACCACTGCTT

Which, for some reason, gives two possibilities for a 5p primer.

These, it is said, correspond to the Clontech SMARTer and NEB cDNA library prep kits, both of which are "officially recommended protocols".

Indeed, an earlier (2014-2015) PacBio "Procedures and Checklist" document ("Procedure and Checklist -Isoform Sequencing (Iso-SeqTM) Using the Clontech ® SMARTer ® PCR cDNA Synthesis Kit and BluePippinTM Size-Selection System"; P/N100-377-100-05) lists the "SMARTer PCR cDNA Synthesis Kit" by Clontech (catalog numbers 634925 or 634926), as well as "Additional 5' PCR Primer IIA" as part of the required materials. (A later document "Procedure & Checklist -Iso-SeqTM Template Preparation for SequelTM Systems" P/N100-377-100-05 also cites these kits as required materials).

The manual for the "SMARTer PCR cDNA Synthesis Kit" (available at: https://www.takarabio.com/documents/User%20Manual/SMARTer%20PCR%20cDNA%20Synthesis%20Kit%20User%20Manual%20%28PT4097-1%29_040114.pdf) lists the components and gives the sequences of the included primers:


### [SEE SCREEN CAPTURE 1] ##
Inline-style: ![alt text](https://github.com/RAWWiberg/figures/SMARTer_PCR_cDNA_Synthesis_Kit_User_Manual_LoC.png "screencap1")


The sequence labelled "SMARTer II A Oligonucleotide" corresponds to the sequence above labelled "Clontech_5p"

Meanwhile, the sequence labelled "3' SMART CDS Primer II A" also corresponds to the "Clontech_5p" sequence but with an additional poly-T tail

A slightly more recent PacBio (2019) "Procedures and Checklist" document ("Procedure & Checklist – Iso-SeqTM Express Template
Preparation for Sequel ® and Sequel II Systems"; PN 101-763-800 Version 02 (October 2019)) lists the "NEBNext ® Single Cell/Low Input cDNA Synthesis & Amplification Module" by New England Biosystems, as part of the required materials.

The NEB website and FAQ (available at: https://international.neb.com/products/e6421-nebnext-single-cell-low-input-cdna-synthesis-and-amplification-module#Product%20Information) for this kit lists the sequences included:


## [SEE SCREEN CAPTURE 2] ##


Here, the first sequence (labelled NEBNext Template Switching Oligo") seems to contain the sequence labelled "Clontech_5p" above, but it contains several additional bases.
The second sequence sequence (labelled "NEBNext Single Cell RT Primer") also corresponds, with some differences, to the sequence labelled "Clontech_5p". 
The final sequence similarly is a minor variation of the "Clontech_5p" sequence.

So already there is a bit of confusion as to why exactly these sequences are recommended by the isoseq3 pipeline, since only some of them seem to correspond to sequences in the kits that are recommended in the workflows, and even then sometimes inexactly.


The story gets more complicated, though, because:

# ii) A set of PacBio "Customer Training" slides (dated March 2020) "Iso-Seq-Express-Library-Preparation-Using-SMRTbell-Express-Template-Prep-Kit-2.0-–-Customer-Training" refers, on slide 48, to the "Procedures and Checlist" document from 2019 above (PN 101-763-800), and also gives a link (https://www.pacb.com/wp-content/uploads/IsoSeqPrimers_Express_SMRTLink6.0.fasta_.zip) to a fasta file containing "Iso-Seq Express Oligo Kit" primer sequences which it claims are required to complete the analysis. This fasta file contains the following sequences:


>5p IsoSeq Express Primer
GCAATGAAGTCGCAGGGTT
>3p IsoSeq Express Primer
AAGCAGTGGTATCAACGCAGAGTAC


Indeed the "Procedures and Checlist" (PN 101-763-800) refers to the "Iso-Seq Express Oligo Kit" in the "Materials and Kits Needed" section.

Note that the sequence labelled "5p IsoSeq Express Primer" is the same as the sequence labelled "NEB_5p" above except missing the final 3 bases. Meanwhile the sequence labelled "3p IsoSeq Express Primer" is a close match to the "Clontech_5p" sequence, but missing the final 6 bases.


Finally, the most recent "Procedures and Checklist" document (PN 101-763-800), says on page 5 to add the NEBNext cDNA primers as well as the Iso-Seq Epxress cDNA primers to the sample at the cDNA synthesis steps. But these full sequences are not given on the isoseq3 pipeline clustering workflow website.


In sum, it is really difficult to know a) what has/should have gone into the samples from the procedures and checklist documents, and b) which primer sequences we should be looking for to try to to remove.


Thankfully, the primer removal steps with the lima tool (https://github.com/pacificbiosciences/barcoding) are quite quick for a single sample so we can run a few tests and compare results.






# [INSERT TEST RESULTS HERE] # 








We can also check the raw CCS reads from our Iso-Seq runs manually to see if we can spot the primers that have been incorporated. Doing this for the first 34 reads our samples we see the following:

# [SAMPLE 1] # 

# [SAMPLE 2] # 

# [SAMPLE 3] # 

# [SAMPLE 4] # 


Now we can use these sequences that we have identified and re-run the lima step to see if the results improve

# [INSERT TEST RESULTS HERE] # 



# 2. cDNA_Cupcake pipeline: isoseq3 post-processing and rarefaction analysis


However, it's not clear what this rarefaction analysis is aiming to accomplish. Because the "standard" used for the analysis is all the discovered transcripts, it is really only measuring how many additional transcripts will be discovered with more sequencing effort. But perhaps a more interesting question is "how much sequencing effort do we need to get a good representation of the available transcripts?" 

To answer this question a different standard is needed, a standard that is, at least to some degree, a measure of the total complement of transcripts.

We performed a very similar rarefaction analysis as what is done in  but instead of measuring how many of all the discovered transcripts are present in each subsample, we measured the proportion (%) of complete BUSCO genes that are present in each subsample.











Data statement:
All of the data and scripts required to check these observations are included in this repository.

























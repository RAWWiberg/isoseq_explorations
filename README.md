
## Some thoughts on IsoSeq data, the isoseq3 pipeline, and the ToFU Cupcake pipeline
R. Axel W. Wiberg and [Peter D. Fields](https://github.com/peterdfields)

# 1. Primer contamination removal
An early step in the isoseq3 analysis pipeline, and indeed any pipeline using isoseq data, is the removal of primer sequences (with [lima](https://github.com/pacificbiosciences/barcoding)) that are left over from the cDNA synthesis steps.

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

Indeed, an earlier (2014-2015) PacBio ["Procedures and Checklist" (document P/N100-377-100-05)](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwiVx9mY2bHsAhXDCOwKHVOkAxQQFjAAegQIARAC&url=https%3A%2F%2Fwww.pacb.com%2Fwp-content%2Fuploads%2F2015%2F09%2FProcedure-Checklist-Isoform-Sequencing-Iso-Seq-using-the-Clontech-SMARTer-PCR-cDNA-Synthesis-Kit-and-the-BluePippin-Size-Selection-System.pdf&usg=AOvVaw3R69LeklQlDTu5GRKJFvxx) lists the "SMARTer PCR cDNA Synthesis Kit" by Clontech (catalog numbers 634925 or 634926), as well as "Additional 5' PCR Primer IIA" as part of the required materials. (A later document "Procedure & Checklist -Iso-SeqTM Template Preparation for SequelTM Systems" P/N100-377-100-05 also cites these kits as required materials).

The manual for the "SMARTer PCR cDNA Synthesis Kit" (available [here](https://www.takarabio.com/documents/User%20Manual/SMARTer%20PCR%20cDNA%20Synthesis%20Kit%20User%20Manual%20%28PT4097-1%29_040114.pdf)) lists the components and gives the sequences of the included primers:


![screencap1][screencap1]


The sequence labelled "SMARTer II A Oligonucleotide" corresponds to the sequence above labelled "Clontech_5p"

Meanwhile, the sequence labelled "3' SMART CDS Primer II A" also corresponds to the "Clontech_5p" sequence but with an additional poly-T tail

A slightly more recent PacBio (2019) ["Procedures and Checklist" (document PN 101-763-800, Version 02, October 2019)](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwj-1brb2LHsAhWJ66QKHU15DYoQFjAAegQIAxAC&url=https%3A%2F%2Fwww.pacb.com%2Fwp-content%2Fuploads%2FProcedure-Checklist-Iso-Seq-Express-Template-Preparation-for-Sequel-and-Sequel-II-Systems.pdf&usg=AOvVaw2nrSzQEvwgP8D3E5QvxYY0) lists the "NEBNext ® Single Cell/Low Input cDNA Synthesis & Amplification Module" by New England Biosystems, as part of the required materials.

The NEB website and FAQ (available [here](https://international.neb.com/products/e6421-nebnext-single-cell-low-input-cdna-synthesis-and-amplification-module#Product%20Information)) for this kit lists the sequences included:


![screencap2][screencap2]


Here, the first sequence (labelled "NEBNext Template Switching Oligo") seems to contain the sequence labelled "Clontech_5p" above, but it contains several additional bases.
The second sequence sequence (labelled "NEBNext Single Cell RT Primer") also corresponds, with some differences, to the sequence labelled "Clontech_5p". 
The final sequence similarly is a minor variation of the "Clontech_5p" sequence.
I have highlighted the relevant parts in yellow

So already there is a bit of confusion as to why exactly these sequences are recommended by the isoseq3 pipeline, since only some of them seem to correspond to sequences in the kits that are recommended in the workflows, and even then sometimes inexactly.


The story gets more complicated, though, because:

### ii) A set of PacBio "Customer Training" slides gives another option.
[The slides](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi6ksOG2LHsAhXQ-aQKHYHPAgsQFjAAegQIAhAC&url=https%3A%2F%2Fwww.pacb.com%2Fwp-content%2Fuploads%2FIso-Seq-Express-Library-Preparation-Using-SMRTbell-Express-Template-Prep-Kit-2.0-%25E2%2580%2593-Customer-Training.pdf&usg=AOvVaw2qz-aAkRlD2cCmrskewy7E) (dated March 2020) refer, on slide 48, to the "Procedures and Checlist" document from 2019 (above; PN 101-763-800), and also gives a [link](https://www.pacb.com/wp-content/uploads/IsoSeqPrimers_Express_SMRTLink6.0.fasta_.zip) to a fasta file containing "Iso-Seq Express Oligo Kit" primer sequences which it says are required to complete the analysis within their SMRT Link v6.0 analysis software.

This fasta file contains the following sequences:


    >5p IsoSeq Express Primer
    GCAATGAAGTCGCAGGGTT
    >3p IsoSeq Express Primer
    AAGCAGTGGTATCAACGCAGAGTAC


Indeed the "Procedures and Checlist" (PN 101-763-800 above) refers to the "Iso-Seq Express Oligo Kit" in the "Materials and Kits Needed" section.

Note that the sequence labelled "5p IsoSeq Express Primer" is the same as the sequence labelled "NEB_5p" above except missing the final 3 bases. Meanwhile the sequence labelled "3p IsoSeq Express Primer" is a close match to the "Clontech_5p" sequence, but missing the final 6 bases.


Finally, the most recent "Procedures and Checklist" document (PN 101-763-800), says on page 5 to add the NEBNext cDNA primers as well as the Iso-Seq Epxress cDNA primers to the sample at the cDNA synthesis steps. But these full sequences are not given on the isoseq3 pipeline clustering workflow website.


In sum, it is really difficult to know a) what has/should have gone into the samples from the procedures and checklist documents, and b) which primer sequences we should be looking for to try to to remove.


Thankfully, the primer removal steps with the [lima](https://github.com/pacificbiosciences/barcoding) tool are quite quick for a single sample so we can run a few tests and compare results.





### [INSERT TEST RESULTS HERE] # 








We can also check the raw CCS reads from our Iso-Seq runs manually to see if we can spot the primers that have been incorporated. Doing this for the first 34 reads our samples we see the following:

### [SAMPLE 1] # 

### [SAMPLE 2] # 

### [SAMPLE 3] # 

### [SAMPLE 4] # 


Now we can use these sequences that we have identified and re-run the lima step to see if the results improve

### [INSERT TEST RESULTS HERE] # 



### Conclusions

Make sure you know what protocol is being followed to produce the libraries and what primers are going into the sample.

Fairly quick to check the first ~30 CCS reads as a sanity check that the primers are correct.



# 2. cDNA_Cupcake pipeline: 
### isoseq3 post-processing and rarefaction analysis

[cDNA_Cupcake](https://github.com/Magdoll/cDNA_Cupcake)

However, it's not clear what this rarefaction analysis is aiming to accomplish. Because the "standard" used for the analysis is all the discovered transcripts, it is really only measuring how many additional transcripts will be discovered with more sequencing effort. Clearly there are not an infinite number of transcripts available to sample within a cell. So perhaps a more sensible question is "how much sequencing effort do we need to get a good representation of full complement of transcripts within the sample?"  

To answer this question a different standard is needed, a standard that is, at least to some degree, a measure of the total complement of transcripts.

We performed a very similar rarefaction analysis as what is done in cDNA_Cupcake, but instead of measuring how many of the set of discovered transcripts are present in each subsample, we measured the percent (%) of complete BUSCO (duplicated and single-copy) genes that are present in each subsample.

Full details can be followed in the R script that you can find in the `scripts` folder of this repository.

Briefly, I use the clusters produced by the isoseq3 pipeline along with the `*cluster_report.csv` file which is produced bu the `isoseq3 polish` step


![fig1][fig1]

The figure above shows the mean (solid black line), SE (black dashed lines), and max (dashed red line) percentage of BUSCO genes recovered as a function of the number of CCS reads sampled.
Also shown are some benchmark values of the percentage of BUSCO genes recovered from a whole-genome assembly of the same organism from which our Iso-Seq data come, a genome-guided transcriptome assembly based on the genome assembly and Illumina RNA-seq data, and the isoseq3 clusters for reference.

We can zoom in on the data for samples with >200,000 reads to see that the trend is almost linear at this point (though not quite).

![fig2][fig2]

If we fit a regression line to that data, and extrapolate out to 4 million CCS reads. We obtain the following figure.

![fig3][fig3]

Where the grey dashed line charts the extrapolations from the regression model. Only at ~4 million CCS reads does it cross the threshhold for the genome assembly.
In reality, it will probably cross much later since a linear regression model is not 100% appropriate in this case, there is still some curvature to the trend.

### Conclusions

In our case one SMRT cell was clearly not enough to get a good representation of the genes. 

Based on the extrapolations we would need ~4 million CCS reads to achieve the same results as the genome assembly threshhold. This corresponds to ~16 SMRT cells on the Sequel and 2-3 on the Sequel II.



#### Data statement:
All of the data and scripts required to check these observations are included in this repository.



[screencap1]: /figures/SMARTer_PCR_cDNA_Synthesis_Kit_User_Manual_LoC.png "screencap1"
[screencap2]: /figures/NEBNext_Single_Cell_Low_Input_cDNA_Synthesis_and_Amplification_Module_FAQ.png "screencap2"

[fig1]:/figures/Maccli_plot1.png
[fig2]:/figures/Maccli_plot2.png
[fig3]:/figures/Maccli_plot1_plus.png















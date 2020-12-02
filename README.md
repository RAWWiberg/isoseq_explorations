
## Some thoughts on IsoSeq data and primer contamination removal
R. Axel W. Wiberg and [Peter D. Fields](https://github.com/peterdfields)

# Primer contamination removal
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

In sum, it is really difficult to know from this diverse information a) what has/should have gone into the samples from the procedures and checklist documents, and b) which primer sequences we should be looking for to try to to remove.

### Testing

Thankfully, the primer removal steps with the [lima](https://github.com/pacificbiosciences/barcoding) tool are quite quick for a single sample so we can run a few tests and compare results.

#### Table 1
![screencap3][screencap3]

Here we can see that the best results (most number of reads passing all threshholds, second row), are given by the set of primers given on the isoseq3 website (second column labelled "primers_isoseq3").

We can also check the raw CCS reads from our Iso-Seq runs manually to see if we can spot the primers that have been incorporated. Doing this for the first 34 reads our samples we see the following:

![screencap4][screencap4]

Here I have the first 60 bases of each of the first 34 reads of one sample. I have highlighted the regions that correspond to one of the several primer sequences above (delimited with a '#') and at the end of the line I write which primer seems to be the best match.
This example clearly shows that there are two common sequences at 5' and 3' ends of transcripts. These correspond to the sequences labelled "NEB_5p" and "3p IsoSeq Express Primer" above.
See the files in the /data/ folder for full results from two separate isoseq samples.

Now we can use these sequences that we have identified and re-run the lima step to see if the results improve. I run lima with the following file (primers_empirical.fasta), formatted to be compatible with lima.

	>IsoSeq_Express_Primer_3p
	AAGCAGTGGTATCAACGCAGAGTAC
	>NEB_5p
	GCAATGAAGTCGCAGGGTTGGG


#### Table 2
![screencap5][screencap5]

This figure shows the same columns as in table 1 above as well as the primer removal steps using the primers that we empirically discovered from eyeballing the first 34 reads in the samples.
The take home message from this is: a) We can see that there is the same number of input CCS reads (first row), and ii) The number of reads that pass all threshholds (second row) is highest for the test using the empirically identified primer sequences (last column).

See the .xlsx file in the /data/ folder for full results, including ones from a second sample of isoseq data. The same conclusions apply there.


### Conclusions

1) Make sure you know what protocol is being followed to produce your libraries and what primers are going into the sample. Even if this is known, it is a good idea and fairly quick to check the first ~30-50 CCS reads as a sanity check that the primers are correct.

2) None of the recommended sets of primers to use for adapter trimming, at least in this case, corresponds to the correct set of primers as determined empirically by looking at the reads.

3) Using the correct set of primers results in the retention of more CCS reads during the trimming step.


[screencap1]: /figures/SMARTer_PCR_cDNA_Synthesis_Kit_User_Manual_LoC.png "screencap1"
[screencap2]: /figures/NEBNext_Single_Cell_Low_Input_cDNA_Synthesis_and_Amplification_Module_FAQ.png "screencap2"
[screencap3]: /figures/primer_removal_tests1.png "screencap3"
[screencap4]: /figures/primers_in_reads.png "screencap4"
[screencap5]: /figures/primer_removal_tests2.png "screencap5"














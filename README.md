## BBS_Abundance
Abundance Distribution pattern changes over time


### Data/code DOI:
__________________________________________________________________________________________________________________________________________

## Abstract
The abundant-center hypothesis is a foundational idea in ecology, but previous work has largely assumed static patterns. Our objective was to quantify temporal variation in within-range abundance patterns and link those dynamics to traits related to demographic parameters and dispersal. To do so, we used the North American Breeding Bird Survey data for 203 species in historical (1980–1990) and recent (2013–2023) decades. We found that 18% of species showed changes in their within-range abundance pattern between the periods; 21% showed an abundant-center pattern in 1980–1990 while 27% showed an abundant-center pattern in 2013–2023. Species with large population changes, fast life histories, high dispersal ability, and predominantly noncoastal range edges were disproportionately likely to show changes in their within-range abundance patterns. These findings showed that abundant-center patterns are not fixed and highlight the importance of incorporating temporal dynamics into macroecological studies and conservation planning. 

 $~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$ <img src="./Figures/Figure_1.png" width="600" />
## Repository Directory

### code 
  * [01_data_filtering.R](./code/01_data_filtering.R). This script download Breeding bird survey data and eBird data, standardize species taxonomy, estimate range coverage and get the abundance data set for 1980–1990 and 2013–2023.
  * [02_data_filtering.R](./code/02_data_filtering.R). Quick script to filter species to remove waterbirds, kingfishers, owls, nightjars and dipper and filter species based on the range proportion
  * [03_pattern_classification.R](./code/03_pattern_classification.R). Script to classify within-range abundance pattern for each species and create the major edge type variable
  * [04_specieslist_add.R](./code/04_specieslist_add.R). Quick script to input the species list with proper scientific names to extract functional trait through different databases
  * [05_functional_traits.R](./code/05_functional_traits.R). Extraction of functional traits using different databases
  * [06_trait_imputation.R](./code/06_trait_imputation.R). Imputation of functional traits extracted through different databases.
  * [07_phylogenetic_pca.R](./code/07_phylogenetic_pca.R). Conducting phylogenetic principal component analysis and adding the population trend data set into the main data set.
  * [08_structuring.R](./code/08_structuring.R). Re-structuring the data set and adding additional functional traits to the data
  * [09_ACE_REDG_partitioning.R](./code/09_ACE_REDG_partitioning.R). Re-defining the abundant-center and rare-edge patterns, carrying out summary statistics on within-range abundance pattern, creating bar graph for change status
  * [10_REDG_GLM.R](./code/10_REDG_GLM.R). Fitting GLMs to see the association between the functional traits and the rare-edge pattern change through years
  * [11_ACE_GLM.R](./code/11_ACE_GLM.R). Fitting GLMs to see the association between the functional traits and the abundant-center pattern change through years
  * [12_REDG_GLM_figs.R](./code/12_REDG_GLM_figs.R). Creating the predictive probability plots for the rare-edge pattern changes association with the functional traits
  * [13_ACE_GLM_figs.R](./code/13_ACE_GLM_figs.R). Creating the predictive probability plots for the abundant-center pattern changes association with the functional traits
  * [14_conditional_inference_tree.R](./code/14_conditional_inference_tree.R). Script for the conditional inference tree analysis done to see the specific pattern change association with the selected functional traits for both abundant-center and rare-edge patterns
  * [15_abundance_histograms.R](./code/15_abundance_histograms.R). Script to create within-range abundance pattern histograms for each species in historical and recent data

### data

  * [all_birds_merged.xlsx](./Data/all_birds_merged.xlsx). Table representing the species status whether it is a core species or not according to the [Sauer et al. 2017](https://bioone.org/journals/the-condor/volume-119/issue-3/CONDOR-17-83.1/The-first-50-years-of-the-North-American-Breeding-Bird/10.1650/CONDOR-17-83.1.full).
    | column | meaning |
    |--------|---------|
    | Common name | Common name of the species per [Sauer et al. 2017](https://bioone.org/journals/the-condor/volume-119/issue-3/CONDOR-17-83.1/The-first-50-years-of-the-North-American-Breeding-Bird/10.1650/CONDOR-17-83.1.full) |
    | Scientific name | scientific name of the species per [Sauer et al. 2017](https://bioone.org/journals/the-condor/volume-119/issue-3/CONDOR-17-83.1/The-first-50-years-of-the-North-American-Breeding-Bird/10.1650/CONDOR-17-83.1.full) |
    | Core | Categorical with two level (core, non-core); Whether the species is core species or not according the [Sauer et al. 2017](https://bioone.org/journals/the-condor/volume-119/issue-3/CONDOR-17-83.1/The-first-50-years-of-the-North-American-Breeding-Bird/10.1650/CONDOR-17-83.1.full)  |


   * [SpeciesList.csv](./Data/SpeciesList.csv) Table for list of taxa for which there are data in the 1966-2022 Breeding Bird Survey data release
      | column | meaning |
      |--------|---------|
      | Seq | Phylogenetic sequence number per Breeding Bird Survey data|
      | AOU | The unique taxa ID number. This is unique identifier is used for BBS data management and throughout the data release files in place of species name |
      | English_Common_Name | Common English name of the taxa per Breeding bird survey data |
      | French_Common_Name | Common French name of the taxa per Breeding bird survey data |
      | Order | Order of which the species belongs to |
      | Family | Family of which the species belongs to |
      | Genus | Genus of which the species belongs to |
      | Species | Species epithet of the scientific name |
   * [Trends_df.csv](./Data/Trends_df.csv) Table representing the percentage change of population size between 1993–2015 according to the [Sauer et al. 2017](https://bioone.org/journals/the-condor/volume-119/issue-3/CONDOR-17-83.1/The-first-50-years-of-the-North-American-Breeding-Bird/10.1650/CONDOR-17-83.1.full)
      | column | meaning |
      |--------|---------|
      | aou |  The unique taxa ID number. This is unique identifier is used for BBS data management and throughout the data release files in place of species name |
      | Trend | Percentage change of population per year from 1993–2015 |
  
   *** NOTE ** AllBirdsHackett1.tre is not included in this repository due to file size limitations. We retrieved this phylogenetic tree data from the [BirdTree.org](https://birdtree.org/) -> Downloads -> Full trees (9993 species), Hackett backbone ->      HackettStage2_0001_1000. A zip file was downloaded. Then clicked through each file until it reached the combinedTrees and the AllBirdsHackett1.tre can be found within that.

### Figures

  * [Figure_1.png](./Figures/Figure_1.png) Figure 1
  * [Figure_1.ai](./Figures/Figure_1.ai) Figure 1 (Adobe illustrator format)
  * [Figure_2.png](./Figures/Figure_2.png) Figure 2
  * [Figure_2.ai](./Figures/Figure_2.ai) Figure 2 (Adobe illustrator format)
  * [Figure_3.png](./Figures/Figure_3.png) Figure 3
  * [Figure_3.ai](./Figures/Figure_3.ai) Figure 3 (Adobe illustrator format)
  * [Figure_4.png](./Figures/Figure_4.png) Figure 4
  * [Figure_4.ai](./Figures/Figure_4.ai) Figure 4 (Adobe illustrator format)

### Results

***** Note *** The following description contains the input data and the output data/results saved on the R workspace to be used in the Rcripts. The above RScripts in the code section were labelled with a number and the code should be run in that order. Also if you want to produce a certain Rscript, make sure to run the precedent script which produce the input data sets for the relevant Rscript.


---

* [01_data_filtering.R](./code/01_data_filtering.R)

- **Input data**
  - `all_birds_merged.xlsx`

- **Output data**
  - `abundance_first_dec.csv`
  - `abundance_last_dec.csv`
  - `prop_species_all_final.csv`
  - `bbs_routes_select.csv`

---

* [02_data_filtering.R](./code/02_data_filtering.R)

- **Input data**
  - `abundance_first_dec.csv`
  - `abundance_last_dec.csv`
  - `prop_species_all_final.csv`

- **Output data**
  - `det_summary_exp.csv`

---

* [03_pattern_classification.R](./code/03_pattern_classification.R)

- **Input data**
  - `abundance_first_dec.csv`
  - `abundance_last_dec.csv`
  - `det_summary_exp.csv`
  - `bbs_routes_select.csv`

- **Output data**
  - `edge_type_dat.csv`
  - `sp_rich_dat.csv`
  - `hyp_final_df.csv`
  - `03_pattern_classification.RData`

---

* [04_specieslist_add.R](./code/04_specieslist_add.R)

- **Input data**
  - `hyp_final_df.csv`
  - `SpeciesList.csv`

- **Output data**
  - `trans_df_2.csv`

---

* [05_functional_traits.R](./code/05_functional_traits.R)

- **Input data**
  - `trans_df_2.csv`

- **Output data**
  - `func_trait_df.csv`

---

* [06_trait_imputation.R](./code/06_trait_imputation.R)

- **Input data**
  - `func_trait_df.csv`

- **Output data**
  - `func_trait_complete.csv`

---

* [07_phylogenetic_pca.R](./code/07_phylogenetic_pca.R)

- **Input data**
  - `func_trait_complete.csv`
  - `Trends_df.csv`
  - `AllBirdsHackett1.tre`

- **Output data**
  - `func_pca.csv`
  - `ppca_pc_perc.csv`
  - `pc_loading_summary.csv`
  - `all_ppca.RData`
  - `species_pc_name_aou.csv`
  - `07_phylogenetic_pca.RData`
  - `pc_score_df.csv`

---

* [08_structuring.R](./code/08_structuring.R)

- **Input data**
  - `func_pca.csv`

- **Output data**
  - `func_an.csv`

---

* [09_ACE_REDG_partitioning.R](./code/09_ACE_REDG_partitioning.R)

- **Input data**
  - `func_trait_df.csv`
  - `func_an.csv`
  - `prop_species_all_final.csv`
  - `edge_type_dat.csv`

- **Output data**
  - `func_an_ACE.csv`
  - `func_an_REDG.csv`
  - `prop_species_3.csv`

---

* [10_REDG_GLM.R](./code/10_REDG_GLM.R)

- **Input data**
  - `func_an_REDG.csv`
  - `sp_rich_dat.csv`

- **Output data**
  - `REDG_selected_model_data_3.RData`
  - `10_REDG_GLM.RData`
  - `cor_matrix.csv`
  - `REDG.AW_akike.csv`

---

* [11_ACE_GLM.R](./code/11_ACE_GLM.R)

- **Input data**
  - `func_an_ACE.csv`
  - `sp_rich_dat.csv`

- **Output data**
  - `ACE_selected_model_data_3.RData`
  - `ACE_SW_AKike.csv`
  - `ACE_pattern_change_data.csv`

---

* [12_REDG_GLM_figs.R](./code/12_REDG_GLM_figs.R)

- **Input data**
  - `REDG_selected_model_data_3.RData`

---

* [13_ACE_GLM_figs.R](./code/13_ACE_GLM_figs.R)

- **Input data**
  - `ACE_selected_model_data_3.RData`

---

* [14_conditional_inference_tree.R](./code/14_conditional_inference_tree.R)

- **Input data**
  - `REDG_selected_model_data_3.RData`
  - `ACE_selected_model_data_3.RData`

---

* [15_abundance_histograms.R](./code/15_abundance_histograms.R)

- **Input data**
  - `03_pattern_classification.RData`


### BBS_Abundance..Rproj

R Project for organizing/accessing data and code in RStudio IDE

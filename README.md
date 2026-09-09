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

## BBS_Abundance
Abundance Distribution pattern changes over time


### Data/code DOI:
__________________________________________________________________________________________________________________________________________

## Abstract
The abundant-center hypothesis is a foundational idea in ecology, but previous work has largely assumed static patterns. Our objective was to quantify temporal variation in within-range abundance patterns and link those dynamics to traits related to demographic parameters and dispersal. To do so, we used the North American Breeding Bird Survey data for 203 species in historical (1980–1990) and recent (2013–2023) decades. We found that 18% of species showed changes in their within-range abundance pattern between the periods; 21% showed an abundant-center pattern in 1980–1990 while 27% showed an abundant-center pattern in 2013–2023. Species with large population changes, fast life histories, high dispersal ability, and predominantly noncoastal range edges were disproportionately likely to show changes in their within-range abundance patterns. These findings showed that abundant-center patterns are not fixed and highlight the importance of incorporating temporal dynamics into macroecological studies and conservation planning. 

 $~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$ <img src="https://github.com/n-a-gilbert/cavity_macroecology/blob/main/figures/figure_01.png" width="600" />
## Repository Directory

### code 
  * [1.1_download_cavity_nester_range_maps.R](./code/1.1_download_cavity_nester_range_maps.R). This script download Breeding bird survey data and eBird data, standardize species taxonomy, estimate range coverage and get the abundance data set for 1980–1990 and 2013–2023.
  * [1.2_identify_north_american_cavity_nesters.R](./code/1.2_identify_north_american_cavity_nesters.R). Quick script to filter species to remove waterbirds, kingfishers, owls, nightjars and dipper and filter species based on the range proportion
  * [1.3_make_list_of_cavity_nesters_to_review.R](./code/1.3_make_list_of_cavity_nesters_to_review.R). Script to classify within-range abundance pattern for each species and create the major edge type variable
  * [1.4_create_list_of_species_to_download_abundance_maps.R](./code/1.4_create_list_of_species_to_download_abundance_maps.R). Quick script to input the species list with proper scientific names to extract functional trait through different databases
  * [1.5_download_ebird_abundance_maps.R](./code/1.5_download_ebird_abundance_maps.R). Extraction of functional traits using different databases
  * [1.6_create_focal_area_shapefile](./code/1.6_create_focal_area_shapefile.R). Imputation of functional traits extracted through different databases.
  * [1.7_join_van_der_hoek_dataset.R](./code/1.7_join_van_der_hoek_dataset.R). Conducting phylogenetic principal component analysis and adding the population trend data set into the main data set.
  * [2.1_calculate_coast_distance.R](./code/2.1_calculate_coast_distance/R). Re-structuring the data set and adding additional functional traits to the data
  * [2.2_calculate_range_edge_distance.R](./code/2.2_calculate_range_edge_distance.R). Re-defining the abundant-center and rare-edge patterns, carrying out summary statistics on within-range abundance pattern, creating bar graph for change status
  * [2.3_calculate_diversity_per_cell.R](./code/2.3_calculate_diversity_per_cell.R). Fitting GLMs to see the association between the functional traits and the rare-edge pattern change through years
  * [3.1_fit_cross_species_models.R](./code/3.1_fit_cross_species_models.R). Fitting GLMs to see the association between the functional traits and the abundant-center pattern change through years
  * [3.2_supercompetitor_analysis_figure_06.R](./code/3.2_supercompetitor_analysis_figure_06.R). Creating the predictive probability plots for the rare-edge pattern changes association with the functional traits
  * [4.1_create_figure_01b.R](./code/4.1_create_figure_01b.R). Creating the predictive probability plots for the abundant-center pattern changes association with the functional traits
  * [4.2_create_maps_figure_02.R](./code/4.2_create_maps_figure_02.R). Script for the conditional inference tree analysis done to see the specific pattern change association with the selected functional traits for both abundant-center and rare-edge patterns


### Figures ####

load(here::here("Rdata/03_pattern_classification.RData"))

library(tidyverse)
##Meleagris gallopavo
## it changes from rare edge to non rare edge let's see

full_hyp_df |> 
  filter(species == "Polioptila caerulea") |> 
  group_by(bin20_first) |> 
  summarise(
    abundance = median(mean_abundance_first)
  ) |> 
  ungroup() |> 
  ggplot(aes(x = bin20_first, y = abundance))+
  geom_histogram(stat = "identity", bins = 20, binwidth = 50, fill = "#ed1c24")+
  scale_x_reverse(breaks = seq(0, 20, by = 5))+
  scale_y_continuous(limits = c(0, 5), breaks = seq(0, 5, 1))+
  theme(panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size = 29),
        axis.text = element_text(size = 22),
  )+
  xlab("bin number")+
  ylab("mean abundance")


ggsave(here::here("Figures/Polioptila caerulea_first_2.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       height = 7,
       width = 9)



full_hyp_df |> 
  filter(species == "Polioptila caerulea") |> 
  group_by(bin20_last) |> 
  summarise(
    abundance = median(mean_abundance_last)
  ) |> 
  ungroup() |> 
  ggplot(aes(x = bin20_last, y = abundance))+
  scale_y_continuous(limits = c(0, 5), breaks = seq(0, 5, 1))+
  geom_histogram(stat = "identity", bins = 20, binwidth = 50, fill = "#ed1c24")+
  scale_x_reverse(breaks = seq(0, 20, by = 5))+
  theme(panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size = 29),
        axis.text = element_text(size = 22),
  )+
  xlab("bin number")+
  ylab("mean abundance")

ggsave(here::here("Figures/Polioptila caerulea_last_2.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       height = 7,
       width = 9)




# looop for all species, first decade

species_names <- unique(hyp_final_df$species)

for(sp in species_names){
  
  full_hyp_df |> 
    filter(species == sp) |> 
    group_by(bin20_first) |> 
    summarise(
      abundance = median(mean_abundance_first)
    ) |> 
    ungroup() |> 
    ggplot(aes(x = bin20_first, y = abundance))+
    geom_histogram(stat = "identity", bins = 20, binwidth = 50, fill = "darkred")+
    scale_x_reverse(breaks = seq(0, 20, by = 5))+
    theme(panel.background = element_rect(fill = "white"),
          axis.line = element_line(colour = "black"),
          axis.title = element_text(size = 29),
          axis.text = element_text(size = 22),
          plot.title = element_text(size = 24,
                                    face = "italic",
                                    hjust = 0.5)
    )+
    xlab("Bin number")+
    ylab("Mean abundance")+
    ggtitle(sp) -> p
  
  ggsave(here::here(paste0("Figures/first/", sp, "_first_2.jpg")),
         plot = p,
         dpi = 600,
         units = "in",
         height = 7,
         width = 9)
}



## for last decade

for(sp in species_names){
  
  full_hyp_df |> 
    filter(species == sp) |> 
    group_by(bin20_last) |> 
    summarise(
      abundance = median(mean_abundance_last)
    ) |> 
    ungroup() |> 
    ggplot(aes(x = bin20_last, y = abundance))+
    geom_histogram(stat = "identity", bins = 20, binwidth = 50, fill = "darkred")+
    scale_x_reverse(breaks = seq(0, 20, by = 5))+
    theme(panel.background = element_rect(fill = "white"),
          axis.line = element_line(colour = "black"),
          axis.title = element_text(size = 29),
          axis.text = element_text(size = 22),
          plot.title = element_text(size = 24,
                                    face = "italic",
                                    hjust = 0.5)
    )+
    xlab("Bin number")+
    ylab("Mean abundance")+
    ggtitle(sp) -> p
  
  ggsave(here::here(paste0("Figures/last/", sp, "_last_2.jpg")),
         plot = p,
         dpi = 300,
         units = "in",
         height = 7,
         width = 9)
}

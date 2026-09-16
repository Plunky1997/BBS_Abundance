###### Model analysis figures ######

load(here::here("REDG_selected_model_data_3.RData"))


summary(model_REDG)


## create for each variable

library(tidyverse)


new_data_Trend <- data.frame(
  Trend = seq(from = min(func_an_REDG$Trend), to = max(func_an_REDG$Trend), 
              length = nrow(func_an_REDG)
  ),
  Hand.wing.Index = rep(mean(func_an_REDG$Hand.wing.Index), nrow(func_an_REDG)),
  pc1 = rep(mean(func_an_REDG$pc1), nrow(func_an_REDG)),
  edge_type = rep(c("coastline"), nrow(func_an_REDG))
)


predict_Trend <- predict(model_REDG, new_data_Trend, se.fit = T,
                         type = "link")

new_data_Trend |> 
  mutate(
    fitted = plogis(predict_Trend$fit),
    upper =  plogis(predict_Trend$fit + 1.96 * predict_Trend$se.fit),
    lower = plogis(predict_Trend$fit - 1.96 * predict_Trend$se.fit)
  ) -> pred_df



ggplot()+
  geom_blank(data = func_an_REDG, aes(x = Trend, y = change))+
  geom_ribbon(data = pred_df, aes(x = Trend, y = fitted,ymin = lower, ymax = upper,
                                  alpha = 0.1), fill = "#0d7d87")+
  geom_line(data = pred_df, aes(x = Trend, y = fitted), linewidth = 1.5,
            color = "#0d7d87")+
  theme(panel.background = element_rect(fill = "white"),
        axis.line = element_line(color = "black"),
        axis.title = element_text(size = 29),
        axis.text = element_text(size = 22),
        legend.position = "none")+
  xlab("Population Trend")+
  ylab("Probability of pattern change")


ggsave(here::here("Figures/REDG_Trend.jpg"),
       dpi = 600,
       units = "in",
       width = 9,
       height = 7)



ggsave(here::here("Figures/REDG_Trend.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       width = 9,
       height = 7)

## do for the PC1 #######

new_data_PC1 <- data.frame(
  pc1 = seq(from = min(func_an_REDG$pc1), to = max(func_an_REDG$pc1), 
            length = nrow(func_an_REDG)
  ),
  Hand.wing.Index = rep(mean(func_an_REDG$Hand.wing.Index), nrow(func_an_REDG)),
  Trend = rep(mean(func_an_REDG$Trend), nrow(func_an_REDG)),
  edge_type = rep("coastline", nrow(func_an_REDG))
)


predict_pc1 <- predict(model_REDG, new_data_PC1, se.fit = T,
                       type = "link")

new_data_PC1 |> 
  mutate(
    fitted = plogis(predict_pc1$fit),
    upper = plogis(predict_pc1$fit + 1.96 * predict_pc1$se.fit),
    lower = plogis(predict_pc1$fit - 1.96 * predict_pc1$se.fit)
  ) -> pred_df_pc1



ggplot()+
  geom_blank(data = func_an_REDG, aes(x = pc1, y = change))+
  geom_ribbon(data = pred_df_pc1, aes(x = pc1, y = fitted,ymin = lower, ymax = upper,
                                      alpha = 0.1), fill = "#4a2377")+
  geom_line(data = pred_df_pc1, aes(x = pc1, y = fitted), linewidth = 1.5,
            color = "#4a2377")+
  theme(panel.background = element_rect(fill = "white"),
        axis.line = element_line(color = "black"),
        axis.title = element_text(size = 29),
        axis.text = element_text(size = 22),
        legend.position = "none")+
  xlab("PC1 (Reproductive slowness)")+
  ylab("Probability of pattern change")


ggsave(here::here("Figures/REDG_pc1.jpg"),
       dpi = 600,
       units = "in",
       width = 9,
       height = 7)



ggsave(here::here("Figures/REDG_pc1.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       width = 9,
       height = 7)


##### Hand wing index #######




new_data_hwi <- data.frame(
  Hand.wing.Index = seq(from = min(func_an_REDG$Hand.wing.Index), 
                        to = max(func_an_REDG$Hand.wing.Index), 
                        length = nrow(func_an_REDG)
  ),
  pc1 = rep(mean(func_an_REDG$pc1), nrow(func_an_REDG)),
  Trend = rep(mean(func_an_REDG$Trend), nrow(func_an_REDG)),
  edge_type = rep(c("coastline"), nrow(func_an_REDG))
)


predict_Hand.wing.Index <- predict(model_REDG, new_data_hwi, se.fit = T,
                                   type = "link")

new_data_hwi |> 
  mutate(
    fitted = plogis(predict_Hand.wing.Index$fit),
    upper = plogis(predict_Hand.wing.Index$fit + 1.96 * predict_Hand.wing.Index$se.fit),
    lower = plogis(predict_Hand.wing.Index$fit - 1.96 * predict_Hand.wing.Index$se.fit)
  ) -> pred_df_Hand.wing.Index



ggplot()+
  geom_blank(data = func_an_REDG, aes(x = Hand.wing.Index, y = change))+
  geom_ribbon(data = pred_df_Hand.wing.Index, aes(x = Hand.wing.Index, y = fitted,ymin = lower, ymax = upper,
                                                  alpha = 0.1), fill = "#8cc5e3")+
  geom_line(data = pred_df_Hand.wing.Index, aes(x = Hand.wing.Index, y = fitted), linewidth = 1.5,
            color = "#8cc5e3")+
  theme(panel.background = element_rect(fill = "white"),
        axis.line = element_line(color = "black"),
        axis.title = element_text(size = 29),
        axis.text = element_text(size = 22),
        legend.position = "none")+
  xlab("log(Hand Wing Index)")+
  ylab("Probability of pattern change")


ggsave(here::here("Figures/REDG_Hand.wing.Index.jpg"),
       dpi = 600,
       units = "in",
       width = 9,
       height = 7)


ggsave(here::here("Figures/REDG_Hand.wing.Index.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       width = 9,
       height = 7)



#edge_type


new_df <- data.frame(edge_type = factor(c("coastline", "inland")),
                     pc1 = mean(func_an_REDG$pc1),
                     Hand.wing.Index = mean(func_an_REDG$Hand.wing.Index),
                     Trend = mean(func_an_REDG$Trend))


predict_edge <- predict(model_REDG, newdata = new_df, type = "link", se.fit = T)


new_df$fitted <- plogis(predict_edge$fit)
new_df$lower <- plogis(predict_edge$fit - 1.96*predict_edge$se.fit)
new_df$upper <- plogis(predict_edge$fit + 1.96*predict_edge$se.fit)



ggplot(new_df, aes(x = edge_type, y = fitted, fill = edge_type)) +
  geom_point(color = "#f55f74", size = 5.3) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0, linewidth = 1, color = "#f55f74") +
  labs(
    x = "Edge type",
    y = "Probability of pattern change"
  )+
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25))+
  theme(panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size = 26),
        axis.text = element_text(size = 19),
        legend.position = "none")



ggsave(here::here("Figures/REDG_Edge_type.jpg"),
       dpi = 600,
       units = "in",
       width = 9,
       height = 7)


ggsave(here::here("Figures/REDG_Edge_type.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       width = 9,
       height = 7)

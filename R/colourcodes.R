library(covidregionaldata)
library(tidyverse)
library(ggplot2)
library(gganimate)
library(roll)

ltu_national_data <- get_regional_data(country="Lithuania",
                                    totals=FALSE,
                                    level = 2,
                                    localise = TRUE,
                                    all_osp_fields = TRUE,
                                    national_data = TRUE) %>%
  filter(municipality == "Lietuva") %>%
#  group_by(date) %>%
  select(-municipality, -iso_3166_2_municipality, -county, -iso_3166_2)

## Colour coded regions

# colour coding ----

colour_code <- function( mean_test_positivity, fourteen_day_incidence_pc ) {
  if (is.na(mean_test_positivity) | is.na(fourteen_day_incidence_pc)) {
    return( NA )
  }
  if (mean_test_positivity > 10 | fourteen_day_incidence_pc > 500) {
    "Juoda D"
  } else if (fourteen_day_incidence_pc > 200) {
    "Raudona C3"
  } else if ( mean_test_positivity > 4) {
    "Raudona C2"
  } else if ( fourteen_day_incidence_pc > 150 ) {
    "Raudona C2"
  } else if ( fourteen_day_incidence_pc > 100 ) {
    "Raudona C1"
  } else if ( fourteen_day_incidence_pc > 50 ) {
    "Geltona B2"
  } else if ( fourteen_day_incidence_pc > 20 ) {
    "Geltona B1"
  } else {
    "Žalia A"
  }
}

colour_codes <- tibble::tribble(
  ~xmax, ~ymax, ~colour,
  12,    600, "gray50",
  10,    500, "firebrick",
  10,    200, "firebrick2",
   4,    150, "firebrick1",
   4,    100, "gold2",
   4,     50, "yellow",
   4,     25, "green2"
)

colour_scale <- c(
"gray50" = "gray50",
"firebrick" = "firebrick",
"firebrick2" = "firebrick2",
"firebrick1" = "firebrick1",
"gold2" = "gold2",
"yellow" = "yellow",
 "green2" = "green2"
)
colour_codes %>%
  ggplot(aes(xmin=0,ymin=0,xmax=xmax,ymax=ymax,fill=colour)) +
  scale_colour_manual(values=colour_scale) +
  geom_rect()

ltu_national_data %>%
      mutate(fourteen_day_incidence_pc=roll_sum(cases_new/population,14)*1e5,
         weekly_mean_positivity=roll_mean(dgn_prc_day,7)) %>%
  select(date, dgn_prc_day, cases_new, fourteen_day_incidence_pc, weekly_mean_positivity, map_colors) %>%
  #arrange(desc(date)) %>%
  filter(date> "2021-02-01") %>%
  ggplot(aes(x=weekly_mean_positivity,y=fourteen_day_incidence_pc)) +
#  enter_appear(early=TRUE) + exit_disappear() +
  geom_rect(aes(xmin=0,ymin=0,xmax=12,ymax=600), fill="gray50") +
  #geom_rect(colour_codes, mapping=aes(xmin=0,ymin=0,xmax=xmax,ymax=ymax)) +
  geom_point() +
  scale_x_continuous(limits=c(0,12)) +
  scale_y_continuous(limits=c(0,600))
#  transition_time(date)

# municipality tracks ----


colour_data <- lt_municipality_data %>%
  group_by(municipality) %>%
  arrange(date) %>%
      mutate(fourteen_day_incidence_pc=roll_sum(cases_new/population,14)*1e5,
         weekly_mean_positivity=roll_mean(dgn_prc_day,7)) %>%
  select(municipality, date, dgn_prc_day, cases_new, fourteen_day_incidence_pc, weekly_mean_positivity, map_colors) %>%
  #arrange(desc(date)) %>%
  filter(date> "2021-02-01" & municipality %in% city_municipalities)

colour_anim <- colour_data %>%
  ggplot(aes(x=weekly_mean_positivity,y=fourteen_day_incidence_pc,
             #colour=municipality,
             group=municipality)) +
  #enter_appear(early=TRUE) + exit_disappear() +
  geom_point() +
  transition_time(date)

#colour_anim_output <-
  animate(plot=colour_anim,
        #height=6, width=6, units="in", res=72,
        width=450, height=450,
        #nframes=day(as.period(max(colour_data$date)-min(colour_data$date),days)),
        #renderer = gifski_renderer(),
        #renderer = av_renderer(codec="libx264"),
        renderer=ffmpeg_renderer(format="mp4"),
        #renderer=file_renderer(),
        #renderer = ffmpeg_renderer(file=paste0("Incidence-animation-", stubStamp(min(recent_incidence_points$date)),         "-to-", stubStamp(max(recent_incidence_points$date)),".mp4"),codec="libx264",options=c("crf"=20, "pix_fmt"="yuv420p")),
        start_pause=5,
        end_pause=5)
#anim_save("CityColours.gif")


#![](CityColours.gif)


# comparison of Vilnius with rest ----

vilnius_only <- lt_municipality_data %>%
  #group_by(municipality) %>%
  filter(municipality=="Vilniaus m. sav.") %>%
  arrange(date) %>%
      mutate(fourteen_day_incidence_pc=roll_sum(cases_new/population,14)*1e5,
         weekly_mean_positivity=roll_mean(dgn_prc_day,7)) %>%
  select(municipality, date, dgn_prc_day, cases_new, fourteen_day_incidence_pc, weekly_mean_positivity, map_colors)
  #arrange(desc(date)) %>%

except_vilnius <- lt_municipality_data %>%
  filter(municipality!="Vilniaus m. sav.") %>%
  group_by(date) %>%
  summarise(cases_new=sum(cases_new), tested_new=sum(tested_new), population=sum(population)) %>%
  mutate(dgn_prc_day = cases_new / tested_new * 100 ) %>%
  arrange(date) %>%
      mutate(fourteen_day_incidence_pc=roll_sum(cases_new/population,14)*1e5,
         weekly_mean_positivity=roll_mean(dgn_prc_day,7)) %>%
  mutate(map_colors = colour_code(weekly_mean_positivity, fourteen_day_incidence_pc)) %>%
  select(date, dgn_prc_day, cases_new, fourteen_day_incidence_pc, weekly_mean_positivity, map_colors)

comparison <- bind_rows(vilnius_only %>% mutate(region="Vilnius m. sav."),
          except_vilnius %>% mutate(region="Rest of Lithuania")) %>%
  select(-municipality) %>%
  filter(date> "2021-01-15")

comparison %>%
  ggplot() +
  #enter_appear(early=TRUE) + exit_disappear() +
#  geom_rect(data=colour_codes, mapping=aes(xmin=0, ymin=0, xmax=xmax, ymax=ymax,
#                                           fill=NA, colour=colour)) +
  geom_line(aes(x=weekly_mean_positivity,y=fourteen_day_incidence_pc,
             colour=region,
             group=region)) +
  #geom_point(data=~filter(.data$region=="Vilniaus m. sav")) %>%
  scale_x_continuous(limits=c(0,12)) +
  scale_y_continuous(limits=c(0,600))
  #transition_time(date)


# animated comparison ----

comparison_anim <- comparison %>%
  ggplot(aes(x=weekly_mean_positivity,y=fourteen_day_incidence_pc,
             #colour=date,
             colour=region,
             group=region)) +
  #enter_appear(early=TRUE) + exit_disappear() +
  geom_point() +
  geom_text(mapping=aes(x=2.5,y=500, label=date),size=6) +
  #geom_point(data=~filter(.data$region=="Vilniaus m. sav")) %>%
   labs( title="Vilnius and the rest of Lithuania have separate pandemics",
        #subtitle=paste0("Confirmed cases between ", min(comparison$date), " and ", max(comparison$date$date)),
        #subtitle="Plot of mean positivity and per capita incidence for Vilnius m. sav. and the rest of Lithuania",
        caption="Richard Martin-Nielsen | Data: OSP",
        x="Weekly mean test positivity", y="Fourteen day incidence per 100 000") +
  #scale_color_distiller(guide=FALSE) +
  scale_x_continuous(limits=c(0,12)) +
  scale_y_continuous(limits=c(0,600)) +
  transition_time(date)

animate(plot=comparison_anim,
        #height=6, width=6, units="in", res=72,
        width=450, height=450,
        nframes=day(as.period(max(comparison$date)-min(comparison$date),days)),
        #renderer = gifski_renderer(),
         renderer = magick_renderer(),
        #renderer = av_renderer(codec="libx264"),
        #renderer=ffmpeg_renderer(format="mp4"),
        #renderer=file_renderer(),
        #renderer = ffmpeg_renderer(file=paste0("Incidence-animation-", stubStamp(min(recent_incidence_points$date)),         "-to-", stubStamp(max(recent_incidence_points$date)),".mp4"),codec="libx264",options=c("crf"=20, "pix_fmt"="yuv420p")),
        start_pause=5,
        end_pause=5)
anim_save("Vilnius_and_elsewhere.gif")

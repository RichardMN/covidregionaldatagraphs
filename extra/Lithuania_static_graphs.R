library(covidregionaldata)
library(ggplot2)
library(ggridges)
library(roll)
library(scales)
library(forcats)
#library(patchwork)
library(dplyr)
library(tidyr)

# Load data ----

lt_county_data <- get_regional_data(country="Lithuania",
                                    totals=FALSE,
                                    level = 1,
                                    localise = TRUE,
                                    all_osp_fields = TRUE)

lt_municipality_data <- get_regional_data(country="Lithuania",
                                          totals=FALSE,
                                          level = 2,
                                          localise = TRUE,
                                          all_osp_fields = TRUE,
                                          national_data = TRUE)

lt_national_data <- lt_municipality_data %>%
  filter(municipality == "Lietuva") %>%
  select(-municipality, -iso_3166_2_municipality, -county, -iso_3166_2)

lt_municipality_data <- lt_municipality_data %>%
  filter(municipality != "Lietuva")

lt_last_date <- format(max(lt_municipality_data$date), "%b %d, %Y")

caption_text <- paste0(
  "Richard Martin-Nielsen | Data: Official Statistics Portal, ",
  lt_last_date
  )

# Make summary table ----

region_summaries <-
  lt_municipality_data %>%
  group_by(municipality) %>%
  summarise(min_i=min(cases_new), max_i=max(cases_new),
            median_i=median(cases_new), mean_i=mean(cases_new)) %>%
  rename(region=municipality)

narrowed_regions <- pull(region_summaries %>%slice_max(max_i, n=10) %>%select(region))

narrowed_regional_incidence <- lt_municipality_data %>%
  #filter(date < as_date("2021-01-04")) %>%
  filter(municipality %in% narrowed_regions)

# Set graphing defaults ----

theme_set(
  theme_minimal()
)

# Plot ridgeline incidence for top 10 municipalities ----

intercity_gap <- 400

ridgeline_labels <- narrowed_regional_incidence %>%
  mutate(y=-as.numeric(factor(municipality))*intercity_gap, region=municipality) %>%
  select(region,y) %>%unique()

narrowed_regional_incidence %>%
  ggplot(aes(x=date,y=-as.numeric(factor(municipality))*intercity_gap,
             height=cases_new, group=municipality)) + #y=as.numeric(municipality)*250
  geom_ridgeline(alpha=0.5,aes(fill=municipality),size=0.25) +
  scale_y_continuous(breaks=ridgeline_labels$y,
                     labels=ridgeline_labels$region,
                     sec.axis =
                       sec_axis(~ . + 10, name="Daily incidence (confirmed cases)",
                                labels=rep(c(intercity_gap/2,"0"),10),
                                breaks=seq(from=-intercity_gap/2,
                                           to=-intercity_gap*10,
                                           by=-intercity_gap/2)),
                     name="Region"
  )+
  scale_x_date(date_breaks = "3 months", date_minor_breaks = "1 month", date_labels = "%b") +
  theme_ridges() +
  theme(legend.position = "none") +
  labs( x= "Date", y="Region / Incidence",
        title="Regional COVID-19 incidence in Lithuania",
        subtitle = "Top ten municipalities by maximum daily incidence",
        caption=caption_text) +
  theme(axis.text.y = element_text(size=8),
        axis.title.y.left = element_blank())

ggsave("extra/Lithuania-ridgeline-top-municipalities.png", width=6, height=4, units="in")

# Plot ridgeline incidence for all 10 counties ----

intercity_gap <- 800

ridgeline_labels <- lt_county_data %>%
  filter(county!="Unknown") %>%
  mutate(y=-as.numeric(factor(county))*intercity_gap, region=county) %>%
  select(region,y) %>%unique()

lt_county_data %>%
  filter(county!="Unknown") %>%
  ggplot(aes(x=date,y=-as.numeric(factor(county))*intercity_gap,
             height=cases_new, group=county)) + #y=as.numeric(municipality)*250
  geom_ridgeline(alpha=0.5,aes(fill=county),size=0.25) +
  scale_y_continuous(breaks=ridgeline_labels$y,
                     labels=ridgeline_labels$region,
                     sec.axis =
                       sec_axis(~ . + 10, name="Daily incidence (confirmed cases)",
                                labels=rep(c(intercity_gap/2,"0"),10),
                                breaks=seq(from=-intercity_gap/2,
                                           to=-intercity_gap*10,
                                           by=-intercity_gap/2)),
                     name="Region"
  )+
  scale_x_date(date_breaks = "3 months", date_minor_breaks = "1 month", date_labels = "%b") +
  theme_ridges() +
  theme(legend.position = "none") +
  labs( x= "Date", y="Region / Incidence",
        title="Regional COVID-19 incidence in Lithuania",
        subtitle = "All counties",
        caption=caption_text) +
  theme(axis.text.y = element_text(size=8),
        axis.title.y.left = element_blank())
ggsave("extra/Lithuania-ridgeline-all-counties.png", width=6, height=4, units="in")

# Waterfall chart case counts ----
lt_counts<- lt_municipality_data %>%
  select(date,cases_new,municipality) %>%
  mutate(weekly_mean_cases=roll_mean(cases_new,7)) %>%
  filter(date>"2020-10-01") %>%
  group_by(date,
           group=fct_rev(cut(weekly_mean_cases,
                             breaks=c(-1,0,5,10,15,20,Inf),
                             labels=c("0", "0-5", "5-10", "10-15", "15-20","20+"),
                             include.lowest=TRUE))) %>%
  summarise(count=n())

lt_counts %>%
  ggplot() +
  geom_col(mapping=aes(x=date,y=count,fill=group),width=1) +
  labs(x="Date",
       y="Number of municipalities",
       fill="Case count",
       title="Municipality case counts in Lithuania",
       subtitle="7 day average counts of new cases",
       caption=caption_text) +
  scale_fill_brewer(palette="Blues",direction=1)

ggsave("extra/Lithuania-waterfall-case-counts.png", width=6, height=4, units="in")

# Waterfall chart municipality test positivity ----
lt_positivity<- lt_municipality_data %>%
  filter(date>"2020-10-01") %>%
  select(date,dgn_prc_day,municipality) %>%
  mutate(weekly_mean_positivity=roll_mean(dgn_prc_day,7)) %>%
  group_by(date,
           group=fct_rev(cut(dgn_prc_day,
                             breaks=c(-1,0,5,10,15,20,Inf),
                             labels=c("0%", "0-5%", "5-10%", "10-15%", "15-20%","20%+"),
                             include.lowest=TRUE))) %>%
  summarise(count=n())

lt_positivity %>%
  ggplot() +
  geom_col(mapping=aes(x=date,y=count,fill=group),width=1) +
  labs(x="Date",
       y="Number of municipalities",
       fill="Test positivity",
       title="Municipality test positivity in Lithuania",
       subtitle="7 day average test positivity",
       caption=caption_text) +
  scale_fill_brewer(palette="Oranges",direction=1)

ggsave("extra/Lithuania-waterfall-positivity.png", width=6, height=4, units="in")

# Compare death definition counts ----

lt_national_data %>%
  ggplot(aes(x=date)) +
  geom_col(aes(y=daily_deaths_def3), color="grey70",width=1) +
  geom_col(aes(y=daily_deaths_def2), color="grey50", width=1) +
  geom_col(aes(y=daily_deaths_def1), color="black",width=1) +
  labs(x="Date", y="Deaths",
       title="Different counts of deaths due to COVID in Lithuania",
       subtitle = "Daily deaths 'by', 'with' or 'after' COVID",
       caption=caption_text)

ggsave("extra/Lithuania-death-counts-comparison.png", width=6, height=4, units="in")

# Acceleration calculations - national ----

lt_national_data %>%
  # put rolling 7 day average in here
  mutate(weekly_mean_cases=roll_mean(cases_new,7),
         weekly_mean_positivity=roll_mean(dgn_prc_day,7)) %>%
  mutate(cases_accel=((weekly_mean_cases-lag(weekly_mean_cases))/abs(lag(weekly_mean_cases))),
         test_accel= ((weekly_mean_positivity-lag(weekly_mean_positivity))/abs(lag(weekly_mean_positivity)))) %>%
  filter(date>"2020-09-01") %>%
  select(date, cases_accel, test_accel) %>%
  pivot_longer(cols = ends_with("_accel"),
               values_to = "accel",
               names_to = "type", names_pattern="(.*)_accel") %>%
  mutate(type=if_else(type=="test", "test positivity", type)) %>%
  ggplot(aes(x=date, y=accel, colour=type)) +
  geom_line() +
  scale_x_date(date_breaks = "2 months", date_minor_breaks = "1 month", date_labels = "%B") +
  #scale_y_continuous(trans = modulus_trans(-0.5), labels=label_percent()) +
  scale_y_continuous( labels=label_percent()) +
  geom_hline(yintercept=0, size=0.2) +
  labs(x="Date", y="Acceleration",
       title="Acceleration of the COVID-19 pandemic in Lithuania",
       subtitle = "% change in 7-day average of incidence or test positivity",
       caption=caption_text)

ggsave("extra/Lithuania-acceleration-national.png", width=6, height=4, units="in")

library(covidregionaldata)
library(ggplot2)
library(ggridges)
library(roll)
library(scales)
library(forcats)
#library(patchwork)
library(dplyr)

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
                                          all_osp_fields = TRUE)

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
  theme_minimal() +
  theme_ridges() +
  theme(legend.position = "none") +
  labs( x= "Date", y="Region / Incidence",
        title="Regional COVID-19 incidence in Lithuania",
        subtitle = "Top ten municipalities by maximum daily incidence",
        caption=caption_text) +
  theme(axis.text.y = element_text(size=8),
        #axis.text.y.left = element_blank(),
        axis.title.y.left = element_blank())

ggsave("extra/Lithuania-ridgeline-top-municipalities.png")

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
  theme_minimal() +
  theme_ridges() +
  theme(legend.position = "none") +
  labs( x= "Date", y="Region / Incidence",
        title="Regional COVID-19 incidence in Lithuania",
        subtitle = "All counties",
        caption=caption_text) +
  theme(axis.text.y = element_text(size=8),
        #axis.text.y.left = element_blank(),
        axis.title.y.left = element_blank())
ggsave("extra/Lithuania-ridgeline-all-counties.png")

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
  theme_minimal() +
  scale_fill_brewer(palette="Blues",direction=1)

ggsave("extra/Lithuania-waterfall-case-counts.png")

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
  theme_minimal() +
  scale_fill_brewer(palette="Oranges",direction=1)

ggsave("extra/Lithuania-waterfall-positivity.png")


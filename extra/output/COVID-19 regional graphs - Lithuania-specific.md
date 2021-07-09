Sub-national COVID graphs for Lithuania
================

# COVID-19 Data Charts for Lithuania

This page presents a set of static charts representing data on the
COVID-19 pandemic in Lithuania. These charts show only past data.

This code uses the
[`covidregionaldata`](http://epiforecasts.io/covidregionaldata) package
to download data for various countries at a subregional level. The
workflow is currently set to install the github version of the package.

This page has some additional graphs specific to Lithuania, in addition
to those available in the other [page of graphs showing COVID-19 data
for Lithuania](COVID-19%20regional%20graphs%20-%20Lithuania.html)

## Overall comparisons of municipalities

Two charts imitating those prepared by the OSP in [their
analyses](https://osp.stat.gov.lt/documents/10180/8420714/1_COVID-19_situacijos_apzvalga_210215.pdf).

``` r
# Waterfall chart case counts ----
lt_counts <- lt_municipality_data %>%
  select(date, cases_new, municipality) %>%
  mutate(weekly_mean_cases = roll_mean(cases_new, 7)) %>%
  filter(date > "2020-10-01") %>%
  group_by(date,
    group = fct_rev(cut(weekly_mean_cases,
      breaks = c(-1, 0, 5, 10, 15, 20, Inf),
      labels = c("0", "0-5", "5-10", "10-15", "15-20", "20+"),
      include.lowest = TRUE
    ))
  ) %>%
  summarise(count = n())
```

    ## `summarise()` has grouped output by 'date'. You can override using the `.groups` argument.

``` r
lt_counts %>%
  ggplot() +
  geom_col(mapping = aes(x = date, y = count, fill = group), width = 1) +
  labs(
    x = "Date",
    y = "Number of municipalities",
    fill = "Case count",
    title = "Municipality case counts in Lithuania",
    subtitle = "7 day average counts of new cases",
    caption = caption_text
  ) +
  scale_fill_brewer(palette = "Blues", direction = 1)
```

![](/covidregionaldatagraphs/images/Lithuania-waterfall-charts-1.png)<!-- -->

``` r
#ggsave("extra/Lithuania-waterfall-case-counts.png", width = 6, height = 4, units = "in")

# Waterfall chart municipality test positivity ----
lt_positivity <- lt_municipality_data %>%
  filter(date > "2020-10-01") %>%
  select(date, dgn_prc_day, municipality) %>%
  mutate(weekly_mean_positivity = roll_mean(dgn_prc_day, 7)) %>%
  group_by(date,
    group = fct_rev(cut(dgn_prc_day,
      breaks = c(-1, 0, 5, 10, 15, 20, Inf),
      labels = c("0%", "0-5%", "5-10%", "10-15%", "15-20%", "20%+"),
      include.lowest = TRUE
    ))
  ) %>%
  summarise(count = n())
```

    ## `summarise()` has grouped output by 'date'. You can override using the `.groups` argument.

``` r
lt_positivity %>%
  ggplot() +
  geom_col(mapping = aes(x = date, y = count, fill = group), width = 1) +
  labs(
    x = "Date",
    y = "Number of municipalities",
    fill = "Test positivity",
    title = "Municipality test positivity in Lithuania",
    subtitle = "7 day average test positivity",
    caption = caption_text
  ) +
  scale_fill_brewer(palette = "Oranges", direction = 1)
```

![](/covidregionaldatagraphs/images/Lithuania-waterfall-charts-2.png)<!-- -->

``` r
#ggsave("extra/Lithuania-waterfall-positivity.png", width = 6, height = 4, units = "in")
```

## Incidence charts

Ridgeline charts showing the incidence in regions of the country. These
emphasise that the first wave was barely a ripple compared with the
second wave, and that the incidence in the larger cities (particularly
Vilnius) has been quite separate from other municipalities.

``` r
# Plot ridgeline incidence for top 10 municipalities ----

intercity_gap <- 400

ridgeline_labels <- narrowed_regional_incidence %>%
  mutate(y = -as.numeric(factor(municipality)) * intercity_gap, region = municipality) %>%
  select(region, y) %>%
  unique()

narrowed_regional_incidence %>%
  ggplot(aes(
    x = date, y = -as.numeric(factor(municipality)) * intercity_gap,
    height = cases_new, group = municipality
  )) + # y=as.numeric(municipality)*250
  geom_ridgeline(alpha = 0.5, aes(fill = municipality), size = 0.25) +
  scale_y_continuous(
    breaks = ridgeline_labels$y,
    labels = ridgeline_labels$region,
    sec.axis =
      sec_axis(~ . + 10,
        name = "Daily incidence (confirmed cases)",
        labels = rep(c(intercity_gap / 2, "0"), 10),
        breaks = seq(
          from = -intercity_gap / 2,
          to = -intercity_gap * 10,
          by = -intercity_gap / 2
        )
      ),
    name = "Region"
  ) +
  scale_x_date(date_breaks = "3 months", date_minor_breaks = "1 month", date_labels = "%b") +
  theme_ridges() +
  theme(legend.position = "none") +
  labs(
    x = "Date", y = "Region / Incidence",
    title = "Regional COVID-19 incidence in Lithuania",
    subtitle = "Top ten municipalities by maximum daily incidence",
    caption = caption_text
  ) +
  theme(
    axis.text.y = element_text(size = 8),
    axis.title.y.left = element_blank()
  )
```

![](/covidregionaldatagraphs/images/Lithuania-incidence-ridgeline-charts-1.png)<!-- -->

``` r
#ggsave("extra/Lithuania-ridgeline-top-municipalities.png", width = 6, height = 4, units = "in")

# Plot ridgeline incidence for all 10 counties ----

intercity_gap <- 800

ridgeline_labels <- lt_county_data %>%
  filter(county != "Unknown") %>%
  mutate(y = -as.numeric(factor(county)) * intercity_gap, region = county) %>%
  select(region, y) %>%
  unique()

lt_county_data %>%
  filter(county != "Unknown") %>%
  ggplot(aes(
    x = date, y = -as.numeric(factor(county)) * intercity_gap,
    height = cases_new, group = county
  )) + # y=as.numeric(municipality)*250
  geom_ridgeline(alpha = 0.5, aes(fill = county), size = 0.25) +
  scale_y_continuous(
    breaks = ridgeline_labels$y,
    labels = ridgeline_labels$region,
    sec.axis =
      sec_axis(~ . + 10,
        name = "Daily incidence (confirmed cases)",
        labels = rep(c(intercity_gap / 2, "0"), 10),
        breaks = seq(
          from = -intercity_gap / 2,
          to = -intercity_gap * 10,
          by = -intercity_gap / 2
        )
      ),
    name = "Region"
  ) +
  scale_x_date(date_breaks = "3 months", date_minor_breaks = "1 month", date_labels = "%b") +
  theme_ridges() +
  theme(legend.position = "none") +
  labs(
    x = "Date", y = "Region / Incidence",
    title = "Regional COVID-19 incidence in Lithuania",
    subtitle = "All counties",
    caption = caption_text
  ) +
  theme(
    axis.text.y = element_text(size = 8),
    axis.title.y.left = element_blank()
  )
```

![](/covidregionaldatagraphs/images/Lithuania-incidence-ridgeline-charts-2.png)<!-- -->

``` r
#ggsave("extra/Lithuania-ridgeline-all-counties.png", width = 6, height = 4, units = "in")
```

The Lithuanian word for “municipality” is *savivaldybė*. “m. sav.” is
short for “city municipality” and “r. sav.” means “regional
municipality”; Vilnius and Kaunas both have suburban municipalities
which are distinguished in these charts only by the “m.” and “r.”

## Acceleration of case incidence and test positivity nationwide

Acceleration is another measure used by OSP. It is intended to give a
more responsive indicator of the development of the pandemic,
particularly in comparison with 7- and 14-day averages. The
time-averaged values are used to smooth out regular weekly variation in
the data but are necessarily lagging indicators, both when incidence is
rising and when it is declining.

``` r
# Acceleration calculations - national ----

lt_national_data %>%
  # put rolling 7 day average in here
  mutate(
    weekly_mean_cases = roll_mean(cases_new, 7),
    weekly_mean_positivity = roll_mean(dgn_prc_day, 7)
  ) %>%
  mutate(
    cases_accel = ((weekly_mean_cases - lag(weekly_mean_cases)) / abs(lag(weekly_mean_cases))),
    test_accel = ((weekly_mean_positivity - lag(weekly_mean_positivity)) / abs(lag(weekly_mean_positivity)))
  ) %>%
  filter(date > "2020-09-01") %>%
  select(date, cases_accel, test_accel) %>%
  pivot_longer(
    cols = ends_with("_accel"),
    values_to = "accel",
    names_to = "type", names_pattern = "(.*)_accel"
  ) %>%
  mutate(type = if_else(type == "test", "test positivity", type)) %>%
  ggplot(aes(x = date, y = accel, colour = type)) +
  geom_line() +
  scale_x_date(date_breaks = "2 months", date_minor_breaks = "1 month", date_labels = "%B") +
  # scale_y_continuous(trans = modulus_trans(-0.5), labels=label_percent()) +
  scale_y_continuous(labels = label_percent()) +
  geom_hline(yintercept = 0, size = 0.2) +
  labs(
    x = "Date", y = "Acceleration",
    title = "Acceleration of the COVID-19 pandemic in Lithuania",
    subtitle = "% change in 7-day average of incidence or test positivity",
    caption = caption_text
  )
```

![](/covidregionaldatagraphs/images/Lithuania-acceleration-national-1.png)<!-- -->

## Attributions of deaths

The OSP provides counts for three different criteria attributing deaths
to COVID, which roughly correspond to “of”, “with” and “after”. This
chart provides a comparison of how the three number of deaths attributed
to COVID according to each criterion compare.

# Compare death definition counts —-

``` r
lt_national_data %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = daily_deaths_def3), color = "grey70", width = 1) +
  geom_col(aes(y = daily_deaths_def2), color = "grey50", width = 1) +
  geom_col(aes(y = daily_deaths_def1), color = "black", width = 1) +
  labs(
    x = "Date", y = "Deaths",
    title = "Different counts of deaths due to COVID in Lithuania",
    subtitle = "Daily deaths 'by', 'with' or 'after' COVID",
    caption = caption_text
  )
```

![](/covidregionaldatagraphs/images/Lithuania-death-definitions-1.png)<!-- -->

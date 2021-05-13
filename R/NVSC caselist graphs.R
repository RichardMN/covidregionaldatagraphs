
library(tidyverse)
library(jsonlite)
library(lubridate)
library(hrbrthemes)
library(skimr)
library(ggridges)
#library(EpiEstim)
library(EpiNow2)
library(future)
library(extrafont)
#library(EpiSoon)

# Downloaded from ftp://atviriduomenys.nvsc.lt/

stubStamp <- stamp_date("20210915")
dashStamp <- stamp_date("2021-09-15")
dateStub <- stubStamp(today())
dashEndDate <- dashStamp(today())
dateEndStub <- stubStamp(today())

OSP_COVID_LT <- jsonlite::fromJSON(paste0("OSP_data/COVID19-",dateEndStub,".json"))

OSP_COVID_data <- OSP_COVID_LT %>%
  transmute(
    `illness_date` = as_datetime(`Susirgimo data`),
    `case_confirmation_date` = as_datetime(`Atvejo patvirtinimo data`),
    imported = recode(`Įvežtinis`, "Taip" = TRUE, "Ne" = FALSE),
    country = `Šalis`,
    outcome = recode_factor(`Išeitis`,
                     "Gydomas" = "treated",
                     "Kita" = "other",
                     "Mirė" = "dead",
                     "Nesirgo" = "well",
                     "Pasveiko" = "healed"),
  foreigner = recode(`Užsienietis`, "Taip" = TRUE, "Ne" = FALSE),
  patient_age = factor(`Atvejo amžius`,
                       levels =c("","0-9", "10-19",  "20-29",  "30-39",  "40-49",  "50-59",
                                 "60-69" , "70-79",  "80-89",  "90-99" , "100-109", "120-129" )
                       ),
  gender = recode_factor(`Lytis`, "Vyras" = "male", "Moteris" = "female", "mot." = "female"),
  region = factor(`Savivaldybė`),
  hospitalised = recode(`Ar hospitalizuotas`, "Taip" = TRUE, "Ne" = FALSE),
  icu_therapy = if_else(`Gydomas intensyvioje terapijoje`=="Taip", TRUE, FALSE),
  chronic_diseases = if_else(`Turi lėtinių ligų`=="Taip", TRUE, FALSE)
  )

rm("OSP_COVID_LT")

# gender age breakdown ----

ggplot(OSP_COVID_data, aes(x=patient_age,fill=outcome)) +
  geom_bar() +
  facet_wrap( ~ gender,ncol=1)

# gender age timeline breakdown ----
ggplot(OSP_COVID_data %>% mutate("week"=isoweek(case_confirmation_date))%>%
         filter(gender%in%c("male","female"),(week>35|week<5),patient_age != "120-129"), aes(x=patient_age,fill=outcome)) +
  geom_bar() +
  theme_minimal()+
  theme(axis.text.x=element_text(angle=90,size=5))+
  labs(x="Patient age cohort", y="Number of cases",
       title="Cases and resolution by age, to 5 January 2021",
       subtitle="Separated by week of confirmation of COVID diagnosis",
       caption="Data from OSP, downloaded 5 January 2021")+
  facet_wrap(  ~week, nrow=1)
# illness incidence ----
illness_incidence <- OSP_COVID_data %>%
  group_by(illness_date) %>%
  summarise(incidence=n()) %>%
  rename (date=illness_date) %>%
  filter(date>="2020-01-01", date<="2020-01-05")

# confirmation incidence ----
confirmation_incidence <- OSP_COVID_data %>%
  group_by(case_confirmation_date) %>%
  summarise(incidence=n()) %>%
  rename (date=case_confirmation_date) %>%
  filter(date>="2020-01-01", date<="2020-01-05")
           # as.Date("2020-01-01", "%y-%m-%d"))
incidence_table <- full_join(illness_incidence, confirmation_incidence, by=c("date"),
                             suffix=c(".illness",".confirmation"))

# incidence_table %>%
#   filter(date>="2020-10-01") %>%
#   ggplot() +
#   geom_col(mapping=aes(x=date,y=incidence.illness,fill="blue"),alpha=0.5) +
#   geom_col(mapping=aes(x=date,y=incidence.confirmation,fill="white"),alpha=0.5) +
#   theme_minimal()
#
# weekday delay analysis ----

weekday_list <- weekdays(as_date("2021-01-04")+0:6)
confirmation_delay_data <- OSP_COVID_data %>%
  mutate(delay=case_confirmation_date-illness_date,
         illness_dotw=factor(weekdays(illness_date),
                             levels=weekday_list, ordered=TRUE),
         confirmation_dotw=factor(weekdays(case_confirmation_date), levels=weekday_list, ordered=TRUE))
confirmation_delay_data %>% select(illness_dotw,confirmation_dotw,delay) %>%
  skim()

format_hm <- function(sec) stringr::str_sub(format(sec), end = -7L)

confirmation_delay_data_means <- confirmation_delay_data %>%
  group_by(illness_dotw) %>%
  summarise(mean_delay = mean(delay)/(24*3600)) %>%
  arrange(illness_dotw)

confirmation_delay_data %>%
  filter(delay< 24*60*60*30)%>%
  ggplot(mapping=aes(x=illness_dotw,y=as.numeric(delay/(24*3600)))) +
  #scale_y_continuous(limits=c(0,2e9)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width=0.25,alpha=0.1,size=0.1) +
#  geom_point(data=confirmation_delay_data_means, mapping=aes(x=illness_dotw,y=mean_delay,colour="red")) +
  scale_y_continuous(limits = c(-5,15)) +
  scale_x_discrete(breaks=weekday_list)

# regional incidence ----
regional_incidence_illness <- OSP_COVID_data %>%
  group_by(region,illness_date) %>%
  summarise(incidence=n()) %>%
  rename(date=illness_date) %>%
  filter(date > "2020-01-01")
regional_incidence_illness %>%
  filter(date < today()) %>%
  #filter(region %in% c("Vilniaus m.", "Kauno m.", "Alytaus m.")) %>%
  ggplot(aes(x=date,y=as.numeric(region)*250,height=incidence, group=region)) +
  geom_ridgeline(alpha=0.5,aes(fill=region)) +
  scale_y_continuous(breaks=unique(as.numeric(regional_incidence_illness$region))*250,
                   labels=levels(regional_incidence_illness$region),
                   sec.axis = dup_axis())+
  theme_minimal() +
  theme_ridges() +
  theme(legend.position = "none") +
  labs( x= "Date", y="Region / Incidence",
        title="Regional incidence in Lithuania", caption="Data: OSP ftp://atviriduomenys.nvsc.lt/") +
  theme(axis.text.y = element_text(size=8),
        axis.text.y.left = element_blank(),
        axis.title.y.left = element_blank())
# ggsave(filename="Regional COVID incidence in Lithuania to January 2021 -illness.pdf",
#        device="pdf",width=29.67, height=21, units="cm")

# regional incidence confirmed ----

regional_incidence_confirmed <- OSP_COVID_data %>%
  group_by(region,case_confirmation_date) %>%
  summarise(incidence=n()) %>%
  rename(date=case_confirmation_date) %>%
  filter(date > "2020-01-01")

region_summaries <-
  regional_incidence_confirmed %>%
  group_by(region) %>%
  summarise(min_i=min(incidence), max_i=max(incidence), median_i=median(incidence),mean_i=mean(incidence))

narrowed_regions <- droplevels(pull(region_summaries %>%slice_max(max_i, n=10) %>%select(region)))

narrowed_regional_incidence <- regional_incidence_confirmed %>%
  #filter(date < as_date("2021-01-04")) %>%
  filter(region %in% narrowed_regions) %>%
  mutate(region = droplevels(region))


# regional ridgeline graphs ----
# Now work for regional versions

narrowed_incidence <- regional_incidence_illness %>%
  filter(region%in%narrowed_regions) %>%
  ungroup() %>%
  rename(confirm=incidence)%>%
  mutate(date=as_date(date),region=droplevels(region)) %>%
  mutate(y=(as.numeric(region)*(-500))) %>%
  mutate(region=levels(region)[as.numeric(region)]) %>%
  select(date,confirm,region,y) %>%
  complete(date=seq.Date(min(as.Date(regional_incidence_illness$date)),
                          Sys.Date(),by="day")
  ) %>%
  filter(!is.na(region), region != "") %>%
  filter(date>= as.Date("2020-07-30", "%Y-%m-%d")) %>%
  tidyr::replace_na(list(date="2020-07-30",confirm=0)) %>%as.data.frame()


  # ggplot(aes(x=date,y=-as.numeric(region)*500,height=confirm, group=region)) +
  # geom_ridgeline(alpha=0.5,aes(fill=region),size=0.25) +
  # scale_y_continuous(breaks=-unique(as.numeric(narrowed_incidence$region))[1:10]*500,
  #                    labels=levels(narrowed_incidence$region),
  #                    sec.axis = sec_axis(~ . + 10, name="Daily incidence (confirmed cases)",
  #                                        labels=rep(c("250","0"),10),
  #                                        breaks=seq(from=-250,to=-5000,by=-250)),
  #                    name="Region"
  #                    )+

theme_update( legend.position = "none",
              axis.text.y = element_text(size=8),
        axis.text.y.left = element_text(face="italic"))
ridgeline_labels <- narrowed_incidence %>%select(region,y) %>%unique()
narrowed_incidence %>%
  #filter(date < as_date("2021-01-04")) %>%
  ggplot(aes(x=date,y=y,height=confirm, group=region)) +
  geom_ridgeline(alpha=0.5,aes(fill=region),size=0.25) +
  scale_y_continuous(breaks=ridgeline_labels$y,
                     labels=ridgeline_labels$region,
                     sec.axis = sec_axis(~ . + 10, name="Daily incidence (confirmed cases)",
                                         labels=rep(c("250","0"),10),
                                         breaks=seq(from=-250,to=-5000,by=-250)),
                     name="Region"
                     )+
  labs( x= "Date", y="Region",
        title="Regional COVID19 incidence in Lithuania", subtitle="Confirmed cases in municipalities with highest daily incidence",
        caption="Each line is offset by 500 cases/day. Data: NVSC ftp://atviriduomenys.nvsc.lt")

# dot graph ----
library(sf)
library(broom)
library(geojsonio)
library(purrr)
#spdf <- geojson_read("http://localhost/~richardmartin/rt_vis/LT-municipalities-OSM.geojson")
municipalities <- st_read("LM-osm.shp") %>%
    dplyr::select(region=name_bat.s) %>%
  mutate(region= gsub(" savivaldybė", "", region)) %>%
  mutate(region= gsub("rajono","r.",region)) %>%
  mutate(region=gsub("miesto","m.",region)) %>%
  mutate(region=recode(region, "Visagino"="Visagino m." ))
#municipalities <- tidy(municipalities, region = "name_lt")
#%>%  mutate(region=factor(name_lt))
regions_labels_incidences <- regional_incidence_confirmed %>%  mutate(region=levels(region)[as.numeric(region)])
geo_incidence <- left_join(municipalities, regions_labels_incidences, by=c("region"))

generate_samples <- function(data) {st_sample(data, size = 60 )}

count_area <- function(data) { st_area(data) }
muni_len <- municipalities %>% mutate(len=length(region))
#points <- map(geo_incidence %>%filter(date == max(date)), generate_samples)
point_baskets <- geo_incidence%>%filter(date==max(date))%>%select("incidence")

#map(st_as_sf(municipalities),count_area)

#pointList <- data.frame()
points <-list()
i=1
for (town in unique(geo_incidence$region)) {
  thisTown <- geo_incidence%>%filter(date==max(date),region==town)
  if(!is.na(thisTown) && length(thisTown) && thisTown$incidence) {
    newPoints <- st_sample(thisTown,thisTown$incidence)
    points[town] <- newPoints
    i <- i+1
  }
}
bind_rows(points)

mapply( generate_samples, municipalities, USE.NAMES = TRUE)
#points <- map(municipalities, generate_samples)

library(dplyr)
library(jsonlite)
library(lubridate)
#library(hrbrthemes)
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


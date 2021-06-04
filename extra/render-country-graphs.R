
library(covidregionaldata)
library(dplyr)
library(purrr)
countries <- get_available_datasets(type = "regional")

render_graphs = function(country) {
  rmarkdown::render(
    "extra/Country-graphs.Rmd",
    output_format = "github_document",
    output_options = list(
      output_format = "github_document",
      self_contained = FALSE
    ),
    params = list(
      country = country,
      prepared_by = "github.com/RichardMN/covidregionaldatagraphs"
    ),
    output_file = paste0("Report ", country, ".md")
  )
}

# countries %<>%
#   filter(!class %in% c("Brazil", "Mexico", "USA") )

start_using_memoise()

purrr::map(countries$origin, render_graphs )


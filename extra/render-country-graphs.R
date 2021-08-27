
library(covidregionaldata)
library(dplyr)
library(purrr)
countries <- get_available_datasets(type = "regional")

render_graphs = function(country) {
    rmarkdown::render(
      "extra/Country-graphs.Rmd",
      output_format = "github_document",
      output_dir = "extra/output",
      output_options = list(
        output_format = "github_document",
        self_contained = FALSE
      ),
      params = list(
        country = country,
        prepared_by = "github.com/RichardMN/covidregionaldatagraphs"
      ),
      output_file = paste0("COVID-19 regional graphs - ", country, ".md")
    )
}

countries <- countries %>%
  filter(!class %in% c("USA", "UK") )

start_using_memoise()

purrr::map(c(countries$origin, "United States", "United Kingdom"), render_graphs )

# Render Lithuania-specific page
rmarkdown::render(
  "extra/Lithuania-graphs.Rmd",
  output_format = "github_document",
  output_dir = "extra/output",
  output_options = list(
    output_format = "github_document",
    self_contained = FALSE
  ),
  params = list(
    prepared_by = "github.com/RichardMN/covidregionaldatagraphs"
  ),
  output_file = paste0("COVID-19 regional graphs - Lithuania-specific.md")
)

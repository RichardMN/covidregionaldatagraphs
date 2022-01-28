
library(covidregionaldata)
library(dplyr)
library(purrr)
countries <- get_available_datasets(type = "regional")

render_graphs = function(country) {
    rmarkdown::render(
      "extra/Country-graphs.Rmd",
      output_format = "github_document",
      output_dir = "docs",
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

# Filter out
# - USA & UK because the naming breaks, we add them in later
# - Netherlands because it's currently (late January 2022) broken
countries <- countries %>%
  filter(!class %in% c("USA", "UK", "Netherlands") )

start_using_memoise()

purrr::map(c(countries$origin, "USA", "United Kingdom"), render_graphs )

# Render Lithuania-specific page
rmarkdown::render(
  "extra/Lithuania-graphs.Rmd",
  output_format = "github_document",
  output_dir = "docs",
  output_options = list(
    output_format = "github_document",
    self_contained = FALSE
  ),
  params = list(
    prepared_by = "github.com/RichardMN/covidregionaldatagraphs"
  ),
  output_file = paste0("COVID-19 regional graphs - Lithuania-specific.md")
)

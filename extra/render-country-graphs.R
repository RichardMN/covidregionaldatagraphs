
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
# - Vietnam because it's currently (early February 2022) broken
countries <- countries %>%
  filter(!class %in% c("USA", "UK", "Vietnam") )

start_using_memoise()

country_errors <- purrr::map(c(countries$origin, "USA", "United Kingdom"),
                             purrr::safely(render_graphs) )

# Be noisy - but don't break - about return values

print("*** Successfully generated:")
print(transpose(keep(country_errors, ~ is_null(.x$error)))[1])

print("*** Errors:")
print(keep(country_errors, ~ !is_null(.x$error)))

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

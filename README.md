# Graphs of COVID-19 regional data

This repo contains graphs showing summary charts of regional COVID-19 data
for countries for which
the [`covidregionaldata`](http://epiforecasts.io/covidregionaldata) package
provides sub-regional data.

This currently includes:

* [France](extra/Report%20France.md)
* [Belgium](extra/Report%20Belgium.md)
* [Brazil](extra/Report%20Brazil.md)
* [Canada](extra/Report%20Canada.md)
* [Colombia](extra/Report%20Colombia.md)
* [Cuba](extra/Report%20Cuba.md)
* [France](extra/Report%20France.md)
* [Germany](extra/Report%20Germany.md)
* [India](extra/Report%20India.md)
* [Italy](extra/Report%20Italy.md)
* [Lithuania](extra/Report%20Lithuania.md)
* [Mexico](extra/Report%20Mexico.md)
* [Netherlands](extra/Report%20Netherlands.md)
* [South](extra/Report%20South.md)
* [Switzerland](extra/Report%20Switzerland.md)

This code uses the
[`covidregionaldata`](http://epiforecasts.io/covidregionaldata) package
to download data for various countries at a subregional level. The workflow
is currently set to install the github version of the package (not the CRAN
version).

In addition to the R code, github actions have been developed to update the
charts daily, though this is not yet functional (and may not be used because
of the limitations of running actions on a a free account).

This package also includes a
[generic version of the graph generation code](extra/Generic_static_graphs.R).
This should generate graphs where possible for any country where 
`covidregionaldata` makes the regional data available.

Finally, for those using who like rmarkdown templated reports, there is a
[parameter-ised Rmarkdown report](extra/Country-graphs.Rmd) which lets
you select the country and enter your name. (Use `knit with parameters`.)

# Graphs of COVID-19 regional data

This repo contains graphs showing summary charts of regional COVID-19 data
for countries for which
the [`covidregionaldata`](http://epiforecasts.io/covidregionaldata) package
provides sub-regional data.

This currently includes:

* [France](extra/Report France.md)
* [Belgium](extra/Report Belgium.md)
* [Brazil](extra/Report Brazil.md)
* [Canada](extra/Report Canada.md)
* [Colombia](extra/Report Colombia.md)
* [Cuba](extra/Report Cuba.md)
* [France](extra/Report France.md)
* [Germany](extra/Report Germany.md)
* [India](extra/Report India.md)
* [Italy](extra/Report Italy.md)
* [Lithuania](extra/Report Lithuania.md)
* [Mexico](extra/Report Mexico.md)
* [Netherlands](extra/Report Netherlands.md)
* [South](extra/Report South.md)
* [Switzerland](extra/Report Switzerland.md)

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

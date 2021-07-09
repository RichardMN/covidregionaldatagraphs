# Graphs of COVID-19 regional data

This repo contains graphs showing summary charts of regional COVID-19 data
for countries for which
the [`covidregionaldata`](http://epiforecasts.io/covidregionaldata) package
provides sub-regional data.

This currently includes:

* [France](extra/output/COVID-19%20regional%20graphs%20-%20France.md)
* [Belgium](extra/output/COVID-19%20regional%20graphs%20-%20Belgium.md)
* [Brazil](extra/output/COVID-19%20regional%20graphs%20-%20Brazil.md)
* [Canada](extra/output/COVID-19%20regional%20graphs%20-%20Canada.md)
* [Colombia](extra/output/COVID-19%20regional%20graphs%20-%20Colombia.md)
* [Cuba](extra/output/COVID-19%20regional%20graphs%20-%20Cuba.md)
* [France](extra/output/COVID-19%20regional%20graphs%20-%20France.md)
* [Germany](extra/output/COVID-19%20regional%20graphs%20-%20Germany.md)
* [India](extra/output/COVID-19%20regional%20graphs%20-%20India.md)
* [Italy](extra/output/COVID-19%20regional%20graphs%20-%20Italy.md)
* [Lithuania](extra/output/COVID-19%20regional%20graphs%20-%20Lithuania.md)
* [Mexico](extra/output/COVID-19%20regional%20graphs%20-%20Mexico.md)
* [Netherlands](extra/output/COVID-19%20regional%20graphs%20-%20Netherlands.md)
* [South Africa](extra/output/COVID-19%20regional%20graphs%20-%20South%20Africa.md)
* [Switzerland](extra/output/COVID-19%20regional%20graphs%20-%20Switzerland.md)
* [United Kingdom](extra/output/COVID-19%20regional%20graphs%20-%20United%20Kingdom.md)
* [United States](extra/output/COVID-19%20regional%20graphs%20-%20United%20States.md)

There is also a specific page for Lithuania:

* [Lithuania (with additional graphs)](extra/output/COVID-19%20regional%20graphs%20-%20Lithuania-specific.md)

This code uses the
[`covidregionaldata`](http://epiforecasts.io/covidregionaldata) package
to download data for various countries at a subregional level. The workflow
is currently set to install the github version of the package (not the CRAN
version).

In addition to the R code, github actions have been developed to update the
charts daily, though this is not yet functional (and may not be used because
of the limitations of running actions on a a free account).

This is done with a
[parameter-ised Rmarkdown report](extra/Country-graphs.Rmd) which lets
you select the country and enter your name. (Use `knit with parameters`.)

# Graphs of COVID-19 regional data

This repo contains graphs showing summary charts of regional COVID-19 data
for countries for which
the [`covidregionaldata`](http://epiforecasts.io/covidregionaldata) package
provides sub-regional data.

This currently includes:

* [France](extra/COVID-19%20regional%20graphs%20-%20France.md)
* [Belgium](extra/COVID-19%20regional%20graphs%20-%20Belgium.md)
* [Brazil](extra/COVID-19%20regional%20graphs%20-%20Brazil.md)
* [Canada](extra/COVID-19%20regional%20graphs%20-%20Canada.md)
* [Colombia](extra/COVID-19%20regional%20graphs%20-%20Colombia.md)
* [Cuba](extra/COVID-19%20regional%20graphs%20-%20Cuba.md)
* [France](extra/COVID-19%20regional%20graphs%20-%20France.md)
* [Germany](extra/COVID-19%20regional%20graphs%20-%20Germany.md)
* [India](extra/COVID-19%20regional%20graphs%20-%20India.md)
* [Italy](extra/COVID-19%20regional%20graphs%20-%20Italy.md)
* [Lithuania](extra/COVID-19%20regional%20graphs%20-%20Lithuania.md)
* [Mexico](extra/COVID-19%20regional%20graphs%20-%20Mexico.md)
* [Netherlands](extra/COVID-19%20regional%20graphs%20-%20Netherlands.md)
* [South Africa](extra/COVID-19%20regional%20graphs%20-%20South%20Africa.md)
* [Switzerland](extra/COVID-19%20regional%20graphs%20-%20Switzerland.md)
* [United Kingdom](extra/COVID-19%20regional%20graphs%20-%20United%20Kingdom.md)
* [United States](extra/COVID-19%20regional%20graphs%20-%20United%20States.md)

There is also a specific page for Lithuania:

* [Lithuania (with additional graphs)](extra/COVID-19%20regional%20graphs%20-%20Lithuania-specific.md)

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

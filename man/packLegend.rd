\name{packLegend}
\alias{packLegend}
\title{
Pack Legends
}
\description{
Pack Legends
}
\usage{
packLegend(..., gap = unit(2, "mm"), direction = c("vertical", "horizontal"),
    max_width = NULL, max_height = NULL, list = NULL)
}
\arguments{

  \item{...}{A list of objects returned by \code{\link{Legend}}.}
  \item{gap}{Gap between two neighbouring legends. The value is a \code{\link[grid]{unit}} object with length of one.}
  \item{direction}{The direction to arrange legends.}
  \item{max_width}{The maximal width of the total packed legends. It only works for horizontal arrangement. If the total width of the legends exceeds it, the legends will be arranged into several rows.}
  \item{max_height}{Similar as \code{max_width}, but for the vertical arrangment of legends.}
  \item{list}{The list of legends can be specified as a list.}

}
\value{
A \code{\link{Legends-class}} object.
}
\examples{
require(circlize)
col_fun = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
lgd1 = Legend(at = 1:6, legend_gp = gpar(fill = 1:6), title = "legend1")
lgd2 = Legend(col_fun = col_fun, title = "legend2", at = c(0, 0.25, 0.5, 0.75, 1))
pd = packLegend(lgd1, lgd2)
draw(pd, test = "two legends")
pd = packLegend(lgd1, lgd2, direction = "horizontal")
draw(pd, test = "two legends packed horizontally")
}

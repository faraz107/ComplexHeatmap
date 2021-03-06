\name{draw_heatmap_body-Heatmap-method}
\alias{draw_heatmap_body,Heatmap-method}
\alias{draw_heatmap_body}
\title{
Draw the heatmap body
}
\description{
Draw the heatmap body
}
\usage{
\S4method{draw_heatmap_body}{Heatmap}(object, kr = 1, kc = 1, ...)
}
\arguments{

  \item{object}{A \code{\link{Heatmap-class}} object.}
  \item{kr}{Row slice index.}
  \item{kc}{Column slice index.}
  \item{...}{Pass to \code{\link[grid]{viewport}} which includes the subset of heatmap body.}

}
\details{
A viewport is created which contains subset rows and columns of the heatmap.

This function is only for internal use.
}
\value{
This function returns no value.
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
# There is no example
NULL

}

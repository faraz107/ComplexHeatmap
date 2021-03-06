\name{draw-Legends-method}
\alias{draw,Legends-method}
\title{
Draw the Legends
}
\description{
Draw the Legends
}
\usage{
\S4method{draw}{Legends}(object, x = unit(0.5, "npc"), y = unit(0.5, "npc"), just = "centre", test = FALSE)
}
\arguments{

  \item{object}{The \code{\link[grid]{grob}} object returned by \code{\link{Legend}} or \code{\link{packLegend}}.}
  \item{x}{The x position of the legends, measured in current viewport.}
  \item{y}{The y position of the legends, measured in current viewport.}
  \item{just}{Justification of the legends.}
  \item{test}{Only used for testing.}

}
\details{
If in the \code{object}, there is already a viewport attached, it will modify the \code{x}, \code{y}
and \code{valid.just} of the viewport. If there is not viewport attached, a viewport
with specified \code{x}, \code{y} and \code{valid.just} is created and attached.

You can also directly use \code{\link[grid]{grid.draw}} to draw the legend object, but you can
only control the position of the legends by first creating a parent viewport and adjusting
the position of the parent viewport.
}
\examples{
lgd = Legend(at = 1:4, title = "foo")
draw(lgd, x = unit(0, "npc"), y = unit(0, "npc"), just = c("left", "bottom"))
}

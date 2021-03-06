\name{max_text_width}
\alias{max_text_width}
\title{
Maximum Width of Text
}
\description{
Maximum Width of Text
}
\usage{
max_text_width(text, gp = gpar())
}
\arguments{

  \item{text}{A vector of text.}
  \item{gp}{Graphic parameters for text.}

}
\details{
Simply calculate maximum width of a list of \code{\link[grid]{textGrob}} objects.

Note it ignores the text rotation.
}
\value{
A \code{\link[grid]{unit}} object which is in "mm".
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\seealso{
\code{\link{max_text_height}} calculates the maximum height of a text vector.
}
\examples{
x = c("a", "bb", "ccc")
max_text_width(x, gp = gpar(fontsize = 10))
}

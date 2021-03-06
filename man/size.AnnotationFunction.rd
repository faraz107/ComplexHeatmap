\name{size.AnnotationFunction}
\alias{size.AnnotationFunction}
\title{
Size of the AnnotationFunction x
}
\description{
Size of the AnnotationFunction x
}
\usage{
\method{size}{AnnotationFunction}(x, ...)
}
\arguments{

  \item{x}{The \code{\link{AnnotationFunction-class}} x.}
  \item{...}{other arguments}

}
\details{
It returns the width if it is a row annotation and the height if it is a column annotation.
}
\examples{
anno = anno_points(1:10)
size(anno)
anno = anno_points(1:10, which = "row")
size(anno)
}

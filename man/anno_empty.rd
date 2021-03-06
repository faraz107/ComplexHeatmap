\name{anno_empty}
\alias{anno_empty}
\title{
Empty Annotation
}
\description{
Empty Annotation
}
\usage{
anno_empty(which = c("column", "row"), border = TRUE, width = NULL, height = NULL)
}
\arguments{

  \item{which}{Whether it is a column annotation or a row annotation?}
  \item{border}{Wether draw borders of the annotation region?}
  \item{width}{Width of the annotation.}
  \item{height}{Height of the annotation.}

}
\details{
It creates an empty annotation and holds space, later users can add graphics
by \code{\link{decorate_annotation}}. This function is useful when users have difficulty to
implement \code{\link{AnnotationFunction}} object.

In following example, an empty annotation is first created and later points are added:

  \preformatted{
	m = matrix(rnorm(100), 10)
	ht = Heatmap(m, top_annotation = HeatmapAnnotation(pt = anno_empty()))
	ht = draw(ht)
	co = column_order(ht)[[1]]
	pt_value = 1:10
	decorate_annotation("pt", \{
		pushViewport(viewport(xscale = c(0.5, ncol(mat)+0.5), yscale = range(pt_value)))
		grid.points(seq_len(ncol(mat)), pt_value[co], pch = 16, default.units = "native")
		grid.yaxis()
		popViewport()
	\})  }

And it is similar as using \code{\link{anno_points}}:

  \preformatted{
	Heatmap(m, top_annotation = HeatmapAnnotation(pt = anno_points(pt_value)))  }
}
\value{
An annotation function which can be used in \code{\link{HeatmapAnnotation}}.
}
\examples{
anno = anno_empty()
draw(anno, test = "anno_empty")
anno = anno_empty(border = FALSE)
draw(anno, test = "anno_empty without border")
}


# == title
# AnnotationFunction class
#
# == details
# THe AnnotationFunction class is a wrapper of user-defined annotation functions.
# See `AnnotationFunction` constructor for details
#
AnnotationFunction = setClass("AnnotationFunction",
	slots = list(
		which = "character",
		fun_name = "character",
		width = "ANY",
		height = "ANY",
		n = "numeric",
		var_env = "environment",
		fun = "function",
		subset_rule = "list",
		subsetable = "logical",
		data_scale = "numeric",
		extended = "ANY"
	),
	prototype = list(
		fun_name = "",
		width = unit(1, "npc"),
		height = unit(1, "npc"),
		subset_rule = list(),
		subsetable = FALSE,
		data_scale = c(0, 1),
		n = 0,
		extended = unit(c(0, 0, 0, 0), "mm")
	)
)


anno_width_and_height = function(which, width = NULL, height = NULL, 
	default = unit(10, "mm")) {

	if(which == "column") {
		if(is.null(height)) {
			height = default
		} else {
			if(!is_abs_unit(height)) {
				stop("height can only be an absolute unit.")
			} else {
				height = convertHeight(height, "mm")
			}
		}
		if(is.null(width)) {
			width = unit(1, "npc")
		}
	}
	if(which == "row") {
		if(is.null(width)) {
			width = default
		} else {
			if(!is_abs_unit(width)) {
				stop("width can only be an absolute unit.")
			} else {
				width = convertWidth(width, "mm")
			}
		}
		if(is.null(height)) {
			height = unit(1, "npc")
		}
	}
	return(list(height = height, width = width))
}


# == title
# Constructor of AnnotationFunction class
#
# == param
# -fun A function which defines how to draw annotation. See **Details** section.
# -fun_name The name of the function. It is only used for `show,AnnotationFunction-method`.
# -which Whether it is drawn as a column annotation or a row annotation?
# -var_imported The name of the object or the objects themselves that the annotation function depends on. See **Details** section.
# -n Number of observations in the annotation. It is not mandatory, but it is better to provide this information.
# -data_scale The data scale on the data axis (y-axis for column annotation and x-axis for row annotation). It is only used
#             when `decoration_annotation` is used with "native" unit coordinates.
# -subset_rule The rule of subsetting variables in ``var_import``. It should be set when users want the final object to
#              be subsetable. See **Details** section.
# -subsetable Whether the object is subsetable?
# -width The width of the plotting region (the viewport) that the annotation is drawn. If it is a row annotation,
#        the width must be an absolute unit.
# -height The height of the plotting region (the viewport) that the annotation is drawn. If it is a column annotation,
#        the width must be an absolute unit.
#
# == details
# The AnnotationFunction class is a wrapper of the function which draws heatmap annotation.
AnnotationFunction = function(fun, fun_name = "", which = c("column", "row"), 
	var_imported = list(), n = 0, data_scale = c(0, 1), subset_rule = list(), 
	subsetable = FALSE, width = NULL, height = NULL) {

	which = match.arg(which)[1]

	verbose = ht_global_opt$verbose
	
	anno = new("AnnotationFunction")

	anno@which = which
	anno@fun_name = fun_name

	if(verbose) qqcat("construct AnnotationFunction with '@{fun_name}()'\n")

	anno_size = anno_width_and_height(which, width, height, unit(1, "cm"))
	anno@width = anno_size$width
	anno@height = anno_size$height

	anno@n = n
	anno@data_scale = data_scale

	anno@var_env = new.env()
	if(is.character(var_imported)) {
		for(nm in var_imported) {
			anno@var_env[[nm]] = get(nm, envir = parent.frame())
		}
	} else if(inherits(var_imported, "list")) {
		if(is.null(names(var_imported))) {
			var_imported_nm = sapply(as.list(substitute(var_imported))[-1], as.character)
			names(var_imported) = var_imported_nm
		}

		for(nm in names(var_imported)) {
			anno@var_env[[nm]] = var_imported[[nm]]
		}
	} else {
		stop_wrap("`var_import` needs to be a character vector which contains variable names or a list of variables")
	}
	
	environment(fun) = anno@var_env
	anno@fun = fun
	
	if(is.null(subset_rule)) {
		for(nm in names(anno@var_env)) {
			if(is.matrix(anno@var_env[[nm]])) {
				anno@subset_rule[[nm]] = subset_matrix_by_row
			} else if(inherits(anno@var_env[[nm]], "gpar")) {
				anno@subset_rule[[nm]] = subset_gp
			} else if(is.vector(anno@var_env[[nm]])) {
				if(length(anno@var_env[[nm]]) > 1) {
					anno@subset_rule[[nm]] = subset_vector
				}
			}
		}
	} else {
		for(nm in names(subset_rule)) {
			anno@subset_rule[[nm]] = subset_rule[[nm]]
		}
	}

	if(missing(subsetable)) {
		# is user defined subset rule
		if(length(anno@subset_rule)) {
			anno@subsetable = TRUE
		}
	} else {
		anno@subsetable = subsetable
	}

	return(anno)
}

# == title
# Subset an AnnotationFunction Object
#
# == param
# -x An `AnnotationFunction-class` object.
# -i Index
#
# == details
# One good thing for designing the `AnnotationFunction-class` can be subsetted.
#
# == example
# anno = anno_simple(1:10)
# anno[1:5]
# draw(anno[1:5], test = "subset of column annotation")
"[.AnnotationFunction" = function(x, i) {
	if(nargs() == 1) {
		return(x)
	} else {
		if(!x@subsetable) {
			stop("This object is not subsetable.")
		}
		x = copy_all(x)
		for(var in names(x@subset_rule)) {
			oe = try(x@var_env[[var]] <- x@subset_rule[[var]](x@var_env[[var]], i), silent = TRUE)
			if(inherits(oe, "try-error")) {
				message(paste0("An error when subsetting ", var))
				stop(oe)
			}
		}
		if(is.logical(i)) {
			x@n = sum(i)
		} else {
			x@n = length(i)
		}
		return(x)
	}
}

# == title
# Draw the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
# -index Index of observations.
# -test Is it in test mode? The value can be logical or a text which is plotted as the title of plot.
#
# == detail
# Normally it is called internally by the `SingleAnnotation` class.
#
# When ``test`` is set to ``TRUE``, the annotation graphic is directly drawn,
# which is generally for testing purpose.
# 
setMethod(f = "draw",
	signature = "AnnotationFunction",
	definition = function(object, index, test = FALSE) {
		
	if(is.character(test)) {
		test2 = TRUE
	} else {
		test2 = test
	}
	if(test2) {
        grid.newpage()
        pushViewport(viewport(width = 0.8, height = 0.8))
    }

    verbose = ht_global_opt$verbose
    if(verbose) qqcat("draw annotation generated by @{object@fun_name}\n")

    if(missing(index)) index = seq_len(object@n)

    anno_height = object@height
    anno_width = object@width

    # names should be passed to the data viewport
	pushViewport(viewport(width = anno_width, height = anno_height))
	object@fun(index)
	if(test2) {
		grid.text(test, y = unit(1, "npc") + unit(2, "mm"), just = "bottom")

		if(!identical(unit(0, "mm"), object@extended[1])) {
			grid.rect(y = 1, height = unit(1, "npc") + object@extended[1], just = "top",
				gp = gpar(fill = "transparent", col = "red", lty = 2))
		} else if(!identical(unit(0, "mm"), object@extended[[2]])) {
			grid.rect(x = 1, width = unit(1, "npc") + object@extended[2], just = "right",
				gp = gpar(fill = "transparent", col = "red", lty = 2))
		} else if(!identical(unit(0, "mm"), object@extended[[3]])) {
			grid.rect(y = 0, height = unit(1, "npc") + object@extended[3], just = "bottom",
				gp = gpar(fill = "transparent", col = "red", lty = 2))
		} else if(!identical(unit(0, "mm"), object@extended[[4]])) {
			grid.rect(x = 0, width = unit(1, "npc") + object@extended[4], just = "left",
				gp = gpar(fill = "transparent", col = "red", lty = 2))
		}
		
	}
	popViewport()

	if(test2) {
		popViewport()
	}
	
})

# == title
# Copy the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
#
# == detail
# In `AnnotationFunction-class`, there is an environment which stores some external variables
# for the annotation function. This `copy_all,AnnotationFunction-method` hard copy all the variables
# in that environment to a new environment.
setMethod(f = "copy_all",
	signature = "AnnotationFunction",
	definition = function(object) {
		object2 = object
		object2@var_env = new.env()
		for(var in names(object@var_env)) {
			object2@var_env[[var]] = object@var_env[[var]]
		}
		environment(object2@fun) = object2@var_env
		return(object2)
})

# == title
# Print the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
#
setMethod(f = "show",
	signature = "AnnotationFunction",
	definition = function(object) {

	cat("An AnnotationFunction object\n")
	if(object@fun_name == "") {
		cat("  function: user-defined\n")
	} else {
		cat("  function: ", object@fun_name, "()\n", sep = "")
	}
	cat("  position:", object@which, "\n")
	cat("  items:", ifelse(object@n == 0, "unknown", object@n), "\n")
	cat("  width:", as.character(object@width), "\n")
	cat("  height:", as.character(object@height), "\n")
	var_imported = names(object@var_env)
	if(length(var_imported)) {
		cat("  imported variable:", paste(var_imported, collapse = ", "), "\n")
		var_subsetable = names(object@subset_rule)
		if(length(var_subsetable)) {
			cat("  subsetable variable:", paste(var_subsetable, collapse = ", "), "\n")
		}
	}
	cat("  this object is", ifelse(object@subsetable, "\b", "not"), "subsetable\n")
	dirt = c("bottom", "left", "top", "right")
	for(i in 1:4) {
		if(!identical(unit(0, "mm"), object@extended[i])) {
			cat(" ", as.character(object@extended[i]), "extension on the", dirt[i], "\n")
		}
	}
	
})

# == title
# Width of the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
#
setMethod(f = "width",
	signature = "AnnotationFunction",
	definition = function(object) {
	object@width
})

# == title
# Assign the Width of the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
# -value A `grid::unit` object.
# -... Other arguments
#
setReplaceMethod(f = "width",
	signature = "AnnotationFunction",
	definition = function(object, value, ...) {
	object@width = value
	object
})

# == title
# Height of the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
#
setMethod(f = "height",
	signature = "AnnotationFunction",
	definition = function(object) {
	object@height
})

# == title
# Assign the Height of the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
# -value A `grid::unit` object.
# -... Other arguments
#
setReplaceMethod(f = "height",
	signature = "AnnotationFunction",
	definition = function(object, value, ...) {
	object@height = value
	object
})

# == title
# Size of the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
#
# == detail
# It returns the width if it is a row annotation and the height if it is a column annotation.
#
setMethod(f = "size",
	signature = "AnnotationFunction",
	definition = function(object) {
	if(object@which == "row") {
		object@width
	} else {
		object@height
	}
})

# == title
# Assign the Size of the AnnotationFunction object
#
# == param
# -object The `AnnotationFunction-class` object.
# -value A `grid::unit` object.
# -... Other arguments
#
# == detail
# It assigns the width if it is a row annotation and the height if it is a column annotation.
#
setReplaceMethod(f = "size",
	signature = "AnnotationFunction",
	definition = function(object, value, ...) {
	if(object@which == "row") {
		object@width = value
	} else {
		object@height = value
	}
	object
})

# == title
# Number of Observations
#
# == param
# -x The `AnnotationFunction-class` object.
#
# == details
# It returns the ``n`` slot in the object.
nobs.AnnotationFunction = function(x) {
	if(x@n > 0) {
		x@n
	} else {
		NA
	}
}
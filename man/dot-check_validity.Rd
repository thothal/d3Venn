% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{.check_validity}
\alias{.check_validity}
\title{Checks validity of the argument passed to d3Venn}
\usage{
.check_validity(sets)
}
\arguments{
\item{sets}{object, will be checked if it fits the requirments of d3Venn}
}
\value{
A list with the follwing elements:
\itemize{
\item result boolean, \code{TRUE} if the object is a valid object, \code{FALSE}
otherwise.
\item msg character, the error / warning message to be returned.
\item severity character, either \dQuote{warning} or \dQuote{error}. Indicates if the
problem found should raise an \link[base:stop]{error} or a
\link[base:warning]{warning}
\code{severity} will be called with the given \code{msg} from the calling
function.
\item fixed data.frame, in case the problem can be fixed by removing elements from
\code{sets}, \code{fixed} will contain this fixed version.
}
}
\description{
The sanity checks for d3Venn are outsourced to this function for cleaner code.
}
\section{Note}{

Not all logical errors will be covered here for simplicity. For instance missing lower
order intersections and or size restrictions on lower order intersections are not
checked. Rational behind this is that we want to make sure that there is at least a
plot, even if it is not as intended. We add some more tests than strictly necessary
for this goal becasue they were rather easy to implement.
The rest is left to the user to investigate further. A close look into the JS console
reveals if there were erros during the rendering.

The following issues are checked:
\itemize{
\item{Wrong input}{sets is not a \code{data.frame} or misses some columns}
\item{Unknown fields}{fields not known to Venn.js are supplied}
\item{Duplicated entries}{rows are repeated}
\item{Duplicate elements in intersections}{elements are repeated}
\item{Missing main sets}{intersections contain entries for sets which are not
specified}
\item{Cardinality is too big}{intersection size exceeds main set size}
}
}


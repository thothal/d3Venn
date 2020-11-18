#' Create a d3 Venn diagram
#'
#' Draw a Venn diagram given a data frame with the sizes and names of the sets.
#'
#' To pass the size (and or label) of the intersections, the corresponding `sets` element
#' must contain a list. To create `list` columns you can use [base:I()]. See Examples.
#'
#' @param sets data.frame, each row correspond to one part in the Venn diagram. Must
#'        contain columns `sets` and `size` and may contain a column `label`.
#'        Intersections are represented by a list of set names.
#' @param width integer, width of the htmlwidget.
#' @param height integer, height of the htmlwidget.
#'
#' @section JavaScript Libraries:
#' * <https://github.com/benfred/venn.js/>
#' * <https://d3js.org/>
#'
#' @return an `htmlwidget`
#' @seealso [htmlwidgets::createWidget]
#' @export
#'
#' @examples
#' # Venn diagram with 2 disjoint sets both of equal size
#' d3Venn(data.frame(sets = c("A", "B"), size = c(20, 20)))
#'
#' # Venn diagram with 2 disjoint sets with differnt sizes and labels
#' d3Venn(data.frame(sets = c("A", "B"), size = c(10, 20), label = c("Set 1", "Set 2")))
#'
#' # Venn diagram with 2 overlapping sets
#' d3Venn(data.frame(sets = I(list("A", "B", list("A", "B")))
#'                   size = c(10, 10, 2)))
#'
#' # Venn diagram where B is a subset of A
#' d3Venn(data.frame(sets = I(list("A", "B", list("A", "B")))
#'                   size = c(20, 10, 10)))

d3Venn <- function(sets,
                   width = NULL, height = NULL) {
   ## in this first version we expect an input to be a data.frame with
   ## column `sets` and `size`and optional `label`
   ## `sets` will most likely include list columns with list elements, so use
   ## data.frame(sets = I(list(1, 2, list(1, 2))))

   data <- do.call(function(...) Map(list,...), sets)

}

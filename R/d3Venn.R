#' Create a d3 Venn diagram
#'
#' Draw a Venn diagram given a data frame with the sizes and names of the sets.
#'
#' To pass the size (and or label) of the intersections, the corresponding `sets` element
#' must contain a list. To create `list` columns you can use [base::I()]. See Examples.
#'
#' @param sets data.frame, each row correspond to one part in the Venn diagram. Must
#'        contain columns `sets` and `size` and may contain a column `label`.
#'        Intersections are represented by a list of set names.
#' @param width integer, width of the htmlwidget.
#' @param height integer, height of the htmlwidget.
#'
#' @section JavaScript Libraries:
#' * <https://github.com/upsetjs/venn.js>
#' * <https://d3js.org/>
#'
#' @return an `htmlwidget`
#' @seealso [htmlwidgets::createWidget()]
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
#' d3Venn(data.frame(sets = I(list("A", "B", list("A", "B"))),
#'                   size = c(10, 10, 2)))
#'
#' # Venn diagram where B is a subset of A
#' d3Venn(data.frame(sets = I(list("A", "B", list("A", "B"))),
#'                   size = c(20, 10, 10)))

d3Venn <- function(sets,
                   width = NULL, height = NULL) {
   ## in this first version we expect an input to be a data.frame with
   ## column `sets` and `size` and optional `label`
   ## `sets` will most likely include list columns with list elements, so use
   ## data.frame(sets = I(list(1, 2, list(1, 2))))

   required_names <- c("sets", "size")
   optional_names <- c("label")

   if (!is.data.frame(sets)) {
      msg <- gettextf(paste(sQuote("sets"), "must be a data.frame"))
      stop(msg, domain = NULL)
   }

   NOK <- !required_names %in% names(sets)
   if (any(NOK)) {
      msg <- sprintf(ngettext(sum(NOK),
                              "required field %s could not be found",
                              "required fields %s could not be found"),
                     paste(sQuote(required_names[NOK]),
                           collapse = ", "))
      stop(msg, domain = NULL)
   }

   NOK <- !names(sets) %in% c(required_names, optional_names)
   if (any(NOK)) {
      msg <- sprintf(ngettext(sum(NOK),
                              "unknown field %s - will be dropped",
                              "unknown fields %s - will be dropped"),
                     paste(sQuote(names(sets)[NOK]),
                           collapse = ", "))
      warning(msg, domain = NULL)
      sets <- sets[, names(sets)[!NOK]]
   }

   sets <- do.call(function(...) Map(function(...) {
      res <- list(...)
      res$sets <- as.list(res$sets)
      res
   }, ...), sets)
   htmlwidgets::createWidget(
      name = "d3Venn",
      list(data = sets),
      width  = width,
      height = height
   )
}


#' Shiny bindings for d3Venn
#'
#' Output and render functions for using d3Venn within Shiny applications and interactive
#' RMD documents
#'
#' @param outputId string, output variable to read the d3Venn diagram from
#' @param width,height Must be a valid CSS unit (like \code{\dQuote{100\%}},
#'        \code{\dQuote{400px}}, \code{\dQuote{auto}}) or a number, which will be coerced to a
#'         string and have \code{\dQuote{px}} appended.
#' @param expr expression, which creates the d3Venn object.
#' @param env environment in which to evaluate \code{expr}.
#' @param quoted boolean, is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @return
#' @export
#'
#' @examples
#' if (requireNamespace("shiny", quietly = TRUE) && interactive()) {
#'    library(shiny)
#'
#'    options(device.ask.default = FALSE)
#'
#'    ui <- fluidPage(
#'       titlePanel("Venn Diagram"),
#'       sidebarLayout(
#'          sidebarPanel(
#'             sliderInput("a", "Set A:", 10, 100, 10, 10),
#'             sliderInput("b", "Set B:", 10, 100, 10, 10),
#'             sliderInput("ovl", "Overlap:", 0, 100, 10, 10, post = "%")
#'          ),
#'          mainPanel(
#'             d3VennOutput("venn")
#'          )
#'       )
#'    )
#'
#'    server <- function(input, output) {
#'       output$venn <- renderD3Venn({
#'          n_A <- req(input$a)
#'          n_B <- req(input$b)
#'          n_AB <- round(req(input$ovl) / 100 * min(n_A, n_B))
#'          if (n_AB > 0) {
#'             dat <- data.frame(sets = I(list("A", "B", list("A", "B"))),
#'                               size = c(n_A, n_B, n_AB))
#'          } else {
#'             dat <- data.frame(sets = c("A", "B"),
#'                               size = c(n_A, n_B))
#'          }
#'          d3Venn(dat)
#'       })
#'    }
#'
#'    shinyApp(ui, server)
#' }
d3VennOutput <- function(outputId, width = "100%", height = "400px") {
   htmlwidgets::shinyWidgetOutput(outputId, "d3Venn", width, height, package = "d3Venn")
}

#' @rdname d3VennOutput
#' @export
renderD3Venn <- function(expr, env = parent.frame(), quoted = FALSE) {
   if (!quoted) {
      expr <- substitute(expr)
   } # force quoted
   htmlwidgets::shinyRenderWidget(expr, d3VennOutput, env, quoted = TRUE)
}

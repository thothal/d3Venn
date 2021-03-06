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
#' @param fill_colors,text_color character, vector of colors for filling the circles and
#'                               the text respectively. Must be interpretable by css (see
#'                               [htmltools::parseCssColors()] for allowed formats).
#' @param center_text boolean, should the circles' texts be centered horizontally and
#'                    vertically?
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
#'
#' # Venn diagram with differnt colors and centered text
#' d3Venn(data.frame(sets = I(list("A", "B", list("A", "B"))),
#'                   size = c(20, 20, 10)),
#'        c("cornflowerblue", "hsl(300, 100%, 70%)"),
#'        "#FFA500",
#'        TRUE)

d3Venn <- function(sets,
                   fill_colors = NULL,
                   text_color  = NULL,
                   center_text = FALSE,
                   width = NULL, height = NULL) {
   ## in this first version we expect an input to be a data.frame with
   ## column `sets` and `size` and optional `label`
   ## `sets` will most likely include list columns with list elements, so use
   ## data.frame(sets = I(list(1, 2, list(1, 2))))

   ## sort all interactions to make sure we detect duplicates

   sanity_check <- .check_validity(sets)

   ## sanity check
   if (!sanity_check$result) {
      if (sanity_check$severity == "error") {
         stop(sanity_check$msg, domain = NULL)
      } else if (sanity_check$severity == "warning") {
         ## use loop in case there are more warnings
         for(msg in sanity_check$msg) {
            warning(msg, domain = NULL)
         }
      }
   }

   ## set sets to canonical version
   sets <- sanity_check$fixed

   sets <- do.call(function(...) Map(function(...) {
      res <- list(...)
      res$sets <- as.list(res$sets)
      res
   }, ...), sets)
   opts <- list(symmetricalTextCentre = center_text)
   if (!is.null(fill_colors)) {
      opts$colourScheme <- htmltools::parseCssColors(fill_colors)
   }
   if (!is.null(text_color)) {
      opts$textFill <- htmltools::parseCssColors(text_color)
   }
   htmlwidgets::createWidget(
      name = "d3Venn",
      list(data = sets,
           opts = opts),
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
#' @param width,height Must be a valid CSS unit (like \dQuote{\code{100\%}},
#'        \dQuote{\code{400px}}, \dQuote{\code{auto}}) or a number, which will be coerced to a
#'         string and have \dQuote{\code{px}} appended.
#' @param expr expression, which creates the d3Venn object.
#' @param env environment in which to evaluate \code{expr}.
#' @param quoted boolean, is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @return An output element for use in UI.
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

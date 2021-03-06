#' Checks validity of the argument passed to d3Venn
#'
#' The sanity checks for d3Venn are outsourced to this function for cleaner code.
#'
#' @section Note:
#' Not all logical errors will be covered here for simplicity. For instance missing lower
#' order intersections and or size restrictions on lower order intersections are not
#' checked. Rational behind this is that we want to make sure that there is at least a
#' plot, even if it is not as intended. We add some more tests than strictly necessary
#' for this goal becasue they were rather easy to implement.
#' The rest is left to the user to investigate further. A close look into the JS console
#' reveals if there were erros during the rendering.
#'
#' The following issues are checked:
#' \itemize{
#' \item{Wrong input}{sets is not a \code{data.frame} or misses some columns}
#' \item{Unknown fields}{fields not known to Venn.js are supplied}
#' \item{Duplicated entries}{rows are repeated}
#' \item{Duplicate elements in intersections}{elements are repeated}
#' \item{Missing main sets}{intersections contain entries for sets which are not
#' specified}
#' \item{Cardinality is too big}{intersection size exceeds main set size}
#' }
#' @param sets object, will be checked if it fits the requirments of d3Venn
#'
#' @return A list with the follwing elements:
#' \itemize{
#' \item result boolean, \code{TRUE} if the object is a valid object, \code{FALSE}
#'       otherwise.
#' \item msg character, the error / warning message to be returned.
#' \item severity character, either \dQuote{warning} or \dQuote{error}. Indicates if the
#'                problem found should raise an [error][base::stop()] or a
#'                [warning][base::warning()]
#'       \code{severity} will be called with the given \code{msg} from the calling
#'       function.
#' \item fixed data.frame, in case the problem can be fixed by removing elements from
#'       \code{sets}, \code{fixed} will contain this fixed version.
#' }

.check_validity <- function(sets) {
   required_names <- c("sets", "size")
   optional_names <- c("label")

   ret <- list(result   = TRUE,
               msg      = NULL,
               severity = NULL,
               fixed    = sets)
   ## check that sets is a data.frame
   if (!is.data.frame(sets)) {
      ret$result <- FALSE
      ret$msg <- gettextf(paste(sQuote("sets"), "must be a data.frame"))
      ret$severity <- "error"
      return(ret)
   }

   ## check that all required fields are present
   NOK <- !required_names %in% names(sets)
   if (any(NOK)) {
      ret$result <- FALSE
      ret$msg <- sprintf(ngettext(sum(NOK),
                                  "required field %s could not be found",
                                  "required fields %s could not be found"),
                         paste(sQuote(required_names[NOK]),
                               collapse = ", "))
      ret$severity <- "error"
      return(ret)
   }

   ## check that there are no unknown fields
   NOK <- !names(sets) %in% c(required_names, optional_names)
   if (any(NOK)) {
      ret$result <- FALSE
      ret$msg <- sprintf(ngettext(sum(NOK),
                                  "unknown field %s - will be dropped",
                                  "unknown fields %s - will be dropped"),
                         paste(sQuote(names(sets)[NOK]),
                               collapse = ", "))
      ret$severity <- "warning"
      sets <- sets[, names(sets)[!NOK]]
   }

   ## sort all sets such that later we can check duplicates easily
   sets$sets <- lapply(sets$sets, function(set) {
      if (is.list(set)) {
         as.list(sort(unlist(set)))
      } else {
         sort(set)
      }
   })

   ## check that intersections are unique
   NOK <- vapply(sets$sets, function(set) length(set) != length(unique(set)), logical(1L))
   if (any(NOK)) {
      ret$result <- FALSE
      msg <- sprintf(ngettext(sum(NOK),
                              "set %s contains duplicated entries - will be reduced",
                              "sets %s contain duplicated entries - will be reduced"),
                     paste(
                        sQuote(
                           vapply(sets$sets[NOK],
                                  function(.) paste0("(",
                                                     paste(., collapse = ", "),
                                                     ")"),
                                  character(1L))),
                        collapse = ", "))
      ret$msg <- c(ret$msg, msg)
      ret$severity <- "warning"
      sets$sets[NOK] <- lapply(sets$sets[NOK], unique)
   }

   ## check that all intersection sets are based on main sets
   card <- vapply(sets$sets, length, integer(1L))
   main_sets <- unlist(sets$sets[card == 1L])
   NOK <- vapply(sets$sets, function(set) !all(unlist(set) %in% main_sets), logical(1L))
   if (any(NOK)) {
      ret$result <- FALSE
      msg <- sprintf(
         ngettext(sum(NOK),
                  "element(s) in set %s do not appear as main sets - will be reduced",
                  "element(s) in sets %s do not appear as main sets - will be reduced"),
         paste(
            sQuote(
               vapply(sets$sets[NOK],
                      function(.) paste0("(",
                                         paste(., collapse = ", "),
                                         ")"),
                      character(1L))),
            collapse = ", "))
      ret$msg <- c(ret$msg, msg)
      ret$severity <- "warning"
      sets$sets[NOK] <- lapply(sets$sets[NOK], function(set) {
         if (is.list(set)) {
            as.list(intersect(set, main_sets))
         } else {
            intersect(set, main_sets)
         }
      })
      sets <- sets[vapply(sets$sets, function(set) !is.null(set) & length(set) != 0,
                          logical(1L)), ]
   }

   ## check that there are no duplicated sets
   NOK <- duplicated(lapply(sets$sets, unlist))
   if (any(NOK)) {
      ret$result <- FALSE
      msg <- sprintf(ngettext(sum(NOK),
                              "set %s is not unique - will be dropped",
                              "sets %s are not unique - will be dropped"),
                     paste(
                        sQuote(
                           vapply(sets$sets[NOK],
                                  function(.) paste0("(",
                                                     paste(., collapse = ", "),
                                                     ")"),
                                  character(1L))),
                        collapse = ", "))
      ret$msg <- c(ret$msg, msg)
      ret$severity <- "warning"
      sets <- sets[!NOK, ]
   }

   ## check that intersection set sizes are not bigger than main set sizes
   main_sets_sizes <- stats::setNames(sets$size[card == 1L],
                                      main_sets)
   set_size_limit <- vapply(sets$sets, function(set)
      min(main_sets_sizes[unlist(set)]), numeric(1L))
   NOK <- sets$size > set_size_limit
   if (any(NOK)) {
      ret$result <- FALSE
      msg <- sprintf(ngettext(sum(NOK),
                              "cardinality of set %s is too big - will be reduced",
                              "cardinality of sets %s is too big - will be reduced"),
                     paste(
                        sQuote(
                           vapply(sets$sets[NOK],
                                  function(.) paste0("(",
                                                     paste(., collapse = ", "),
                                                     ")"),
                                  character(1L))),
                        collapse = ", "))
      ret$msg <- c(ret$msg, msg)
      ret$severity <- "warning"
      sets$size[NOK] <- set_size_limit[NOK]
   }

   ret$fixed <- sets
   ret
}

#' Checks validity of the argument passed to d3Venn
#'
#' The sanity checks for d3Venn are outsourced to this function for cleaner code.
#'
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
   sets$sets <- lapply(sets$sets, function(elem) {
      if (is.list(elem)) {
         as.list(sort(unlist(elem)))
      } else {
         sort(elem)
      }
   })

   ## check that intersections are unique

   NOK <- sapply(sets$sets, function(set) length(set) != length(unique(set)))
   if (any(NOK)) {
      ret$result <- FALSE
      msg <- sprintf(ngettext(sum(NOK),
                              "set %s contains duplicated entries - will be reduced",
                              "sets %s contain duplicated entries - will be reduced"),
                     paste(
                        sQuote(
                           sapply(sets$sets[NOK],
                                  function(.) paste0("(",
                                                     paste(., collapse = ", "),
                                                     ")"))),
                        collapse = ", "))
      ret$msg <- c(ret$msg, msg)
      ret$severity <- "warning"
      sets$sets[NOK] <- lapply(sets$sets[NOK], unique)
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
                           sapply(sets$sets[NOK],
                                  function(.) paste0("(",
                                                     paste(., collapse = ", "),
                                                     ")"))),
                        collapse = ", "))
      ret$msg <- c(ret$msg, msg)
      ret$severity <- "warning"
      sets <- sets[!NOK, ]
   }

   ret$fixed <- sets
   ret
}

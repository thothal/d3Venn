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
               fixed    = NULL)
   if (!is.data.frame(sets)) {
      ret$result <- FALSE
      ret$msg <- gettextf(paste(sQuote("sets"), "must be a data.frame"))
      ret$severity <- "error"
      return(ret)
   }
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

   NOK <- !names(sets) %in% c(required_names, optional_names)
   if (any(NOK)) {
      ret$result <- FALSE
      ret$msg <- sprintf(ngettext(sum(NOK),
                              "unknown field %s - will be dropped",
                              "unknown fields %s - will be dropped"),
                     paste(sQuote(names(sets)[NOK]),
                           collapse = ", "))
      ret$severity <- "warning"
      ret$fixed <- sets[, names(sets)[!NOK]]
      return(ret)
   }
   ret
}

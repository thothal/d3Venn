test_that("d3Venn() fails if sets is not a data.frame", {
   error_msg_rex <- "must be a data\\.frame"
   expect_error(d3Venn(list(1)),
                error_msg_rex)
   expect_error(d3Venn(1),
                error_msg_rex)
})

test_that("d3Venn() fails if required fields are missing", {
   error_msg_rex <- "required fields? .* could not be found"
   sets <- data.frame()
   expect_error(d3Venn(sets),
                error_msg_rex)
   sets <- data.frame(sets = 1)
   expect_error(d3Venn(sets),
                error_msg_rex)
})

test_that("d3Venn() warns if unknown fields are present", {
   warning_msg_rex <- "unknown fields? .* - will be dropped"
   sets <- data.frame(sets = "A", size = 2, new = TRUE)
   expect_warning(d3Venn(sets),
                  warning_msg_rex)
})



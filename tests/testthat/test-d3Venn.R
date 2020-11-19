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

test_that("d3Venn() warns if intersections contain duplicated entries", {
   warning_msg_rex <- "sets? .* contains? duplicated entries - will be reduced"
   sets <- data.frame(sets = I(list("A", "B", list("C", "C"))),
                      size = 1:3)
   expect_warning(d3Venn(sets),
                  warning_msg_rex)
})

test_that("d3Venn() warns if duplicated fields are present", {
   warning_msg_rex <- "sets? .* not unique - will be dropped"
   ## catch duplicated main nodes
   sets <- data.frame(sets = c("A", "A"), size = 1:2)
   expect_warning(d3Venn(sets),
                  warning_msg_rex)
   ## catch duplicated interactions
   sets <- data.frame(sets = I(list("A", "B", list("A", "B"), list("A", "B"))),
                     size = 1:4)
   expect_warning(d3Venn(sets),
                  warning_msg_rex)
   ## should work also if the interactions are sorted differently
   sets <- data.frame(sets = I(list("A", "B", list("A", "B"), list("B", "A"))),
                     size = 1:4)
   expect_warning(d3Venn(sets),
                  warning_msg_rex)

})

test_that("d3Venn() warns if elements in intersections do not appear in main sets", {
   warning_msg_rex <- "element\\(s\\) in sets? .* do not appear as main sets - will be reduced"
   sets <- data.frame(sets = I(list("A", list("C", "D"))), size = 1:2)
   expect_warning(d3Venn(sets),
                  warning_msg_rex)
})



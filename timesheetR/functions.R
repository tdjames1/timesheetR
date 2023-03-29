library(readxl)
library(dplyr)

project_groups <- list(
  SWIFT_FASTA = c("FASTA"),
  SWIFT_PDF = c("PDF data extraction"),
  SWIFT_WP4_Testbed3 = c("WP4", "Testbed 3", "SWIFT general")
)

load_timesheet <- function(file_path) {
  df <- readxl::read_xlsx(file_path) %>%
    # TODO generalise date formatting
    mutate(month = format(Date, "%m"), year = format(Date, "%Y"),
           hours = as.integer(format(Hours, "%H")) + as.integer(format(Hours, "%M"))/60) %>%
    # TODO allow adjustment of project groups
    mutate(project = forcats::fct_collapse(Project, !!!project_groups))
  return(df)
}

get_months <- function(df) {
  month.name[as.numeric(unique(na.omit(df$month)))]
}

get_years <- function(df) {
  unique(na.omit(df$year))
}

get_weekdays_in_month <- function(month, year) {
  dlist = na.omit(as.Date(paste(year, month, 1:31), format = '%Y %B %d'))
  return(sum(!weekdays(dlist) %in% c("Saturday", "Sunday")))
  #return(19)
}

get_summary <- function(file_path, month, year = NULL) {

  ts_data <- load_timesheet(file_path)

  if (is.null(year)) {
    year <- get_years(ts_data) %>% last()
  }

  date <- as.Date(paste(1, month, year), "%d %B %Y")

  ts_total <- group_by(ts_data, year, month) %>%
    summarise(total = sum(hours))

  # Get number of nominal working days in month
  n_days = get_weekdays_in_month(month, year)

  # Number of working days in month * 7.5 = number of working hours in month
  n_hours = n_days * 7.5

  # Calculate adjusted percentage
  # 100 x hours worked / number of working hours in month

  res <- group_by(ts_data, year, month, project) %>%
    summarise(hours = sum(hours)) %>%
    left_join(ts_total) %>%
    mutate(
      `% total` = round(hours/total*100, digits = 2),
      `% adj` = round(hours/n_hours*100, digits = 2)
    ) %>%
    arrange(desc(`% adj`), .by_group = TRUE) %>%
    filter(month == format(date, "%m"), year == format(date, "%Y"))

  return(res)
}

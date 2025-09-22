library(DBI)
library(odbc)

get_databricks_con <- function() {
  tryCatch({
    DBI::dbConnect(
      odbc::odbc(),
      Driver   = "Databricks",     # or an absolute path to the driver .dylib
      Host     = Sys.getenv("DATABRICKS_HOST"),
      HTTPPath = Sys.getenv("DATABRICKS_HTTP_PATH"),
      PWD      = Sys.getenv("DATABRICKS_TOKEN"),
      Port     = 443,
      AuthMech = 3,                # token auth
      SSL      = 1,
      ThriftTransport = 2,
      SparkServerType = 3,
      UID      = "token"
    )
  }, error = function(e) e)        # return the error object instead of crashing
}
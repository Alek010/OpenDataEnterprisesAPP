AppVersionsList <- R6::R6Class(
  classname = "AppVersionsModel",
  public = list(
    get_versions_list = function() {
      versions <- list(
        private$ver_0_1_0
      )

      return(versions)
    }
  ),
  private = list(
    ver_0_1_0 = list(
      Date = as.Date("2023-07-03"), Version = "0.1.0",
      Description = (
        "App works ony with 3 files: enterprises under insolvency proceedings; enterprises shareholders; enterprises joint shareholders.")
    )
  )
)

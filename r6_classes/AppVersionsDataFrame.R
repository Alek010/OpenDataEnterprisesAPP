AppVersionsDataFrame <- R6::R6Class(
  classname = "AppVersion",
  public = list(
    app_verions_list = NULL,
    initialize = function() {
      self$app_verions_list <- AppVersionsList$new()
    },
    get_df = function() {
      versions <- self$app_verions_list$get_versions_list()

      for (i in 1:length(versions)) {
        versions[[i]]$Description <- private$description_into_html_list(versions[[i]]$Description)
      }

      return(bind_rows(versions))
    }
  ),
  private = list(
    description_into_html_list = function(version_description) {
      for (i in 1:length(version_description)) {
        version_description[i] <- paste0("<li>", version_description[i], "</li>")
      }

      return(paste0("<ol>", paste(version_description, collapse = ""), "</ol>"))
    }
  )
)



#' @title download_pictures
#' @description This function looks through all the uploaded photos to the field notes and downloads the photos to a specified folder. It will only download photos that have not yet been downloaded.
#' # Download all user created photos ( upstream, downstream, clarity, filter and other pictures)
# Label according to site, date, description in the format site_YYYYMMDD_descriptor.jpg

#' @param field_notes A dataframe containing field notes with columns: site, crew, start_DT,end_dt, cal_report_collected, cals_performed, log_downloaded, log1_type,log1_mmdd,  log2_type, log2_mmdd
#' @param download_path A string filepath to the current file where field pictures should be downloaded to. If it does not exist yet, a sub folder named sampling_pics will be created at this path
#'
#' @example
#' source("src/download_pictures.R")
#' download_pictures(field_notes = all_notes_cleaned,
#'               download_path = "data/field_pics/")

download_pictures <- function(field_notes, download_path = "data/field_pics/"){

  # Find all the downloaded pictures
  all_file_names <- list.files(path = here(download_path), recursive = TRUE, full.names = T)
  # basic path to field pics
  path <- here(paste0(download_path, "/sampling_pics/"))

  #create folder if it does not exist
  if(!dir_exists(path)){
    dir_create(path)
  }

  #grab notes
  sampling_photos <- field_notes%>%
    #grab needed columns
    select(site, start_dt,photos_downloaded,upstream_pic,downstream_pic,clarity,filter_pic,other_pic,other_pic_descriptor)%>%
    mutate(
      #correct names if it is in our upper sites (upper case acronyms)
      site = tolower(site),
      #Date format for pictures
      yyyymmdd = format(start_dt, "%Y%m%d"),
      #create filenames ONLY if there is a URL associated with the site visit
      upstream_filename = case_when(
        !is.na(upstream_pic) ~ here(paste0(path, site, "_", yyyymmdd, "_upstream.jpg")),
        TRUE ~ NA_character_
      ),
      downstream_filename = case_when(
        !is.na(downstream_pic) ~ here(paste0(path, site, "_", yyyymmdd, "_downstream.jpg")),
        TRUE ~ NA_character_
      ),
      clarity_filename = case_when(
        !is.na(clarity) ~ paste0(path, site, "_", yyyymmdd, "_clarity.jpg"),
        TRUE ~ NA_character_
      ),
      filter_filename = case_when(
        !is.na(filter_pic) ~ paste0(path, site, "_", yyyymmdd, "_filter.jpg"),
        TRUE ~ NA_character_
      ),
      # check to see if the photo is already downloaded to folder
      upstream_downloaded = case_when(
        is.na(upstream_filename) ~ NA,
        upstream_filename %in% all_file_names ~ TRUE,
        TRUE ~ FALSE
      ),
      clarity_downloaded = case_when(
        is.na(clarity_filename) ~ NA,
        clarity_filename %in% all_file_names ~ TRUE,
        TRUE ~ FALSE
      ),
      filter_downloaded = case_when(
        is.na(filter_filename) ~ NA,
        filter_filename %in% all_file_names ~ TRUE,
        TRUE ~ FALSE
      ),
      downstream_downloaded = case_when(
        is.na(downstream_filename) ~ NA,
        downstream_filename %in% all_file_names ~ TRUE,
        TRUE ~ FALSE
      )
    )



  # loop thru dataset and download the photo ONLY if it is not yet downloaded and not NA
  for (i in 1:nrow(sampling_photos)) {
    if (!is.na(sampling_photos$upstream_downloaded[i]) && !sampling_photos$upstream_downloaded[i]) {
      #print(sampling_photos$upstream_filename[i])
      download.file(sampling_photos$upstream_pic[i], destfile = paste0(sampling_photos$upstream_filename[i]))
    }

    if (!is.na(sampling_photos$downstream_downloaded[i]) && !sampling_photos$downstream_downloaded[i]) {
      #print(sampling_photos$downstream_filename[i])
      download.file(sampling_photos$downstream_pic[i], destfile = paste0(sampling_photos$downstream_filename[i]))
    }
    if (!is.na(sampling_photos$clarity_downloaded[i]) && !sampling_photos$clarity_downloaded[i]) {
      #print(sampling_photos$clarity_filename[i])
      download.file(sampling_photos$clarity[i], destfile = paste0(sampling_photos$clarity_filename[i]))
    }
    if (!is.na(sampling_photos$filter_downloaded[i]) && !sampling_photos$filter_downloaded[i]) {
      #print(sampling_photos$filter_filename[i])
      download.file(sampling_photos$filter_pic[i], destfile = paste0(sampling_photos$filter_filename[i]))
    }
  }



  #grab notes for sites with other pictures
  other_photos <- field_notes%>%
    #grab needed columns
    select(site, start_dt,other_pic,other_pic_descriptor)%>%
    #get rid of instances with no other pics
    filter(!is.na(other_pic))%>%
    mutate(
      site = tolower(site),
      #Date format for pictures
      yyyymmdd = format(start_dt, "%Y%m%d"),
      # separate multiple URLs in other pic column
      other_pic_sep = str_split(other_pic, "; "),
      #seperate multiple descriptors in the descriptor column
      other_descriptor_sep = str_split(other_pic_descriptor, ","))%>%
    #for rows with multiple pictures, create a new row for each picture

    unnest(cols = c(other_pic_sep, other_descriptor_sep))%>%
    #remove excess columns and rename sep columns to match old columns
    select(site, start_dt,yyyymmdd, other_pic = other_pic_sep, other_pic_descriptor = other_descriptor_sep)%>%
    # make descriptor lower case and remove any spaces in the name
    mutate(other_pic_descriptor = tolower(str_replace_all(other_pic_descriptor, " ", "_")),
           other_filename = case_when(!is.na(other_pic) ~ here(paste0(here(download_path), "/", site, "_", yyyymmdd, "_", other_pic_descriptor, ".jpg"))),
           # Check to see if photo has already been downloaded
           other_downloaded = case_when(
             is.na(other_filename) ~ NA,
             other_filename %in% all_file_names ~ TRUE,
             TRUE ~ FALSE
           ))

# find all the descriptors > 25 characters

long_desc <- other_photos%>%
  filter(nchar(other_pic_descriptor) > 40 & !other_downloaded)

if(nrow(long_desc) > 0) {
  for (i in 1:nrow(long_desc)) {
      cat("\nWarning: The descriptor for ",long_desc$site[i], " on ", as.character(as.Date(long_desc$start_dt[i])), " too long for a file name:\n",
          long_desc$other_pic_descriptor[i], "\nPlease shorten the descriptor in mWater.\n")
  }
  #prompt user to proceed
  proceed <- readline(prompt = "Do you want to continue downloading pictures? (yes/no): ")
  if (tolower(proceed) != "yes") {
    cat("Download cancelled\n")
    return()
  }
}



  # loop thru dataset and download the photo ONLY if it is not yet downloaded and not NA
  for (i in 1:nrow(other_photos)) {
    if (!is.na(other_photos$other_downloaded[i]) && !other_photos$other_downloaded[i]) {
      #print(other_photos$other_filename[i])
      download.file(other_photos$other_pic[i], destfile = paste0(other_photos$other_filename[i]))
    }}

cat("\nAll Available Pictures Downloaded\n")
}

#download_pictures()
#RUN TO DOWNLOAD NEW PICTURES
# It takes about 2-5 minutes to download ~25-50 photos
# Sometimes the request to mWater time out, just re run the function below if that happens




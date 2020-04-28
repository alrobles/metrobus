# start from the rocker/r-ver:3.6.2 image
FROM rocker/r-ver:3.6.2

# install the linux libraries needed for package
RUN apt-get update -qq && apt-get install -y \
      libssl-dev \
      libcurl4-gnutls-dev
# install r packages
RUN R -e "install.packages(c('jsonlite', 'RSQLite', 'plumber', 'DBI', 'dplyr', 'purrr'))"

# copy everything from the current directory into the container
COPY / /

# open port 80 to traffic
EXPOSE 3737

# when the container starts, start the plumber and run_sql_etl script
ENTRYPOINT ["Rscript", "main.R"]
ENTRYPOINT ["Rscript", "sql_etl.R"]      
      
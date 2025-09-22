# Works on Apple Silicon and in Azure (we’ll build as amd64)
FROM ghcr.io/rocker-org/shiny:latest

# System libs for odbc etc. (safe to keep even if you don’t use DB yet)
RUN apt-get update && apt-get install -y --no-install-recommends \
      unixodbc unixodbc-dev libssl-dev libsasl2-dev libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# R packages your app needs
RUN R -e "install.packages(c('shiny','DT','readr','DBI','odbc','dplyr','ggplot2'))"

# Copy app to the root Shiny site directory (served at "/")
WORKDIR /srv/shiny-server/
COPY . .

# Let Rocker start shiny-server
EXPOSE 3838

CMD ["R", "-e", "shiny :: runApp('./app.R', host='0.0.0.0', port=3838)"]
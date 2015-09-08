loadCredentials <- function(file="/tmp/credentials/example.yml") {
    creds <- "credentials/credentials.yml"
    if (file.exists(creds)) yaml.load_file(creds)
}


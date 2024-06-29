Function Start-Ninite {
    Start-Process -Filepath "$scriptroot\$Ninite" -ArgumentList "/Silent"
}
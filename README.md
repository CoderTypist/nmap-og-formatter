# nmap-og-formatter

### Description:
Formats grepable output produced by nmap when using the -oG option

### Motivation:
The grepable output can be a little difficult to read. This makes it easier to see which ports are open. This makes the results look more similar to the actual nmap output.

### Disclaimer:
In retrospect, it would have been better to create a script that parses nmap's xml output (-oX) than nmap's grepable output (-oG) produced by nmap. I was skimming through the nmap book and the author said that the format of grepable output may be changed in future versions of nmap. This means that any changes to the format of nmap's grepable output will break the script. However, if a script parses nmap's xml output, then it will be resistant to any changes made to the format of nmap's output. A script that parses xml output could be named ```nmap_ox_formatter``` instead of ```nmap_og_formatter```.

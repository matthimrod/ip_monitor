# ip_monitor.pl
Simple Perl script to monitor for public IP changes.

## Configuration

The script requires a configuration/data file `ip_monitor.yml` that will be read/rewritten by the script. The script uses Gmail to send an email alerting when the IP address changes. The format is as follows:

    ---
    api_url: https://api.ipify.org
    config:
      email_from: username@gmail.com
      email_to: username@gmail.com
      username: username@gmail.com
      password: password
    last_address: 12.23.34.45

* `api_url` is the URL to use for the lookup, such as ipify.org, whatismyipaddress.com, or my-ip.io. There are several. The only requirement is that the destination API return a plain text IP address.
* `config` section contains the email configuration
  * `email_from` is the from email address. This needs to be an email address that the Gmail account has previously authorized to send mail. 
  * `email_to` is the destination email address.
  * `username` and `password` are the credentials to the Gmail account.
* `last_address` is set and updated by the program itself. When the IP address returned by the API differs from this, an email is sent.

Logging currently goes to ip_monitor.log, but this can be changed by modifying line 11. I'll add this to the config file for greater flexibility in a future version.

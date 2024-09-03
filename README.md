Generate your own self signed certificates using a custom Root CA so you can have https for your local environment.

# Usage
### Edit certificate data (Optional)
Open the bash script and edit the root certificate and ssl certificate data as needed.

### Generate
Run the script and pass the domain you want to generate a new ssl certificate for.
``` bash
./generate_self_signed_certificate.sh sursill.dev
```
This will generate a `local_rootCA.crt` that you can install to the browser of your choice. The script will also generate a new folder for your domain. The folder contains the certifcate and key that you can use in your web server. The script also automatically includes the `www` subdomain of your domain.

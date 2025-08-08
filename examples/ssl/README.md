## Local CA Setup

### Introduction

This guide will walk you through setting up a local Certificate Authority (CA) and generating SSL certificates for your awesome projects. Having your own CA gives you more control, which can be of help if you're running a multi-container setup.

### Prerequisites

Make sure you have the following installed:

*   **OpenSSL:** You probably already have it. If not, install it using your system's package manager. For example:
    *   **Gentoo:** `sudo emerge -av dev-libs/openssl`
    *   **Debian:** `sudo apt-get install openssl`
    *   **RHEL:** `sudo yum install openssl`
    *   **macOS:** `brew install openssl` (if you have Homebrew)
*   **The text editor of your choice:** Vim, Emacs or Zed, whatever floats your boat.

Nice to have:

*   **Basic Linux command-line knowledge:** You should be comfortable navigating directories and running commands. If you're a complete newbie, DuckDuckGo is your friend.

### Configuration steps

1.  **Create the CA directory structure in a location of your choice,:**

    ```bash
    mkdir -p ca/{certs,crl,csr,newcerts,private}
    ```

    This command creates the necessary directories for storing your certificates, Certificate Revocation Lists (CRLs), Certificate Signing Requests (CSRs), newly signed certificates, and private keys. The `-p` flag ensures that parent directories are created if they don't exist.

2.  **Set permissions:**

    ```bash
    cd ca
    chmod 700 certs crl csr newcerts private
    ```

    This sets the permissions on the directories to restrict access to only the owner (usually root). This is crucial for security.

3.  **Create and secure the `openssl.conf` file:**

    You can use the example provided with AINode, assuming you've created the `ca` directory in the cloned repo's root:
    ```bash
    cp ../examples/ssl/openssl.conf ./
    chmod 600 openssl.conf
    ```

    The `openssl.conf` file contains the configuration options for OpenSSL.  You'll need to make some adjustments to specify the CA key and certificate location, as well as other settings.
    ```bash
    vim openssl.conf
    ```

4.  **Initialize the certificate serial number file:**

    ```bash
    touch index.txt
    echo '01' > serial
    ```

    This initializes the serial number file, which keeps track of the certificates you've issued. The `index.txt` file is used to store the serial numbers, and the `serial` file contains the current serial number.

5.  **Generate the CA key and certificate:**

    ```bash
    openssl genrsa -aes256 -out private/ca.key 4096
    openssl req -config openssl.conf -key private/ca.key -new -x509 -nodes -sha256 -extensions v3_ca -days 3650 -out certs/ca.crt
    ```

    The first command generates a 4096-bit RSA key and saves it to `private/ca.key`. You should provide a secure password when asked. The second command creates the CA certificate using the generated key and the configuration file. The `-days 3650` option specifies that the certificate will be valid for 10 years. Adjust this as needed.

6.  **Generate a Certificate Signing Request (CSR) for your AINode instance:**

    First, you want to create the `csr/ainode.conf` file. You can use the provided example. The `csr/ainode.conf` file contains the configuration options for the CSR. ***If you're going to access Comfyui, Kokoro or Ollama API over SSL beside the Open WebUI interface, you have to provide their hostnames as `alt_names` in this file.***

    ```bash
    cp ../examples/ssl/ainode.conf csr/
    ```

    ```bash
    openssl genrsa -out private/ainode.key 2048
    openssl req -config csr/ainode.conf -key private/ainode.key -new -sha256 -out csr/ainode.csr
    ```

    This generates a 2048-bit RSA key for your AINode instance and creates a CSR.

7.  **Sign the AINode CSR with the CA:**

    ```bash
    openssl ca -config openssl.conf -days 3650 -in csr/ainode.csr -out certs/ainode.crt -extensions req_ext -extfile csr/ainode.conf
    ```

    This signs the AINode CSR with your CA certificate, creating the final SSL certificate. The `-days 3650` option specifies that the certificate will be valid for 10 years.

8.  **Install the certificates:**

    First, place the `ainode.crt` and `ainode.key` in the `ssl` directory of repo's root:

    ```bash
    cp certs/ainode.crt ../ssl/
    cp private/ainode.key ../ssl/
    ```

    You should also install the `certs/ca.crt` as a local CA for your web browser.

###  Important considerations

*   **Security is paramount:** Protect your CA private key (`private/ca.key`).  If it's compromised, your entire PKI is compromised.
*   **Key Rotation:** In a production environment, regularly rotate your CA key and certificate to minimize the impact of potential security breaches.
*   **`csr/ainode.conf`:** This file is *crucial*. Make sure it contains the correct information about your AINode instance.

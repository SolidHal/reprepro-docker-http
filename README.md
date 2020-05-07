# Reprepro (debian apt-get repository)

Debian package repository.

* Based upon: [the guide for setting up a private debian repository](http://wiki.debian.org/SettingUpSignedAptRepositoryWithReprepro).
* Purpose: Hosting in-house deb packages, not designed to fulfill the role of a full repository.

## Building the image (in-house)
```bash
$ git clone git@bitbucket.org:iomoss/docker-files.git
$ cd docker-files/reprepro
$ ./create-image.sh
```
Access to the repository requires affiliation with IOMOSS.

## Running (in-house)
```bash
$ git clone git@bitbucket.org:iomoss/docker-files.git
$ cd docker-files/reprepro
$ ./run.sh /home/skeen/reprepro 8080 2222
```
Access to the repository requires affiliation with IOMOSS.

## Running (stand-alone)
### Configuration done
Assuming the configuration is done, you can start the server as;
```bash
$ export CONFIG_FOLDER=/home/config_here
$ export WEBSERVER_PORT=8080
$ export SSH_PORT=2222
$ docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -d iomoss/reprepro
```

### Configurating
There are three ways to configurate the image;

* Interactive
* Environmental
* Manual

Stand-alone (Interactive configuration);
```bash
$ export CONFIG_FOLDER=/home/config_here
$ export WEBSERVER_PORT=8080
$ export SSH_PORT=2222
$ docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -it iomoss/reprepro
```

Stand-alone (Environemental configuration);
```bash
$ export CONFIG_FOLDER=/home/config_here
$ export WEBSERVER_PORT=8080
$ export SSH_PORT=2222
$ export KEY_REAL_NAME="{{YOUR-NAME}}"
$ export KEY_COMMENT="{{GPG-KEY COMMENT}}"
$ export KEY_EMAIL="{{YOUR-EMAIL}}"
$ export HOSTNAME="{{YOUR-DOMAIN-NAME}}"
$ export PROJECT_NAME="{{NAME-OF-APT-REPO}}" 
$ export CODE_NAME="{{CODENAME-OF-OS-RELEASE}}" 
$ docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 \
             -e KEY_REAL_NAME=$KEY_REAL_NAME -e KEY_COMMENT=$KEY_COMMENT \
             -e KEY_EMAIL=$KEY_EMAIL -e HOSTNAME=$HOSTNAME \
             -e PROJECT_NAME=$PROJECT_NAME -e CODE_NAME=$CODE_NAME \
             -it iomoss/reprepro
```

Stand-alone (Manual); The same as 'Configuration done'

### Configuration variables
#### Run configuration

* `$CONFIG_FOLDER`: The folder in which the reprepro configuration is stored.
* `$WEBSERVER_PORT`: The exposed nginx port (where packages are served).
* `$SSH_PORT`: The exposed openssh-port (which is used for uploading packages).

#### Setup configuration
*Note: Running in interactive configuration mode will prompth the user for this information.*

*Note: For manual configuration see the bottom of this file.*

* `$KEY_REAL_NAME`: The name to be used on the GPG keys
* `$KEY_COMMENT`: The comment to be used on the GPG keys
* `$KEY_EMAIL`: The email to be used on the GPG keys

* `$HOSTNAME`: The hostname of the server (i.e. the url on which it's reached).
* `$PROJECT_NAME`: The name of the apt repository (can be anything).
* `$CODE_NAME`: The code-name of the os release for which packages will be served (wheezy/jessie/ect).

### Outside configuration
While most of the configuration can be done inside the container.

The `authorized_keys` file (for uploading packages) must be supplied from outside the container.

#### Setting up `authorized_keys`
The keys are required for adding packages to the system, and should be added to;
```bash
$CONFIG_FOLDER/home/debian/.ssh/authorized_keys
```
Assuming you have generated a ssh key-set on the machine, you can do this by running;
```bash
$ export CONFIG_FOLDER=/home/config_here
$ cp ~/.ssh/id_rsa.pub $CONFIG_FOLDER/home/debian/.ssh/authorized_keys
```
Generating a ssh key-set can be done by running;
```bash
$ ssh-keygen
```
And following the instructions.

*Note: The image is able to run without `authorized_keys` being in place,
however uploading packages will not be an option then.*

## Uploading packages
The below assumes that you are in the folder of your `.deb` package.

The example is based upon uploading `kicad*.deb` (multiple packages).
```bash
$ export SSH_PORT=2222
$ export HOSTNAME="{{YOUR-DOMAIN-NAME}}"
$ export CODE_NAME="{{CODENAME-OF-OS-RELEASE}}"
$ scp -P SSH_PORT kicad*.deb debian@$HOSTNAME:
$ ssh -p SSH_PORT debian@$HOSTNAME "sudo chmod -R 777 /var/www/repos/"
$ ssh -p SSH_PORT debian@$HOSTNAME "reprepro -b /var/www/repos/apt/debian includedeb $CODE_NAME *.deb"
```

## Client Configuration
Once the repository is up and running, clients will need to be configured to use it.

The nginx webserver (which hosts the repository) has an index page with configuration information.

Assuming your hostname is `$HOSTNAME` head over to `http://$HOSTNAME/`, and these two commands will be shown;

### Registering the GPG public key
```bash
$ wget -O - http://$HOSTNAME/$HOSTNAME.gpg.key | apt-key add - 
```

### Registering the repository to `sources.list.d`
```bash
$ echo "deb http://$HOSTNAME/ $CODE_NAME main" > /etc/apt/sources.list.d/$HOSTNAME.list 
```

### Installing packages
At this point the repository is added, and you can run;
```bash
$ apt-get update
$ apt-get install $PACKAGE_NAME
```
To install `$PACKAGE_NAME` from your own repository to the client system.

*Note: The repository is non-functional until the first package has been added.*

## Manual configuration
Instead of using the interactive or environmental configuration,
you can simply provide your own configuration files inside `$CONFIG_FOLDER`,
alike how it was done with the `authorized_keys` file.

### Setting up `authorized_keys`
See the section above.

### Setting up gpg-keys
The GPG keys are used for signing packages, they can be provided to;
```bash
$CONFIG_FOLDER/home/debian/.gnupg/pubring.pgp
$CONFIG_FOLDER/home/debian/.gnupg/secring.pgp
```
Generating gpg keys can be done by running;
```bash
$ gpg --gen-key
```
The keys will be output to `~/.gnupg/*.gpg`

### Setting up nginx
The nginx `sites-enabled` file can be provided as:
```bash
$CONFIG_FOLDER/etc/nginx/sites-enabled/reprepro-repository
```

### Setting up reprepro
The reprepro configuration file can be provided as;
```bash
$CONFIG_FOLDER/var/www/repos/apt/debian/conf/options
```

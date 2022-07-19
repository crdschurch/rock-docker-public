## Important Notes

1. The images that are generated from this repository are Windows Containers, and Docker Desktop needs to be configured to run Windows Containers.
2. There are two images that need to be created:
    - The rock web image (Created with the [dockerfile](./Dockerfile))
    - The sql server image (Created with the [steps outlined below](https://github.com/crdschurch/rock-docker-public#how-to-build-the-sql-server-image))
3. Once both images are created lines 4 and 11 of the [compose](./compose.yml) file need updated with the image names and tags

## How to build the Rock Web Image

- Open your cli of choice and navigate to the repository that contains the Dockerfile
- Create a docker network 
`docker network create -d nat --gateway 172.8.128.1 --subnet 172.8.128.0/20 -o com.docker.network.windowsshim.dnsservers=4.4.4.4,8.8.8.8 -o com.docker.network.windowsshim.disable_gatewaydns=true MyPublic`
    - This creates a way for the docker container to connect to the internet and download the .NET 3.5 features needed to run the Rock Installer. The network is called MyPublic.
    - If you get an error "Error response from daemon: plugin "nat" not found", then make sure docker desktop is **switched to use windows containers**
- Build the docker image `docker build -t <your dockerhub organization/reponame:tag> . --network "MyPublic"`
    - The first time this runs may take awhile because Docker needs to pull all of the images. Once it runs the first time it will use the Docker Cache and be much much faster.
- Update line 11 in the [compose](./compose.yml) file to the image tag you used in the step above (<your dockerhub organization/reponame:tag>)

## How to build the SQL Server Image

- Create the container `docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Password1!" -p 1433:1433 --name sql octopusdeploy/mssql-server-windows-express`
    - The value you put after "SA_PASSWORD=" is the password for the sa account into SQL Server. I would suggest using something stronger than Password1.
    - `--name` is the name of the container you create, in this case sql.
    - The above command runs a docker container on port 1433 of your local machine running a version of SQL Server Express.
- You can access the server via SSMS on your local machine:
     - Server name: 127.0.0.1
     - Login: sa
     - Password: <value you put after SA_PASSWORD=> 
- Create a new Database and remember the name. This will be needed when running the Rock Installer
- Save all the changes you have made to the base image `docker commit <value you used for --name in the command above> <your dockerhub organization/reponame:tag>`
    * i.e `docker commit sql crdschurch/crds-rock-dev-env:db_v1`
- Update line 4 of [compose](./compose.yml) to the image tag you used in the step above
- Stop running container `docker stop <value you used for --name 2 commands ago>`

## Standing up the Containers

- In the same directory as the the compose.yml file run `docker-compose up -d`
    - The `-d` means that you will still be able to use the command line that intiated the docker-compse command. With out the -d the commandline only runs the containers.
- Once the containers are running navigate to `localhost:9000/Start.aspx` or `localhost:9001/Start.aspx` to enable SSL.
- Follow the steps in the Rock Installer

## Saving your DB

- Once the installer is finished and has added all the tables needed for the Rock to your SQL Server DB you will want to save those changes. 
- `docker commit sql-server <image name you used when creating the sql server docker container>`
    * i.e `docker commit sql-server crdschurch/crds-rock-dev-env:db_v1`

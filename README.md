# this project is designed to test cicd functionality #
checking cicd functionality today.....
######### post build commands in jenkins ############

docker build -t testimage:$BUILD_NUMBER .

docker rm -f $(docker ps |grep test1 |awk '{print $1}')

docker run --name test1 -d -p 80:80 testimage

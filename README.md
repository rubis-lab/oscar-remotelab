## RemoteLab Image management
RemoteLab image management consists of two parts:  
 Reservation Checker and Image Deployer. 

---
### Reservation Checker
It checks whether there is a reservation starting in n minutes using the ```/soon``` function of the reservation server. If there is one, it pulls an appropriate image from the repository and runs the container. It schedules an Image Deployer to be run at reservation finish time.  
Implemented in ```cron.sh```.

### Image deployer
It stops running container and saves as a new image to the reposiroty.  
Implemented in ```image_deploy.sh```.

curl -LO allbombson.github.io/TARBS/tarbs.sh
sudo bash tarbs.sh

dialog --infobox "Downloading and installing Black Arch Tools and More..." 4 60
curl -O https://blackarch.org/strap.sh
sudo bash strap.sh
sudo pacman -S blackarch

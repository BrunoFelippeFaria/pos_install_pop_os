#!/usr/bin/bash

# Pop os 22.04 LTS


#cores
VERMELHO='\e[1;91m'
SEM_COR='\e[0m'

#Funções

parar(){
	pkill -9 -f posinstall.sh
}

apt_update(){
	sudo apt update && sudo apt dist-upgrade -y
}


#======================================TESTES E REQUISITOS=====================================================================

# Detectar internet

testes_internet(){
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
	echo -e "${VERMELHO}[ERROR] - Seu computador não está conectado a internet ${SEM_COR}"
	parar
fi
}

#=======================================CONFIGURAÇÃO DO GNOME=====================================================================

alterar_aparencia(){
echo -e "configurando aparencia do sistema..."
#tema
gsettings set org.gnome.desktop.interface gtk-theme "Pop-dark"
#dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode MAXIMIZED_WINDOWS
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 28
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-alignment 'CENTER'
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
}

#========================================INSTALAÇÃO APT=================================================================

apps_para_instalar=(
	mpv
	git
	wget
	translate-shell
	htop
	golang-go
	neofetch
	code
	links2
	feh
	ranger
	python3-pip
	pipx
	curl
)

instalar_apt(){
echo -e "Instalando pacotes apt"

for programa in ${apps_para_instalar[@]}; do
  if ! dpkg -l | grep -q $programa; then # Só instala se já não estiver instalado
    sudo apt install "$programa" -y
	echo "$programa foi instalado!"
  else
    echo "$programa já está instalado"
  fi
done
}

#===================================INSTALAÇÃO FLATPAKS======================================================================

flatpaks_para_instalar=(
	org.gimp.GIMP
	io.github.jeffshee.Hidamari
	io.appflowy.AppFlowy
	com.rtosta.zapzap
)

instalar_flatpaks(){
for flat in ${flatpaks_para_instalar[@]}; do
	if ! flatpak list --app | grep -q $flat; then
		flatpak install flathub $flat -y
	else
		echo "$flat já está instalado"
	fi
done
}

#===========================================INSTALAÇÃO PIPX=================================================================

pipx_para_instalar=(
	yewtube
	Trackma
)
instalar_pipx(){
for p in ${pipx_para_instalar[@]}; do
	if ! pipx list | grep -q $p; then
		pipx install $p
	fi
done
}

#========================================INSTALAÇÃO GIT=================================================================

# Go anime
instalar_goanime(){
	if [ ! -f /usr/local/bin/goanime ]; then
		git clone https://github.com/alvarorichard/GoAnime.git
		cd GoAnime/cmd/goanime
		echo "instalando go anime..."
		go build -o main .
		sudo mv main /usr/local/bin/goanime
		sudo ln -f /usr/local/bin/goanime /usr/local/bin/go-anime
		cd ../../..
		sudo rm -rf GoAnime/
	else
		echo "go anime já está instalado"
	fi
}

#==============================INSTALAÇÃO CURL=============================================================================

instalar_curl(){
#tgpt
if [ ! -f /usr/local/bin/tgpt ]; then
	curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin
else
	echo "tgpt já está instalado"
fi

#neovim
if [ ! -f /usr/local/bin/nvim ]; then
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	sudo mv nvim.appimage /usr/local/bin/nvim
fi

# vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

#============================================================Finalização==========================================

system_clean(){
apt_update -y
flatpak update -y
sudo apt autoclean -y
sudo apt autoremove -y
nautilus -q
}

#------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------executar

testes_internet
apt_update
alterar_aparencia
instalar_apt
instalar_flatpaks
instalar_pipx
instalar_curl
instalar_goanime
apt_update
system_clean

echo "Pos instalação finalizada"

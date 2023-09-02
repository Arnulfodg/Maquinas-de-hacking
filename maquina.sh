#! /bin/bash

#---colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
#---end colores

#---control c

function ctrl_c() {
	echo -e "\n\n ${redColour}[!] saliendo...\n${endColour}"
	tput cnorm && exit 1
}

#Ctrl+c
	trap ctrl_c INT

#---end control c
#-- variables globales

main_url=https://htbmachines.github.io/bundle.js

#function of the help Panle

function helPanel(){
echo -e "\n${greenColour}[+]${endColour}${yellowColour}\tPanel de ayuda${endColour}"
echo -e "\tu) Descarga y actualizacion de los archivos necesarios"
echo -e "\tm) Realizar busqueda  por nombre de maquina"
echo -e "\td) Realizar busqueda por dificultad de la maquina"
echo -e "\ti) Realizar busqueda por IP de la maquina"
echo -e "\to) Realizar busqueda por sistema operativo"
echo -e "\ty) obtener link para saber resolver la maquina"
echo -e "\th) Mostrar el panel de ayuda"
}

# funcion del updatefile

function updateFile(){
	echo -e "\n Comprobando la descarga de los archivos necesarios"
	sleep 1
if [ ! -f maquina.js ]; then
	echo -e "\n[-]\tDescargando o Actualizando los archivos necesarios...\n"
	curl -s $main_url > maquina.js
	js_beautify maquina.js | sponge maquina.js
	echo -e "\n[-]\tTodos los archivos han sido descargados...\n"
else
	curl -s $main_url > maquina_temp.js
	js_beautify maquina_temp.js | sponge maquina_temp.js
	md5sum_temp=$(md5sum maquina_temp.js | awk '{print $1}')
	md5sum_orig=$(md5sum maquina.js | awk '{print $1}')

if [ "$md5sum_temp" == "md5sum_orig" ]; then
	echo -e "\nNo existen actualizaciones"
	rm maquina_temp.js
else
	echo -e "\nRealizando actualizaciones"
	rm maquina.js && mv maquina_temp.js maquina.js
	sleep 2
fi
	echo -e "\nTodos los Archivos estan Actualizados"
fi
}

#function del searchmachine

function searchMachine(){
        machineName="$1"

	v_maquina="$(cat maquina.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -i -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
if [ "$v_maquina" ]; then
	echo -e "\nRealizando busqueda de la maquina"
	cat maquina.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -i -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
else
	echo -e "\n\t [-] La maquina no existe"
fi
}

#funcion ipAdd

function searchIP(){
	ipAdd="$1"
	v_ip="$(cat maquina.js | grep "ip: \"$ipAdd\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ",")"
if [ $v_ip ]; then
	echo -e  "La maquina que corresponde a la ip $ipAdd es la $v_ip"
else
	echo -e "\n\t [-] La maquina no existe"
fi
}

#funcion de youtube

function youtube(){
	machineName=$1
	youtube_l="$(cat maquina.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print$NF}')"
if [ $youtube_l ]; then
	echo "Puedes ver el tutorial en el siguiente enlace $youtube_l"
else
	 echo -e "\n\t [-] La maquina no existe"
fi
}

function dificulty(){
	dificultad="$1"
	busqueda="$(cat maquina.js | iconv -f UTF-8 -t ASCII//TRANSLIT |grep -i "dificultad: \"$dificultad\"" -B 5 | grep "name:" | awk 'NF{print $NF}' |tr -d '"' | tr -d ',' | column)"
if [ "$busqueda" ]; then
	echo -e "\n\t Estas son las maquinas con la dificultad $dificultad \n"
	cat maquina.js | iconv -f UTF-8 -t ASCII//TRANSLIT |grep -i "Dificultad: \"$dificultad\"" -B 5 | grep "name:" | awk 'NF{print $NF}' |tr -d '"' | tr -d ',' | column
else
	echo -e "\n\t [-] La maquina no existe"
fi
}

#busqueda por sistema operativo

function system(){
	os="$1"
	os_b="$(cat maquina.js | grep -i "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' |tr -d '"' | tr -d ',' | column)"
if [ "$os_b" ]; then
        echo -e "\n\t Estas son las maquina con el sistema operativo $os \n"
        cat maquina.js | grep -i "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' |tr -d '"' | tr -d ',' | column
else
        echo -e "\n\t [-] La maquina no existe"
fi
}

#funcion busqueda de os y dificultad

function dif_os(){
      d_o="$( cat maquina.js | iconv -f UTF-8 -t ASCII//TRANSLIT | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$dificultad\"" -B 5 | grep -i "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
if [ "$d_o" ]; then
        echo -e "\n\t Estas son las maquina filtradas por sistema operativo $os y dificultad $dificultad"
  	cat maquina.js | iconv -f UTF-8 -t ASCII//TRANSLIT | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$dificultad\"" -B 5 | grep -i "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
else
        echo -e "\n\t [-] El filtro que deseas realizar es incorrecto"
fi

}

#espias de filtrado

declare -i espia_dif=0
declare -i espia_os=0

#indicadores de variable solo para numeros

declare -i parameter_counter=0

# panel de ayuda

while getopts "m:ui:y:d:o:h" arg; do
	case $arg in
	m) machineName="$OPTARG"; let parameter_counter+=1;;
	u) let parameter_counter+=2;;
	i) ipAdd="$OPTARG"; let parameter_counter+=3;;
	y) machineName="$OPTARG"; let parameter_counter+=4;;
	d) dificultad="$OPTARG"; espia_dif=1; let parameter_counter+=5;;
	o) os="$OPTARG"; espia_os=1; let parameter_counter+=6;;
	h);;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFile
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAdd
elif [ $parameter_counter -eq 4 ]; then
	youtube $machineName
elif [ $parameter_counter -eq 5 ]; then
	dificulty $dificultad
elif [ $parameter_counter -eq 6 ]; then
        system $os
elif [ $espia_dif -eq 1 ] && [ $espia_os -eq 1 ]; then
	dif_os $espia_dif $espia_os 
else
	helPanel
fi

#Practica del curso de hack4you by S4vitar

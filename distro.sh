#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : distro
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
#--------1---------2---------3---------4---------5---------6---------7---------8
function distro_name 
{
  ## Briefs: 
  ##   - DE: zeigt den Namen der Linux-Distribution
  ##   - EN: displays the name of the Linux distro 
  ##   - ES: muestra el nombre de la distribución de Linux
  ##   - FR: affiche le nom de la distribution Linux 
  ##   - IT: visualizza il nome distribuzione Linux
  ## Comments: 
  ##     Linux distro: suse redhat centos debian ubuntu gentoo
  ## Returns:
  ##   - stdout: linux distro
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: assert -la -r0 -c'distro_name'
  ## Usages: distro_name
  ## Comments: |
  ##
  local _os=$(uname -s | tr "[:upper:]" "[:lower:]")
  local distro=''
  #
  if [ $_os = 'linux' ]
  then    
      [[ -r /etc/SuSE-release      ]] && distro='suse'
      [[ -r /etc/redhat-release    ]] && distro='redhat'
      [[ -r /etc/fedora-release    ]] && distro='fedora'
      [[ -r /etc/centos-release    ]] && distro='centos'
      [[ -r /etc/slackware-release ]] && distro='slackware'
      [[ -r /etc/debian_release    ]] && distro='debian'
      [[ -r /etc/debian_release    ]] && distro='debian'
      [[ -r /etc/mandrake-release  ]] && distro='mandrake'
      [[ -r /etc/yellowdog-release ]] && distro='yellowdog'
      [[ -r /etc/gentoo-release    ]] && distro='gentoo'
  else
      distro='non linux'
      return 1
  fi
  #
  echo $distro 
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function distro_release 
{
  ## Briefs: 
  ##   - DE: zeigt Zahlen fur Dur, Moll und Patch der Distro
  ##   - EN: displays numbers major, minor and patch of the distro
  ##   - ES: muestra los números mayores, menores y el parche de la distribución
  ##   - FR: affiche les numéros majeur, mineur et le patch de la distribution 
  ##   - IT: visualizza i numeri maggiori, minori e la patch della distribuzione
  ## Returns:
  ##   - stdout: major, minor, patch release numbers 
  ## Tests: 
  ##   - ut: assert -la -c 'distro_release'
  ## Usages: distro_release
  ## Comments: |
  ##
  local distro_name=$1 
  local regex="release ([0-9]+)\.([0-9]+)\.([0-9]+).*"
  local major minor patch
  #
  case $distro_name in
       redhat)    release=$(cat /etc/redhat-release )     ;;
       fedora)    release=$(cat /etc/fedora-release )     ;;
       centos)    release=$(cat /etc/fedora-release )     ;;
       slackware) release=$(cat /etc/slackware-release )  ;;
       debian)    release=$(cat /etc/debian_release    )  ;;
       mandrake)  release=$(cat /etc/mandrake-release  )  ;;
       yellowdog) release=$(cat /etc/yellowdog-release )  ;;
       gentoo)    release=$(cat /etc/gentoo-release    )  ;;
       *)         return 1
  esac
  #
  [[ $release =~ $regex ]] 
  major=${BASH_REMATCH[1]} 
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  echo $major $minor $patch
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function distro_codename 
{
  ## Briefs: 
  ##   - DE: zeigt den Codenamen der Verteilung
  ##   - EN: display distro codename
  ##   - ES: muestra la distribución de código
  ##   - FR: affiche le code de la distribution 
  ##   - IT: visualizza il codice di distribuzione
  ## Returns:
  ##   - stdout: release code_name
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: assert -la -r0  -c 'distro_codename'
  ## Usages: distro_release
  ## Comments: |
  ##
  local distro_name=$1 
  local regex="\((.*)\)"
  local code_name
  # 
  case $distro_name in
       redhat)    release=$(cat /etc/redhat-release )     ;;
       fedora)    release=$(cat /etc/fedora-release )     ;;
       centos)    release=$(cat /etc/fedora-release )     ;;
       slackware) release=$(cat /etc/slackware-release )  ;;
       debian)    release=$(cat /etc/debian_release    )  ;;
       mandrake)  release=$(cat /etc/mandrake-release  )  ;;
       yellowdog) release=$(cat /etc/yellowdog-release )  ;;
       gentoo)    release=$(cat /etc/gentoo-release    )  ;;
       *)         return 1
  esac
  #
  [[ $release =~ $regex ]] 
  code_name=${BASH_REMATCH[1]} 
  echo $code_name	   
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function distro_arch 
{
  ## Briefs: 
  ##   - DE: zeigt die Kernel-Architektur
  ##   - EN: displays the kernel architecture
  ##   - ES: muestra la arquitectura del núcleo
  ##   - FR: affiche l'architecture du noyau 
  ##   - IT: mostra l'architettura del kernel
  ## Returns:
  ##   - stdout: architecture
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: assert -la -r0  -c 'distro_arch'
  ## Usages: distro_arch
  ## Comments: |
  ##
  echo $(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
  return $?
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function distro_kernelversion
{
  ## Briefs: 
  ##   - DE: zeigt die Kernel-Versionsnummer
  ##   - EN: displays the kernel version number
  ##   - ES: muestra el número de versión del kernel
  ##   - FR: affiche le numéro de version du noyau 
  ##   - IT: visualizza il numero di versione del kernel
  ## Returns:
  ##   - stdout: version
  ## Usages: distro_kernelversion
  ## Comments: |
  ##
  echo $(uname -r)
  return $?
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - EN: Main programm, tests processing
##   - ES: Programa principal, tratamiento de los juegos de pruebas
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: Programma principale, trattamento di test gioco
## Usages: |
##   distro.sh -ut <function_name> run tests of this function_name
##   distro.sh -ut                 run tests of all library functions
## Comments: |
##
[[ ${LOGGER_SH++} ]] || source logger.sh
[[ ${ASSERT_SH++} ]] || source assert.sh
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
DISTRO_SH=true
#--------1---------2---------3---------4---------5---------6---------7---------8

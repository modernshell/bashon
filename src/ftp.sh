#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : ftp
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_connect
{
  ## Briefs:
  ##   - DE: prüft die Verbindung zum FTP-Server
  ##   - EN: checks the connection to FTP server
  ##   - ES: prueba la conexión al servidor FTP
  ##   - FR: vérifie la connexion au serveur FTP
  ##   - IT: controlla il collegamento al server FTP
  ## Parameters:
  ##   -  h: hostname
  ## Returns:
  ##   - stdout: banner message
  ##   - logger: banner message
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1 }
  ## Tests:
  ##   #  a: connected
  ##   - ut: assert -l a -r0   -c"ftp_connect -h $H"
  ##   #  b: ERROR BAD hostname
  ##   - ut: assert -l b -r1   -c"ftp_connect -h BAD"
  ##   #  c: ERROR value required to option
  ##   - ut: assert -l c -r254 -c"ftp_connect -h"
  ##   #  d: ERROR invalid option 
  ##   - ut: assert -l d -r255 -c"ftp_connect -z $H"
  ## Usages: ftp_connect -h <host>
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
  local rc err
  # Reads function arguments
  while getopts ":h:" option 
  do
     case ${option} in
       h) local -r host="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} ]];then
      rc=253; err="mandatory value required "
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  local ftp_out=$(mktemp)  
  $_ftp -n -v < <(  echo "open  ${host}"
                    echo "bye"  )> ${ftp_out}
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  else 
      rc=0
      local banner1=$(awk '!/^[1-9]/{print $0;}' $ftp_out | head -1 )
      $_logger INFO  "$(eval $_msg_log);banner:$banner1"
  fi
  test -e $ftp_out && rm $ftp_out
  #
  return $rc 
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_logged
{
  ## Briefs:
  ##   - DE: prüft den Benutzerzugriff auf FTP-Server
  ##   - EN: checks user access to FTP server
  ##   - ES: prueba el usuario tiene acceso al servidor FTP
  ##   - FR: vérifie l'access de l'utilisateur au serveur FTP
  ##   - IT: controlli di accesso utente al server FTP
  ## Parameters:
  ##   -  h: hostname
  ##   -  u: username
  ##   -  p: password
  ## Returns:
  ##   - logger: INFO & head of welcome message
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1, 2 }
  ## Tests:
  ##   #  a: user logged to host
  ##   - ut: assert -la -r0   -c"ftp_logged -h $H  -u $U  -p $P"
  ##   #  b: ERROR user not logged BAD hostname
  ##   - ut: assert -lb -r1   -c"ftp_logged -h BAD -u $U  -p $P"
  ##   #  c: ERROR user not logged BAD username
  ##   - ut: assert -lc -r2   -c"ftp_logged -h $H  -u BAD -p $P"
  ##   #  d: ERROR user not logged BAD password
  ##   - ut: assert -ld -r2   -c"ftp_logged -h $H  -u $U  -p BAD"
  ##   #  e: ERROR option needs argument
  ##   - ut: assert -le -r253 -c"ftp_logged -h $H"
  ##   #  f: ERROR mandatory value missed
  ##   - ut: assert -lf -r254 -c"ftp_logged -h $H  -u "
  ##   #  g: ERROR invalid option 
  ##   - ut: assert -lg -r255 -c"ftp_logged -z $H"
  ## Usages:  ftp_connect -h <host> -u <user> -p <pass>
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
  local rc err
  # Reads function arguments
  while getopts ":h:u:p:" option 
  do
     case ${option} in
       h) local -r host="$OPTARG" ;;
       u) local -r user="$OPTARG" ;;
       p) local -r pass="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} && ${user++} && ${pass++} ]];then
      rc=253; err="mandatory value required "
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  local ftp_out=$(mktemp)  
  $_ftp -n -v < <(  echo "open  ${host}"
                    echo "user  ${user} ${pass}"
                    echo "pwd"
                    echo "close"
                    echo "bye"  )> ${ftp_out}
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^230 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not logged
      rc=2; err="user not logged, bad user or passwd"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^257 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR other
      rc=3; err=$(grep -E "^[45][0-9]{2}" $ftp_out | tr '\n' ';' )
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  else 
      # OK, pwd command performed
      rc=0
      local welcome1=$(awk '!/^[1-9]/{print $0;}' $ftp_out | head -1 )
      $_logger INFO  "$(eval $_msg_log);banner:$welcome1"
  fi
  test -e $ftp_out && rm $ftp_out
  #
  return $rc 
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_dir
{
  ## Briefs:
  ##   - DE: listet der Remote-Verzeichnis
  ##   - EN: lists the remote directories
  ##   - ES: lista los directorios remotos
  ##   - FR: liste les répertoires distants
  ##   - IT: elenca directory remote
  ## Parameters:
  ##   -  h: hostname
  ##   -  u: username
  ##   -  p: password
  ##   -  r: remote directory
  ## Returns:
  ##   - stdout: listing
  ##   - logger: cmd traces
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1, 2, 3, 4 }
  ## Tests:
  ##   #  a: list remote directory
  ##   - ut: assert -la -r0 -c"ftp_dir -h$H -u$U -p$P -r$RO"
  ##   #  b: ERROR bad remote directory
  ##   - ut: assert -lb -r4 -c"ftp_dir -h$H -u$U -p$P -rBAD"
  ## Usages: ftp_nlist -h <host> -u <user> -p <pass> -r <rdir>
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
  local rc err
  # Reads function arguments
  while getopts ":h:u:p:r:" option
  do
     case "${option}" in
       h) local -r host="$OPTARG" ;;
       u) local -r user="$OPTARG" ;;
       p) local -r pass="$OPTARG" ;;
       r) local -r rdir="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} && ${user++} && ${pass++} && ${rdir++} ]];then
      rc=253; err="required mandatory option"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  local ftp_out=$(mktemp)  
  $_ftp -n -v < <( echo "open  $host"
                   echo "user  $user $pass"
                   echo "cd    $rdir"
                   echo "dir"
                   echo "close"
                   echo "bye"  )> $ftp_out
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^230 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not logged
      rc=2; err="user not logged, bad user or passwd"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^250 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR CWD command failure
      rc=4; err="CWD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err};"
  elif [[ $(grep -q ^226 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not all OK
      rc=3; err=$(grep -E "^[45][0-9]{2}" $ftp_out | tr '\n' ';' )
      $_logger ERROR "$(eval $_msg_log);err:${err};"
  else 
      # then all OK
      rc=0
      $_logger INFO  "$(eval $_msg_log);"
      while read -r dir_line
      do
          $_logger INFO  "fnt:${FUNCNAME};raw:$dir_line"
          echo $dir_line
      done < <(awk '/^[d-][r]/{print $0;}' $ftp_out)
  fi
  test -e $ftp_out && rm $ftp_out
  #
  return $rc
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_nlist
{
  ## Briefs:
  ##   - DE: listet die Einträgenammen der Remote-Verzeichnis
  ##   - EN: lists the filenames of the remote directory
  ##   - ES: lista los nombres del archivos del directorio remoto
  ##   - FR: liste les noms de fichier du répertoire distant
  ##   - IT: elenca i nomi dei file della directory remota
  ## Parameters:
  ##   -  h: hostname
  ##   -  u: username
  ##   -  p: password
  ##   -  r: remote directory, OPTIONAL
  ## Returns:
  ##   - stdout: listing
  ##   - logger: cmd traces
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1, 2, 3, 4 }
  ## Tests:
  ##   #  a: list remote directory
  ##   - ut: assert -la -r0 -c"ftp_nlist -h $H -u $U -p $P -r $RO"
  ##   #  b: ERROR bad remote directory
  ##   - ut: assert -lb -r4 -c"ftp_nlist -h $H -u $U -p $P -r BAD"
  ## Usages: ftp_nlist -h <host> -u <user> -p <pass> [-r <rdir>]
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
  local rc err
  # Reads function arguments
  while getopts ":h:u:p:r:" option
  do
     case "${option}" in
       h) local -r host="$OPTARG" ;;
       u) local -r user="$OPTARG" ;;
       p) local -r pass="$OPTARG" ;;
       r) local -r rdir="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} && ${user++} && ${pass++} ]];then
      rc=253; err="required mandatory option"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  local ftp_out=$(mktemp)  
  $_ftp -n -v  < <(  echo "open  $host"
                     echo "user  $user $pass"
  [[ ${rdir++} ]] && echo "cd    $rdir"
                     echo "nlist"
                     echo "close"
                     echo "bye"  )> $ftp_out
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^230 $ftp_out ;echo $?) -ne 0 ]];then
      # not logged
      rc=2; err="user not logged, bad user or passwd"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${rdir++} && $(grep -q ^250 $ftp_out ;echo $?) -ne 0 ]];then
      # no CWD command successful (to remote directory)
      rc=4; err="CWD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^226 $ftp_out ;echo $?) -ne 0 ]];then
      # not all OK
      rc=3; err=$(grep -E "^[45][0-9]{2}" $ftp_out | tr '\n' ';' )
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  else 
      # all OK
      rc=0
      $_logger INFO  "$(eval $_msg_log);"
      while read -r list_line
      do
          $_logger INFO  "fnt:${FUNCNAME};file:$list_line"
      done < <(awk '/^125/,/^226/' $ftp_out | head -n -1 | tail -n +2 )
  fi
  test -e $ftp_out && rm $ftp_out
  #
  return $rc
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_get
{
  ## Briefs:
  ##   - DE: erhalten eine Datei vom FTP-Server
  ##   - EN: get one file from the remote FTP server
  ##   - ES: tome un archivo del servidor FTP remoto
  ##   - FR: obtenir un fichier du serveur FTP distant
  ##   - IT: ottenere un file dal server FTP remoto
  ## Parameters:
  ##   -  h: hostname
  ##   -  u: username
  ##   -  p: password
  ##   -  l: local  directory, OPTIONAL
  ##   -  r: remote directory, OPTIONAL
  ##   -  f: remote filename
  ## Returns:
  ##   - logger: traces
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1, 2, 3, 4, 5 }
  ## Tests:
  ##   #  a: get file from remote-dir
  ##   - ut: assert -la -r0 -c'ftp_get -h$H -u$U -p$P       -r$RO -f$FR'
  ##   #  b: get file from remote-dir to localname
  ##   - ut: assert -lb -r0 -c'ftp_get -h$H -u$U -p$P       -r$RO -f"$FR $FL"'
  ##   #  c: get file from remote-dir to local-dir
  ##   - ut: assert -lc -r0 -c'ftp_get -h$H -u$U -p$P -l$LI -r$RO -f$FR'
  ##   #  d: get file from remote-dir to local-dir, localname
  ##   - ut: assert -ld -r0 -c'ftp_get -h$H -u$U -p$P -l$LI -r$RO -f"$FR $FL"'
  ##   #  e: ERROR Bad local directory
  ##   - ut: assert -le -r5 -c'ftp_get -h$H -u$U -p$P -lBAD -r$RO -f$FR'
  ##   #  f: ERROR Bad remote directory
  ##   - ut: assert -lf -r4 -c'ftp_get -h$H -u$U -p$P -l$LI -rBAD -f$FR'
  ##   #  g: ERROR Bad remote filename
  ##   - ut: assert -lg -r3 -c'ftp_get -h$H -u$U -p$P -l$LI -r$RO -fBAD'
  ## Usage: |
  ##   ftp_get -h <host> -u <user> -p <pass> [-l <ldir>] [-r <rdir>] -f <file>
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
  # Reads function arguments
  while getopts ":h:u:p:l:r:f:" option
  do
     case "${option}" in
       h) local -r host="$OPTARG" ;;
       u) local -r user="$OPTARG" ;;
       p) local -r pass="$OPTARG" ;;
       l) local -r ldir="$OPTARG" ;;
       r) local -r rdir="$OPTARG" ;;
       f) local -r file="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} && ${user++} && ${pass++} && ${file++} ]];then
      rc=253; err="required mandatory option"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  local ftp_out=$(mktemp)  
  $_ftp -n -v   < <( echo "open $host"
                     echo "user $user $pass"
  [[ ${ldir++} ]] && echo "lcd  $ldir"
  [[ ${rdir++} ]] && echo "cd   $rdir"
                     echo "sunique on"
                     echo "get  $file"
                     echo "close"
                     echo "bye" )> $ftp_out
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^230 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR not logged
      rc=2; err="user not logged, bad user or passwd"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${ldir++} && \
          $(grep -q '^Local directory now ' $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no LCD to local directory)
      rc=5; err="LCD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${rdir++} && \
          $(grep -q ^250 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no CWD command successful code 250 (to remote directory)
      rc=4; err="CWD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^226 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR others
      rc=3; err=$(grep -E "^[45][0-9]{2}" $ftp_out | tr '\n' ';' )
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  else 
      # OK, pwd command performed
      rc=0
      local get=$(grep received  $ftp_out)
      $_logger INFO  "$(eval $_msg_log);get:$get"
  fi
  #
  test -e $ftp_out && rm $ftp_out
  return $rc
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_put
{
  ## Briefs:
  ##   - DE: erhalten eine Datei vom FTP-Server 
  ##   - EN: put one file to the remote FTP server
  ##   - ES: pone un archivo al servidor FTP remoto
  ##   - FR: dépose un fichier sur le serveur FTP distant
  ##   - IT: mettere un file sul server FTP remoto
  ## Parameters:
  ##   -  h: hostname
  ##   -  u: username
  ##   -  p: password
  ##   -  l: local  directory, OPTIONAL
  ##   -  r: remote directory, OPTIONAL
  ##   -  f: remote filename
  ## Returns:
  ##   - logger: traces
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1, 2, 3, 4, 5 }
  ## Tests:
  ##   #  a: put file to remote dir
  ##   - ut: assert -la -r0 -c'ftp_put -h$H -u$U -p$P       -r$RI -f$FL'
  ##   #  b: put file to remote dir
  ##   - ut: assert -lb -r0 -c'ftp_put -h$H -u$U -p$P       -r$RI -f"$FL $FR"'
  ##   #  c: put file from local dir to remote dir 
  ##   - ut: assert -lc -r0 -c'ftp_put -h$H -u$U -p$P -l$LO -r$RI -f$FL'
  ##   #  d: put from-local dir to-remote dir, file:localname to remotename
  ##   - ut: assert -ld -r0 -c'ftp_put -h$H -u$U -p$P -l$LO -r$RI -f"$FL $FR"'
  ##   #  e: ERROR Bad local directory
  ##   - ut: assert -le -r5 -c'ftp_put -h$H -u$U -p$P -lBAD -r$RI -f$FL'
  ##   #  f: ERROR Bad remote directory
  ##   - ut: assert -lf -r4 -c'ftp_put -h$H -u$U -p$P -l$LO -rBAD -f$FL'
  ##   #  g: ERROR Bad remote filename
  ##   - ut: assert -lg -r3 -c'ftp_put -h$H -u$U -p$P -l$LO -r$RI -fBAD'
  ## Usage: |
  ##   ftp_put -h <host> -u <user> -p <pass> [-l <ldir>] [-r <rdir>] -f <file>
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
  # Reads function arguments
  while getopts ":h:u:p:l:r:f:" option
  do
     case "${option}" in
       h) local -r host="$OPTARG" ;;
       u) local -r user="$OPTARG" ;;
       p) local -r pass="$OPTARG" ;;
       l) local -r ldir="$OPTARG" ;;
       r) local -r rdir="$OPTARG" ;;
       f) local -r file="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} && ${user++} && ${pass++} && ${file++} ]];then
      rc=253; err="required mandatory option"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  local ftp_out=$(mktemp)
  $_ftp -n -v   < <( echo "open $host"
                     echo "user $user $pass"
  [[ ${ldir++} ]] && echo "lcd  $ldir"
  [[ ${rdir++} ]] && echo "cd   $rdir"
                     echo "runique on"
                     echo "put  $file"
                     echo "close"
                     echo "bye" )> $ftp_out
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^230 $ftp_out ;echo $?) -ne 0 ]];then
      # not logged
      rc=2; err="user not logged, bad user or passwd"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${ldir++} && \
          $(grep -q '^Local directory now ' $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no LCD to local directory)
      rc=5; err="LCD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${rdir++} && \
          $(grep -q ^250 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no CWD command successful code 250 (to remote directory)
      rc=4; err="CWD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^226 $ftp_out ;echo $?) -ne 0 ]];then
      # not all OK
      rc=3; err=$(grep -E "^[45][0-9]{2}" $ftp_out | tr '\n' ';' )
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  else 
      # OK, pwd command performed
      rc=0
      local put=$(grep sent $ftp_out)
      $_logger INFO  "$(eval $_msg_log);put:$put"
  fi
  #
  test -e $ftp_out && rm $ftp_out
  return $rc
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_mget
{
  ## Briefs:
  ##   - DE: erhält mehrere Dateien vom FTP-Server 
  ##   - EN: gets multiple files from the remote FTP server
  ##   - ES: tome múltiples archivos del servidor FTP remoto
  ##   - FR: obtient plusieurs fichiers du serveur FTP distant
  ##   - IT: ottiene più file dal server FTP remoto
  ## Parameters:
  ##   -  h: hostname
  ##   -  u: username
  ##   -  p: password
  ##   -  l: local  directory,  OPTIONAL
  ##   -  r: remote directory,  OPTIONAL
  ##   -  f: remote files pattern
  ## Returns:
  ##   - logger: traces
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1, 2, 3, 4, 5 }
  ## Tests:
  ##   #  a: get files from remote-dir
  ##   - ut: assert -la -r0 -c'ftp_mget -h$H -u$U -p$P       -r$RO -f$MR'
  ##   #  b: get files from remote-dir to localname
  ##   - ut: assert -lb -r0 -c'ftp_mget -h$H -u$U -p$P       -r$RO -f$MR'
  ##   #  c: get files from remote-dir to local-dir
  ##   - ut: assert -lc -r0 -c'ftp_mget -h$H -u$U -p$P -l$LI -r$RO -f$MR'
  ##   #  d: ERROR Bad local directory
  ##   - ut: assert -ld -r5 -c'ftp_mget -h$H -u$U -p$P -lBAD -r$RO -f$MR'
  ##   #  e: ERROR Bad remote directory
  ##   - ut: assert -le -r4 -c'ftp_mget -h$H -u$U -p$P -l$LI -rBAD -f$MR'
  ##   #  f: ERROR Bad remote filename
  ##   - ut: assert -lf -r3 -c'ftp_mget -h$H -u$U -p$P -l$LI -r$RO -fBAD'
  ## Usage: |
  ##   ftp_mget -h <host> -u <user> -p <pass> [-l <ldir>] [-r <rdir>] -f <file>
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
  # Reads function arguments
  set -f
  while getopts ":h:u:p:l:r:f:" option
  do
     case "${option}" in
       h) local -r host="$OPTARG" ;;
       u) local -r user="$OPTARG" ;;
       p) local -r pass="$OPTARG" ;;
       l) local -r ldir="$OPTARG" ;;
       r) local -r rdir="$OPTARG" ;;
       f) local -r file="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  set +f
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} && ${user++} && ${pass++} && ${file++} ]];then
      rc=253; err="required mandatory option"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  set -f
  local ftp_out=$(mktemp)  
  $_ftp -niv    < <( echo "open $host"
                     echo "user $user $pass"
  [[ ${ldir++} ]] && echo "lcd  $ldir"
  [[ ${rdir++} ]] && echo "cd   $rdir"
                     echo "mget $file"
                     echo "close"
                     echo "bye" )> $ftp_out
  set +f
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^230 $ftp_out ;echo $?) -ne 0 ]];then
      # not logged
      rc=2; err="user not logged, bad user or passwd"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${ldir++} && \
          $(grep -q '^Local directory now ' $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no LCD to local directory)
      rc=5; err="LCD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${rdir++} && \
          $(grep -q ^250 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no CWD command successful code 250 (to remote directory)
      rc=4; err="CWD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^226 $ftp_out ;echo $?) -ne 0 ]];then
      # not all OK
      rc=3; err=$(grep -E "^[45][0-9]{2}" $ftp_out | tr '\n' ';' )
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  else 
      # OK, pwd command performed
      rc=0
      $_logger INFO  "fnt:${FUNCNAME};arg:${args}"
      local count=1
      set -f
      while read ftp_line
      do 
          [[ $count == 1 ]] && file=$ftp_line
          [[ $count == 2 ]] && stat=$ftp_line
          [[ $count == 3 ]] && count=1
           $_logger INFO "fnt:${FUNCNAME};file:$file;stat:$stat"
          count=$(($count+1));
      done < <(grep -E "local: $file|received" $ftp_out)
      set +f
  fi
  #
  test -e $ftp_out && rm $ftp_out
  return $rc
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function ftp_mput
{
  ## Briefs:
  ##   - DE: legt mehrere Dateien auf den FTP-Server 
  ##   - EN: puts multiples file to the remote FTP server
  ##   - ES: pone múltiples archivo(s) al servidor FTP remoto
  ##   - FR: dépose plusieurs fichiers sur le serveur FTP distant
  ##   - IT: mette più file al server FTP remoto
  ## Parameters:
  ##   -  h: hostname
  ##   -  u: username
  ##   -  p: password
  ##   -  l: local directory,  OPTIONAL
  ##   -  r: remote directory, OPTIONAL
  ##   -  f: remote files pattern
  ## Returns:
  ##   - logger: traces
  ##   - rc: { ok: 0, ko: 253, 254, 255, 1, 2, 3, 4, 5 }
  ## Tests:
  ##   #  a: put files to remote dir
  ##   - ut: assert -la -r0 -c'ftp_put -h$H -u$U -p$P       -r$RI -f$ML'
  ##   #  b: put files to remote dir
  ##   - ut: assert -lb -r0 -c'ftp_put -h$H -u$U -p$P       -r$RI -f$ML'
  ##   #  c: put files from local dir to remote dir 
  ##   - ut: assert -lc -r0 -c'ftp_put -h$H -u$U -p$P -l$LO -r$RI -f$ML'
  ##   #  d: ERROR Bad local directory
  ##   - ut: assert -ld -r5 -c'ftp_put -h$H -u$U -p$P -lBAD -r$RI -f$ML'
  ##   #  e: ERROR Bad remote directory
  ##   - ut: assert -le -r4 -c'ftp_put -h$H -u$U -p$P -l$LO -rBAD -f$ML'
  ##   #  f: ERROR Bad remote filename
  ##   - ut: assert -lf -r3 -c'ftp_put -h$H -u$U -p$P -l$LO -r$RI -fBAD'
  ## Usage: |
  ##   ftp_mput -h <host> -u <user> -p <pass> [-l <ldir>] [-r <rdir>] -f <file>
  ## Comments: |
  ##
  local OPTIND
  local args="$@"
 # Reads function arguments
  set -f
  while getopts ":h:u:p:l:r:f:" option
  do
     case "${option}" in
       h) local -r host="$OPTARG" ;;
       u) local -r user="$OPTARG" ;;
       p) local -r pass="$OPTARG" ;;
       l) local -r ldir="$OPTARG" ;;
       r) local -r rdir="$OPTARG" ;;
       f) local -r file="$OPTARG" ;;
      \?) rc=255; err="invalid option -$OPTARG"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
       :) rc=254; err="option -$OPTARG needs argument"
          $_logger ERROR "$(eval $_msg_log);err:${err}"
          return $rc ;;
     esac
  done
  set +f
  shift $((OPTIND-1))
  # Checks mandatory args
  if ! [[ ${host++} && ${user++} && ${pass++} && ${file++} ]];then
      rc=253; err="required mandatory option"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
      return $rc
  fi
  # Runs FTP commands
  set -f
  local ftp_out=$(mktemp)  
  $_ftp -niv   < <( echo "open $host"
                    echo "user $user $pass"
  [[ -v $ldir ]] && echo "lcd  $ldir"
  [[ -v $rdir ]] && echo "cd   $rdir"
                    echo "runique on"
                    echo "mput $file"
                    echo "close"
                    echo "bye" )> $ftp_out
  set +f
  # Checks FTP codes
  if   [[ $(grep -q ^220 $ftp_out ;echo $?) -ne 0 ]];then
      # not connected
      rc=1; err="serveur not connected"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^230 $ftp_out ;echo $?) -ne 0 ]];then
      # not logged
      rc=2; err="user not logged, bad user or passwd"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${ldir++} && \
          $(grep -q '^Local directory now ' $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no LCD to local directory)
      rc=5; err="LCD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ ${rdir++} && \
          $(grep -q ^250 $ftp_out ;echo $?) -ne 0 ]];then
      # ERROR no CWD command successful code 250 (to remote directory)
      rc=4; err="CWD command failure"
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  elif [[ $(grep -q ^226 $ftp_out ;echo $?) -ne 0 ]];then
      # not all OK
      rc=3; err=$(grep -E "^[45][0-9]{2}" $ftp_out | tr '\n' ';' )
      $_logger ERROR "$(eval $_msg_log);err:${err}"
  else 
      # OK, pwd command performed
      rc=0
      $_logger INFO  "fnt:${FUNCNAME};arg:${args}"
      local count=1
      set -f
      while read ftp_line
      do 
          [[ $count == 1 ]] && file=$ftp_line
          [[ $count == 2 ]] && stat=$ftp_line
          [[ $count == 3 ]] && count=1
           $_logger INFO "fnt:${FUNCNAME};file:$file;stat:$stat"
          count=$(($count+1));
      done < <(grep -E "local: $file|sent" $ftp_out)
      set +f
  fi
  #
  test -e $ftp_out && rm $ftp_out
  return $rc
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - EN: Main programm, tests processing
##   - ES: Programa principal, tratamiento de pruebas
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: Programma principale, trattamento di test gioco
## Usages: |
##   ftp.sh -ut <function_name> run tests of this function_name
##   ftp.sh -ut                 run tests of all library functions
## Comments: |
##
_msg_loc="fnt:${FUNCNAME};num:${BASH_LINENO}"
_msg_log="fnt:${FUNCNAME};num:${BASH_LINENO};arg:${args};rc:${rc}"
#
data=$(sed '0,/^__DATA__$/d' "$0")
eval "$data"
[[ ${ASSERT_SH++} ]] || source assert.sh
[[ ${LOGGER_SH++} ]] || source logger.sh
_ftp=$(which ftp)    || exit 2
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
FTP_SH=true
exit
#--------1---------2---------3---------4---------5---------6---------7---------8
# my tests data
__DATA__
H='towertwo'
U='test'
P='test'
LI='/var/ftp/in'
LO='/var/ftp/out'
RI='in'
RO='out'
FR='f1'
FL='l1'
MR='f*'
ML='l*'

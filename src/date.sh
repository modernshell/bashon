#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : date
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_e2dt
{
  ## Briefs:
  ##   - DE: wandelt Epoche zu Datetime (Sekunden vom 01-01-1970 bis heute)
  ##   - EN: converts epoch to datetime (seconds from 01-01-1970 to date)
  ##   - ES: convierte un número de segundos despachada después 01-01-1970 en fecha
  ##   - FR: convertit un nombre de secondes écoulée depuis 01-01-1970 en date
  ##   - IT: converte un numero di secondi dal 01-01-1970 datato
  ## Parameters:
  ##   - $1: seconds since 01-01-1970
  ##   - $2: date format (iso8601 rfc2822 rfc3339)
  ## Returns:
  ##   - stdout: datetime
  ## Tests:
  ##   #  a: epoch to date (default format)
  ##   - ut: assert -la -c'date_e2dt 1234567890' -r0 -o 'Fri Feb 13 23:31:30 UTC 2009'
  ##   #  b: epoch to date (rfc-2822 format)
  ##   - ut: assert -lb -c'date_e2dt 1234567890 --rfc-2822' -r0 -o 'Fri, 13 Feb 2009 23:31:30 +0000'
  ##   #  c: epoch to date (rfc-3339 format)
  ##   - ut: assert -lc -c'date_e2dt 1234567890 --rfc-3339=sec' -r0 -o '2009-02-13 23:31:30+00:00'
  ##   #  d: epoch to date (iso-8601 format)
  ##   - ut: assert -ld -c'date_e2dt 1234567890 --iso-8601=sec' -r0 -o '2009-02-13T23:31:30+0000'
  ##   #  e: epoch to date (Zulu format)
  ##   - ut: assert -le -c'date_e2dt 1234567890 "+%Y%m%dT%H%M%SZ"' -r0 -o '20090213T233130Z'
  ##   #  f: ERROR  invalid input epoch
  ##   - ut: assert -lf -c'date_e2dt "zorglub"  "+%Y%m%dT%H%M%SZ"' -r1 
  ##   #  g: ERROR  invalid input epoch
  ##   - ut: assert -lg -c'date_e2dt "30:00" "+%Y%m%dT%H%M%SZ"' -r1 
  ## Usages: date_e2dt <epoch> <output-date-format>
  ## Comments: |
  ##
  local epoch=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing epoch;"}
  local shape=$2
  #
  if [[ ! $epoch =~ ^[0-9]+$ ]];then
      $_logger ERROR "$(eval $_msg_log);err:integer expected" 
      return 1
  fi
  #
  local datetime=$(date -u --date @${epoch} $shape)
  if [[ $? -eq "0" ]];then
      echo "$datetime" 
      return 0
  else
      $_logger ERROR "$(eval $_msg_log);$datetime" 
      return 1
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_dt2e
{
  ## Briefs:
  ##   - DE: wandelt Datetime in Sekunden seit dem 01-01-1970
  ##   - EN: converts datetime to seconds since 01-01-1970
  ##   - ES: convierte una fecha en segundos despachados desde el 01-01-1970
  ##   - FR: convertit une date en secondes écoulées depuis le 01-01-1970
  ##   - IT: converte una data in secondi dal 01-01-1970
  ## Parameters:
  ##   - $1: datetime
  ## Returns:
  ##   - stdout: epoch
  ## Tests:
  ##   #  a: date Zulu to epoch
  ##   - ut: assert -la -c'date_dt2e "2009-02-13T23:31:30Z"' -r0 -o '1234567890'
  ##   #  b: date to epoch
  ##   - ut: assert -lb -c'date_dt2e "2009-02-13 23:31:30"' -r0 -o '1234567890'
  ##   #  c: date to epoch
  ##   - ut: assert -lc -c'date_dt2e "2009-02-13 23:31:30-00:00"' -r0 -o '1234567890'
  ##   #  d: ERROR invalid date to epoch
  ##   - ut: assert_g -ld -c'date_dt2e foo' -r1 -e 'date: invalid date' 
  ##   #  e: ERROR invalid date to epoch
  ##   - ut: assert -le -c'date_dt2e foo' -r1 
  ##   #  f: date to epoch
  ##   - ut: assert -lf -c'date_dt2e "20090213T233130Z"' -r0 -o '1234567890'
  ## Usages: date_dt2e <date>
  ## Comments: |
  ##
  #
  local dt=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing datetime;"}
  local epoch
  # gnu date deals only with extended datetime format (with separators)
  if [[ $dt =~ ([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{2})Z ]]
  then
      local  Years=${BASH_REMATCH[1]}
      local months=${BASH_REMATCH[2]}
      local   days=${BASH_REMATCH[3]}
      local  Hours=${BASH_REMATCH[4]}
      local    Min=${BASH_REMATCH[5]}
      local    Sec=${BASH_REMATCH[6]}
      dt=$(printf "%s-%s-%sT%s:%s:%s%s" \
             $Years $months $days $Hours $Min $Sec)
  fi
  #
  set -o pipefail
  epoch=$( date -ud "$datetime" "+%s" 2>&1 | tee /dev/stderr )
  rc=$? 
  set +o pipefail
  #
  if [ $rc -eq "0" ];then
      echo "$epoch" 
      return 0
  else
      $_logger ERROR "$(eval $_msg_log);epoch:$epoch;" 
      return 1
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_add
{
  ## Briefs:
  ##   - DE: fügt einen Zeitraum, um ein Datum
  ##   - EN: adds a period to a date
  ##   - ES: añade un periode tiene una fecha
  ##   - FR: ajoute une periode a une date
  ##   - IT: aggiunge un periodo ad una data
  ## Parameters:
  ##   - $1: period
  ##   - $2: datetime
  ## Returns:
  ##   - stdout: datetime
  ## Tests:
  ##   #   : add period to date
  ##   - ut: assert -la -c 'date_add "+30 minutes" "2000-01-01T00:00"' -r 0 -o '20000101T003000Z'
  ##   - ut: assert -lb -c 'date_add "+3 hours"    "2000-01-01T00:00"' -r 0 -o '20000101T030000Z'
  ##   - ut: assert -lc -c 'date_add "+2 days"     "2000/01/01 00:00"' -r 0 -o '20000103T000000Z'
  ##   - ut: assert -ld -c 'date_add "+2 months"   "2000/01/01 00:00"' -r 0 -o '20000301T000000Z'
  ##   - ut: assert -le -c 'date_add "+1 years"    "2000/01/01 00:00"' -r 0 -o '20010101T000000Z'
  ## Usages: date_add <period> <datetime>
  ## Comments: |
  ##
  local period=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing period;"}
  local date_from=$(date -ud "${2:-}")
  #
  local datetime=$(TZ="UTC" date '+%Y%m%dT%H%M%SZ' -d "$date_from $period" 2>&1)
  if [[ $? -eq 0 ]];then
       echo "$datetime"
       return 0
  else
       $_logger ERROR "$(eval $_msg_log);$datetime"
       return 1
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_zulu
{
  ## Briefs:
  ##   - DE: wandelt eine lokale Datum (ISO8601/RFC3339) nach Format (UTC/Zulu)
  ##   - EN: converts (iso8601/rfc3339) local-date to (UTC/Zulu) format
  ##   - ES: converte una fecha local (iso8601/rfc3339) en el formato (UTC/Zulu)
  ##   - FR: convertir une date locale (iso8601/rfc3339) au format (UTC/Zulu)
  ##   - IT: converte una data locale (iso8601/rfc3339) al formato (UTC/Zulu)
  ## Parameters:
  ##   - $1: datetime
  ## Returns:
  ##   - logger: error
  ##   - stdout: zulu datetime
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests:
  ##   - ut: assert -la -c 'date_zulu "2000-01-01T00:00:00+0300"' -r 0 -o '19991231T210000Z'
  ## Usages: date_zulu <datetime> <datetime_Zulu/UTC>
  ## Comments: |
  ##
  local dt=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing date;"}
  #
  local b='[0-9]{2}' # 2digit
  if [[ "$dt" =~ ^($b$b)-?($b)-?($b)T($b):?($b):?($b)[+-]($b):?($b) ]]
  then
     local zulu=$(date -u -d "$dt" +%Y%m%dT%H%M%SZ)
     #$_logger INFO  "fnt:$FUNCNAME;dt:$dt;zulu:$zulu"
     echo $zulu
     return 0
  else
     $_logger ERROR "$(eval $_msg_log);dt:$dt"
     return 1
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_iso
{
  ## Briefs:
  ##   - DE: prünfen 'iso8601' Datumsformat (ohne Leerzeichen)
  ##   - EN: checks 'iso8601' date format (no space)
  ##   - ES: somete a un test fecha al formato 'iso8601' (sin espacio).
  ##   - FR: teste date au format 'iso8601' (sans espace)
  ##   - IT: controlli data al formato 'iso8601' (senza spazio)  
  ## Description:
  ##   -url: https://en.wikipedia.org/wiki/ISO_8601 
  ## Parameters:
  ##   - $1: datetime
  ## Returns:
  ##   - rc: { ok: 0, ko: 1-7 }
  ## Tests:
  ##   #   : valid iso format
  ##   - ut: assert -la -c 'date_iso "2009-02-13T13:31:30+00:00"' -r 0
  ##   - ut: assert -lb -c 'date_iso "2009-02-13T13:31:30Z"' -r 0
  ##   - ut: assert -lc -c 'date_iso "20090213T235959"' -r 0
  ##   - ut: assert -ld -c 'date_iso "20090213T23:31:30Z"' -r 0
  ##   - ut: assert -le -c 'date_iso "2009-02-13T233130Z"' -r 0
  ##   - ut: assert -lf -c 'date_iso "20090213T233130Z"' -r 0
  ##   #   : ERROR invalid iso format
  ##   - ut: assert -lg -c 'date_iso "Fri Feb 13 23:31:30 UTC 2009"' -r 1
  ##   - ut: assert -lh -c 'date_iso "Fri, 13 Feb 2009 23:31:30 +0000"' -r 1
  ##   - ut: assert -li -c 'date_iso "2009-02-13 23:59:60"' -r 1
  ##   #   : ERROR invalid months number
  ##   - ut: assert -lk -c 'date_iso "20092302T233130Z"' -r 2
  ##   #   : ERROR invalid hours number
  ##   - ut: assert -ll -c 'date_iso "20090213T993130Z"' -r 4
  ## Usages: date_iso <datetime>
  ## Comments: |
  ##
  local dt=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing datetime;"}
  #
  local b='[0-9]{2}' # 2digit
  local iso="($b$b)[-]?($b)[-]?($b)T($b)[:]?($b)[:]?($b)(Z?|[\+\-]$b[:]?$b)"
  #
  if [[ "$dt" =~ $iso ]]
  then
      local parts=(${BASH_REMATCH[@]})
      [[ ${parts[1]} -gt 2100 ]] && $_logger ERROR "fnt:$FUNCNAME;$dt:year"  && return 7 
      [[ ${parts[2]} -gt 12   ]] && $_logger ERROR "fnt:$FUNCNAME;$dt:month" && return 2
      [[ ${parts[3]} -gt 31   ]] && $_logger ERROR "fnt:$FUNCNAME;$dt:day"   && return 3
      [[ ${parts[4]} -gt 23   ]] && $_logger ERROR "fnt:$FUNCNAME;$dt:hour"  && return 4
      [[ ${parts[5]} -gt 59   ]] && $_logger ERROR "fnt:$FUNCNAME;$dt:min"   && return 5
      [[ ${parts[6]} -gt 59   ]] && $_logger ERROR "fnt:$FUNCNAME;$dt:sec"   && return 6
      return 0
  else
      $_logger ERROR "$(eval $_msg_log);dt:$dt;err:not iso8601" 
      return 1
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_tz
{
  ## Briefs:
  ##   - DE: zeigt die Server-Zeitzone
  ##   - EN: displays the server timezone
  ##   - ES: fija el huso horario del servidor
  ##   - FR: affiche le fuseau horaire du serveur
  ##   - IT: affiggi il fuso orario del server  
  ## Returns:
  ##   - stdout: timezone
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests:
  ##   - ut: assert -l '0' -c 'date_tz' -r 0 
  ## Usages: date_tz ()
  ## Comments: |
  ##
  local timezone
  #
  olddir=$PWD
  cd /usr/share/zoneinfo
  timezone=$(find * -maxdepth 1 -type f -exec sh -c \
             "diff -q /etc/localtime '{}' > /dev/null && echo {}" \;)
  local rc=$?
  cd $olddir
  #
  if [[ $rc -eq 0 ]]
  then  
      echo $timezone 
      return 0
  else
      return 1
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_u2tz
{
  ## Briefs:
  ##   - DE: wandelt UTC datetime, um Zeitzone
  ##   - EN: converts UTC datetime to timezone
  ##   - ES: convierte una fecha UTC en fecha local  
  ##   - FR: converti une date UTC en date locale
  ##   - IT: convertite una data UTC in data locale  
  ## Parameters:
  ##   - $1: timezone
  ##   - $2: datetime-iso8601
  ## Returns:
  ##   - stdout: datetime remote tz
  ##   - rc: { ok: 0, bad_date: 1, bad_zone: 2 }
  ## Tests:
  ##   #  a: What time is it at Moscow when UTC is ?
  ##   - ut: assert -la -c'date_u2tz "/Europe/Moscow" "20120101T0700"' -r 0 -o '20120101T0000'
  ##   #  b: Error bad TZ
  ##   - ut: assert -lb -c'date_u2tz "/Mars/Olympus"  "20000101T0000"' -r 2
  ##   #  c: Error bad date
  ##   - ut: assert -lc -c'date_u2tz "/Europe/Minsk"   "????????????"' -r 1
  ## Usages: date_u2tz <TZ> <datetime_UTC>
  ## Comments: |
  ##
  local timezone=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing timezone;"}
  local datetime=${2:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing datetime;"}
  #
  find /usr/share/zoneinfo/$timezone >/dev/null 2>&1 
  if [[ $? -ne 0 ]]; then 
      return 2
  else
      localtime=$(TZ=":$timezone" date -ud "$datetime" +%Y%m%dT%H%M)
      if [[ $? -eq 0 ]]; then 
          echo $localtime 
          return 0
      else
          return 1
      fi
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_diff
{
  ## Briefs:
  ##   - DE: Anzahl der Sekunden zwischen zwei Daten
  ##   - EN: number of seconds between two dates
  ##   - ES: número de segundos entre dos fechas  
  ##   - FR: nombre de secondes entre deux dates
  ##   - IT: numero di secondi tra due date
  ## Parameters:
  ##   - $1: datetime1
  ##   - $2: datetime2
  ## Returns:
  ##   - stdout: datetime1 - datetime2 in second
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests:
  ##   #  a: dates differ of 30 minutes
  ##   - ut: assert -l a -c 'date_diff "20000101T003000Z" "20000101T000000Z"' -r 0 -o "1800"
  ##   #  b: dates differ of  3 hours
  ##   - ut: assert -l b -c 'date_diff "20000101T030000Z" "20000101T000000Z"' -r 0 -o "10800"
  ##   #  c: dates differ of  2 days
  ##   - ut: assert -l c -c 'date_diff "20000103T000000Z" "20000101T000000Z"' -r 0 -o "172800"
  ##   #  d: dates differ of  1 year
  ##   - ut: assert -l d -c 'date_diff "20010101T000000Z" "20000101T000000Z"' -r 0 -o "31622400"
  ## Usages: date_diff <datetime> <datetime>
  ## Comments: |
  ##
  local date1=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing date1;"}
  local date2=${2:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing date2;"}
  #
  local d1_sec=$(date_dt2e "$date1") || return 1
  local d2_sec=$(date_dt2e "$date2") || return 1
  #
  echo $(( d1_sec - d2_sec )) && return 0
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_s2p
{
  ## Briefs:
  ##   - DE: wandelt eine Anzahl von Sekunden in ISO8601 Periode
  ##   - EN: transforms a number of seconds in ISO8601 period
  ##   - ES: transforma una duración en segundos en el período ISO8601
  ##   - FR: transforme une durée en secondes en une periode ISO8601 
  ##   - IT: trasforma una durata in secondi in un periodo ISO8601  
  ## Parameters:
  ##   - $1: secondes
  ## Returns:
  ##   - stdout: periode iso8601  P3Y6M17W3D16TH30M50S
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests:
  ##   #   : test various periods
  ##   - ut: assert -la -r0 -c'date_s2p 12'       -o'PT12S'
  ##   - ut: assert -lb -r0 -c'date_s2p 120'      -o'PT2M'
  ##   - ut: assert -lc -r0 -c'date_s2p 14400'    -o'PT4H'
  ##   - ut: assert -ld -r0 -c'date_s2p 259200'   -o'P3DT'
  ##   - ut: assert -le -r0 -c'date_s2p 12345678' -o'P142DT21H21M18S'
  ## Usages: date_s2p <seconds>
  ## Comments: |
  ##
  local T=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing seconds;"}
  local                                         period+="P"
  local D=$(($T/60/60/24)) && [[ $D -gt 0 ]] && period+="${D}D"
                                                period+="T"
  local H=$(($T/60/60%24)) && [[ $H -gt 0 ]] && period+="${H}H"
  local M=$(($T/60%60))    && [[ $M -gt 0 ]] && period+="${M}M"
  local S=$(($T%60))       && [[ $S -gt 0 ]] && period+="${S}S"
  echo "$period"
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_p2s
{
  ## Briefs:
  ##   - DE: wandelt einen Zeitraum, um Sekunden
  ##   - EN: transforms a period to seconds
  ##   - ES: transforma una duración en segundos  
  ##   - FR: transforme une durée en secondes 
  ##   - IT: trasforma una durata in secondi  
  ## Parameters:
  ##   - $1: iso8601 period
  ## Returns:
  ##   - stdout: seconds
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests:
  ##   #   : test various period sequence
  ##   - ut: assert -l a -c 'date_p2s "PT3M"'        -r 0 -o '180'
  ##   - ut: assert -l b -c 'date_p2s "PT03H"'       -r 0 -o '10800'
  ##   - ut: assert -l c -c 'date_p2s "P3D"'         -r 0 -o '259200'
  ##   - ut: assert -l d -c 'date_p2s "P2W"'         -r 0 -o '1209600'
  ##   - ut: assert -l e -c 'date_p2s "PT3H3M3S"'    -r 0 -o '10983'
  ##   - ut: assert -l f -c 'date_p2s "P3DT3H3M3S"'  -r 0 -o '270183'
  ##   #  g: ERROR invalid period
  ##   - ut: assert -l g -c 'date_p2s "AD AETERNAM"' -r 1 
  ## Usages: date_p2s <period>
  ## Comments: |
  ##
  local period=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing period;"}
  [[ $period =~ [^PWDTHMS0123456780]  ]] \
     && echo ERROR "bad period character"\
     && return 1 
  #
  local W=0 && [[ $period =~ ([0-9]+)W  ]]   && W=${BASH_REMATCH[1]}
  local D=0 && [[ $period =~ ([0-9]+)D  ]]   && D=${BASH_REMATCH[1]}
  local H=0 && [[ $period =~ T.*([0-9]+)H ]] && H=${BASH_REMATCH[1]}
  local M=0 && [[ $period =~ T.*([0-9]+)M ]] && M=${BASH_REMATCH[1]}
  local S=0 && [[ $period =~ T.*([0-9]+)S ]] && S=${BASH_REMATCH[1]}
  #
  local Wsec=$(($W*60*60*24*7))
  local Dsec=$(($D*60*60*24))
  local Hsec=$(($H*60*60))
  local Msec=$(($M*60))
  #
  echo $(( $Wsec + $Dsec + $Hsec + $Msec + $S ))
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function date_stat
{
  ## Briefs:
  ##   - DE: gibt das Dateierstellungsdatum
  ##   - EN: returns the file creation date
  ##   - ES: devuelve la fecha de creación del fichero  
  ##   - FR: retourne la date de création du fichier
  ##   - IT: ritorna la data di creazione del file 
  ## Parameters:
  ##   - $1: file path
  ##   - $2: opt1
  ##   - $3: opt2
  ## Returns:
  ##   - stdout: creation datetime
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests:
  ##   #  a: last file access date
  ##   - ut: assert -l a -c 'date_stat -a -f ".."' -r 0
  ##   #  b: last file modification date
  ##   - ut: assert -l b -c 'date_stat -m -f "date.sh"' -r 0 
  ##   #  c: file access date
  ##   - ut: assert -l c -c 'date_stat -c -f "date.sh"' -r 0
  ##   #  d: date of creation date 

  ##   #  e: epoch of creation date 
  ##   - ut: assert -l 0 -c 'touch -m -d 2000-01-01T00:00:00Z foo.t' -r 0
  ##   - ut: assert -l e -c 'date_stat -e -f "foo.t"' -r 0 -o '946684800' 
  ##   - ut: assert -l 0 -c 'rm foo.t'
  ## Usages: date_stat -amcde -f <filepath|filename>
  ## Comments: |
  ##
  local OPTIND
  local stat_format="%y"
  local stat_date="--iso-8601=sec"
  #
  while getopts "amcdef:" option "$@"
  do
     case "${option}" in
       a) stat_format="%x" ;;
       m) stat_format="%y" ;;
       c) stat_format="%z" ;;
       d) stat_date="d" ;;
       e) stat_date="e" ;;
       f) local filepath="$OPTARG" ;;
      \?) $_logger ERROR "Err:Invalid option -$OPTARG"          ; return 255 ;;
       :) $_logger ERROR "Err:Option -$OPTARG requires argument"; return 255 ;;
    esac
  done
  shift $((OPTIND-1))
  #
  [[ ! -e $filepath ]] && $_logger ERROR "no reach $filepath" && return 1
  #
  [[ $stat_date -eq "e" ]] && stat_format=${stat_format^^}
  local datetime="$(stat --format $stat_format $filepath)"
  # if epoch datetime display and exit
  [[ $stat_date -eq "e" ]] && echo $datetime && return 0 
  # else parse and convert to iso datetime format
  if [[ $datetime =~ ([0-9]{4})-([0-9]{2})-([0-9]{2})\ ([0-9]{2}):([0-9]{2}):([0-9]{2})\.[0-9]{9}\ ([+-][0-9]{4}) ]]
  then
      local    Years=${BASH_REMATCH[1]}
      local   months=${BASH_REMATCH[2]}
      local     days=${BASH_REMATCH[3]}
      local    Hours=${BASH_REMATCH[4]}
      local  Minutes=${BASH_REMATCH[5]}
      local  Seconds=${BASH_REMATCH[6]}
      local   offset=${BASH_REMATCH[7]}
      # return iso datetime
      echo "${Years}${months}${days}T${Hours}${Minutes}${Seconds}${offset}"
      return 0
  else  
      echo no match
      return 1
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - EN: Main programm, tests processing
##   - ES: Programa principal, tratamiento de los juegos de pruebas
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: Programma principale, trattamento di test gioco
## Usages: |
##   date.sh -ut <function_name> run tests of this function_name
##   date.sh -ut                 run tests of all library functions
## Comments: |
##
_msg_log='fnt:${FUNCNAME};num:${BASH_LINENO};arg:$@'
[[ ${LOGGER_SH++} ]] || source logger.sh
[[ ${ASSERT_SH++} ]] || source assert.sh
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
DATE_SH=true
#--------1---------2---------3---------4---------5---------6---------7---------8
#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : Logger
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
#--------1---------2---------3---------4---------5---------6---------7---------8
function logger
{
  ## Briefs:
  ##   - DE: zeichnet Nachricht mit Status
  ##   - EN: records message with status 
  ##   - ES: guardar el mensaje con el estado
  ##   - FR: enregitre le message avec le statut
  ##   - IT: salvare il messaggio con lo stato
  ## Parameters:
  ##   - $1: status
  ##   - $@: messages
  ## Returns: 
  ##   - stdout: None
  ##   - logger: message
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: logger TRACE "ut:1;msg:trace"
  ##   - ut: logger DEBUG "ut:2;msg:debug"
  ##   - ut: logger INFO  "ut:3;msg:info"
  ##   - ut: logger WARN  "ut:4;msg:warn"
  ##   - ut: logger ERROR "ut:5;msg:error" 
  ##   - ut: logger FATAL "ut:6;msg:fatal" 
  ##   - ut: logger DEBUG "ut:7;fnc:\${FUNCNAME}"
  ##   - ut: logger DEBUG "ut:8;num:\${LINENO}" 
  ##   - ut: logger DEBUG "ut:9;src:\${BASH_SOURCE}" 
  ##   - ut: assert_g -l'10' -c'logger TRACE "ut:1;msg:trace"' -o 'msg:trace'
  ##   - ut: assert_g -l'11' -c'logger DEBUG "ut:2;msg:debug"' -o 'msg:debug'
  ## Usages: logger <status> <messages>
  ## Comments: |
  ##
  local log_tag=${1^^:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing tag;"}
  local log_msg=${2:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing msg;"}
  #
  for appender in "${!_logger_cmd[@]}"
  do
      local appender_level=0
      case ${_logger_lvl[${appender}]} in
          TRACE) appender_level=1 ;;
          DEBUG) appender_level=2 ;;
          INFO)  appender_level=3 ;;
          WARN)  appender_level=4 ;;
          ERROR) appender_level=5 ;;
          FATAL) appender_level=6 ;;
      esac
      #
      local stamp=$(date +'%Y%m%d_%H%M%S') 
      local app_tgt=${_logger_tgt[${appender}]}
      local log_string="echo \"$stamp;$(printf "%-5b" $log_tag);$log_msg\" $app_tgt"
      case ${log_tag} in
          TRACE) [[ 1 -ge $appender_level ]] && eval "$log_string" ;;
          DEBUG) [[ 2 -ge $appender_level ]] && eval "$log_string" ;;
          INFO)  [[ 3 -ge $appender_level ]] && eval "$log_string" ;;
          WARN)  [[ 4 -ge $appender_level ]] && eval "$log_string" ;;
          ERROR) [[ 5 -ge $appender_level ]] && eval "$log_string" ;;
          FATAL) [[ 6 -ge $appender_level ]] && eval "$log_string" ;;
      esac
  done
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function logger_rotate 
{
  ## Briefs:
  ##   - DE: drehen Logdatei zum Ziel
  ##   - EN: rotate source log file to target
  ##   - ES: rotación del archivo de registro
  ##   - FR: rotation du fichier journal 
  ##   - IT: rotazione del file di registro
  ## Parameters:
  ##   - $1: source_log_file
  ##   - $2: target_log_file 
  ## Returns: 
  ##   - logger: info or error
  ##   - stdout: captured mv-command-line stdout
  ##   - sterr:  captured mv-command-line stderr 
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: touch source; logger_rotate ./source ./target ; rm target 
  ## Usages: logger_rotate <source_filepath> <target_filepath>
  ## Comments: |
  ##
  local source_file=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing source;"}
  local target_file=${2:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing target;"}
  local tag='rotate log file'
  #
  local mv_msg=$(mv -v $source_file $target_file 2>&1)
  case "$?" in 
      0) logger INFO  "$(eval $_logger_src0);${tag}:$mv_msg;" && return 0 ;;
      *) logger ERROR "$(eval $_logger_src0);${tag}:$mv_msg;" && return 1 ;;
  esac 
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function logger_rotold 
{
  ## Briefs:
  ##   - DE: drehen alte Logdateien
  ##   - EN: rotate old log files
  ##   - ES: viejos periódicos rotación
  ##   - FR: rotation de vieux journaux
  ##   - IT: vecchio rotazione giornali
  ## Parameters:
  ##   - $1: source_glob
  ##   - $2: target_mask 
  ##   - $3: old_days  default  30 days
  ## Returns: 
  ##   - logger: info and/or error
  ##   - stdout: success_count
  ##   - sterr:  failure_count 
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests:
  ##   - ut: touch -d $(date +%Y%m%d -d "1 monyh ago") /var/log/bbt/t1
  ##   - ut: logger_rotold '/var/log/batch/t*' '/var//backup' 30 
  ## Usages: logger_rotold <source_path> <target_path> [<days>]
  ## Comments: |
  ##
  set -f   # no globbing
  local source_glob=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing source;"}
  local target_path=${2:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing target;"}
  local    old_days=${3:-30} 
  # initialise counter
  local success_count=0
  local failure_count=0
  local   total_count=0
  local find_path=$(dirname  $source_glob)
  local find_glob=$(basename $source_glob)  
  set +f  # globbing again
  #
  for file in $(find $find_path -name "$find_glob" -mtime +$old_days)
  do
      echo $file
      local target_base="$(basename $file)"
      local target_file="${target_path}/${target_base}"
      local out_msg=$(logger_rotate  $file  $target_file)
      [ $? -eq 0 ] && ((success_count++)) || ((failure_count++))
      ((total_count++))
  done
  #
  local tag='rotate old log files'
  local rotate_ratio="${success_count}/${total_count}"
  #
  [ $success_count -eq $total_count ]\
      && logger INFO  "$(eval $_logger_src0);${tag}:${rotate_ratio};"\
      && return 0
  #
  [ $success_count -ne $total_count ]\
      && logger ERROR "$(eval $_logger_src0);${tag}:${rotate_ratio};"\
      && return 1
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function logger_compress
{
  ## Briefs:
  ##   - DE: comprimieren größten Log-dateien
  ##   - ES: grandes periódicos de compresión
  ##   - EN: compress greatest log-files
  ##   - FR: compression les gros journaux
  ##   - IT: compressione grandi giornali
  ## Parameters:
  ##   - $1: log_file
  ##   - $2: max_size default 10000
  ## Returns: 
  ##   - stdout: None
  ##   - sterr:  None
  ##   - rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: base64 /dev/urandom | head -c 11000 > test.log
  ##   - ut: logger_compress test.log +10k
  ##   - ut: rm test.log.gz
  ## Usages: logger_compress <filename> [<max_filesize>]
  ## Comments: |
  ##
  set -f   # no globbing
  local log_file=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing source;"}
  local max_size=${2:-100} # default 100k 
  # initialise counter
  local stamp=$(date +'%m%d')
  local tag='compress log file'
  local compress_success=0
  local compress_failure=0
  local find_path=$(dirname  $log_file)
  local find_glob=$(basename $log_file)  
  set +f  # globbing again
  #
  for file in $(find $find_path -name "$find_glob" -size +$max_size -type f)
  do
      local gz_msg=$(gzip -v ${file} 2>&1)
      case "$?" in 
          0) ((compress_success++))
             logger DEBUG "$(eval $_logger_src0);${tag}:$gz_msq;" ;;
          *) ((compress_failure++))
             logger WARN  "$(eval $_logger_src0);${tag}:$gz_msq;" ;;
      esac
  done	
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - ES: programa principal, tratamiento de los juegos de pruebas
##   - EN: Main programm, tests processing
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: programma principale, trattamento di test gioco
## Usages: |
##   logger.sh -ut <function_name> run tests of this function_name
##   logger.sh -ut                 run tests of all library functions
## Comments: |
##
[[ ${LOGGER_CONF++} ]] || source ./logger.conf 
[ $? -ne 0 ] && logger ERROR "fail to load logger.conf" && exit 2 
[[ ${ASSERT_SH++} ]] || source assert.sh
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
LOGGER_SH=true
#--------1---------2---------3---------4---------5---------6---------7---------8

#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : mailing
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
#--------1---------2---------3---------4---------5---------6---------7---------8
function mailer_sendmail_enclosed
{
  ## Briefs: 
  ##   - DE: E-Mail mit der beiliegenden Datei zu senden
  ##   - EN: sending a mail with enclosed file 
  ##   - ES: envia correo electrónico con datos adjunto
  ##   - FR: evoye un courriel avec une pièce jointe 
  ##   - IT: spedendo un e-mail con un affetto
  ## Comments: |
  ##       
  ## Parameters:
  ##   - $1: mail recipient to
  ##   - $2: mail subject
  ##   - $2: mail body
  ##   - $4: path of the enclosed file
  ##   - $5: name of the enclosed file
  ## Returns:
  ##   - stdout: info message
  ##   - stderr: error message
  ##   - logger: info|error message 
  ##   - rc:     { ok: 0, ko: 1 }
  ## Usages: |
  ##   mail_attach 'you@your_secret_garden' \
  ##               'my subject'             \
  ##               '$my_message_body'       \
  ##               /home/me/my_photo.jpeg   \
  ##               'my photo'
  ## Comments: |

  local mail_send=$(which sendmail) || return $_ko
  local mail_code=$(which uuencode) || return $_ko

  local m_recipient=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing arg1;"}
  local   m_subject=${2:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing arg2;"}
  local      m_body=${3:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing arg2;"}
  local attach_file=${4:-''}   # optional
  local attach_name=${5:-''}   # optional

 local mail_out=$($mail_send -v -oi -t <<!EOMAIL
 To: $m_recipient
 Subject: $m_subject
 $m_body
 !EOMAIL
 )
  local rc=$?
  
  [[ $rc -eq 0 ]] && $_logger DEBUG "$(eval $_logger_fmt0)" && return 0
  [[ $rc -ne 0 ]] && $_logger ERROR "$(eval $_logger_fmt0)" && return 1
}
# $attach_file && $(uuencode $attach_name $attach_file )
#--------1---------2---------3---------4---------5---------6---------7---------8
function mailer_simple
{
  ## Briefs:
  ##   - DE: Senden einer einfachen E-Mail 
  ##   - EN: sending a basic e-mail
  ##   - ES: enviar un simple correo electrónico
  ##   - FR: envoyer un courriel simple
  ##   - IT: invio di una semplice e-mail e-mail
  ## Parameters:
  ##   - $1: mailer recipient
  ##   - $2: mailer subject
  ##   - $3: mailer body
  ## Returns:
  ##   - stdout: info message
  ##   - stderr: error message
  ##   - logger: info|error message 
  ##   - rc:     { ok: 0, ko: 1 }
  ## Tests:
  ##   - ut: assert -l a -r 0 -c"mailer_simple 'to' 'subject' 'body''"
  ## Usages: mailer_simple <recipient> <subject> <body>
  ## Comments: |

  local mail_send=$(which sendmail) || return 2

  local m_recipient=${1:? fnt:$FUNCNAME;from:$BASH_LINENO;err:missing arg1;}
  local   m_subject=${2:? fnt:$FUNCNAME;from:$BASH_LINENO;err:missing arg2;}
  local      m_body=${3:? fnt:$FUNCNAME;from:$BASH_LINENO;err:missing arg3;}

  local mail="To: $m_recipient\nSubject: $m_subject\nFrom: noreply\n$m_body"  
  echo -e $mail | sendmail -t  
  exit $?  
    
  [[ $rc -eq 0 ]] && $_logger INFO  "$(eval $_logger_fmt0)" && return 0
  [[ $rc -ne 0 ]] && $_logger ERROR "$(eval $_logger_fmt0)" && return 1
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function mailer_external
{
  ## Briefs: 
  ##   - DE: Senden von externen Mail-Server
  ##   - EN: sending by external mail server 
  ##   - ES: enviar correo electrónico mediante un servidor externo
  ##   - FR: evoyer un courriel via un serveur externe 
  ##   - IT: envio e-mail attraverso un server esterno
  ## Parameters:
  ##   - t: mail to
  ##   - f: mail from
  ##   - s: mail subject
  ##   - b: mail body
  ##   - m: mail message
  ##   - u: mail user
  ##   - p: mail passwd  
  ## Returns:
  ##   - stdout: info message
  ##   - stderr: error message
  ##   - logger: info|error message 
  ##   - rc:     { ok: 0, ko: 1 }
  ## Usages: mail_
  ## Comments: |
  ##

  local OPTIND
  local flags=0

  while getopts ":t:f:s:b:m:u:p:" option "$@"
  do
     case "${option}" in
       t) local      mail_to="$OPTARG" ;;
       f) local    mail_from="$OPTARG" ;;
       s) local mail_subject="$OPTARG" ;;
       b) local    mail_body="$OPTARG" ;;
       m) local smtp_serveur="$OPTARG" ;;
       u) local    smtp_user="$OPTARG" ;;
       p) local  smtp_passwd="$OPTARG" ;;
      \?) echo "Err: Invalid option -$OPTARG"           >&2 ; return 255 ;;
       :) echo "Err: Option -$OPTARG requires argument" >&2 ; return 255 ;;
     esac
  done
  shift $((OPTIND-1))

local mail_out=$(
 echo $mail_body | mailx -v \
 -r "$mail_from" \
 -s "$mail_subject" \
 -S smtp="$smtp_server.net:587" \
 -S smtp-use-starttls \
 -S smtp-auth=login \
 -S smtp-auth-user="smtp_user" \
 -S smtp-auth-password="smtp_passwd" \
 -S ssl-verify=ignore \
"$mail_to" )
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - EN: Main programm, tests processing
##   - ES: Programa principal, tratamiento de pruebas
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: Programma principale, trattamento di test gioco
## Usages: |
##   mailer.sh -ut <function_name> run tests of this function_name
##   mailer.sh -ut                 run tests of all library functions
## Comments: |
##
[[ ${LOGGER_SH++} ]] || source logger.sh
[[ ${ASSERT_SH++} ]] || source assert.sh
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
MAILER_SH=true
#--------1---------2---------3---------4---------5---------6---------7---------8

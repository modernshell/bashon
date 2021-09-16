#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : password
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
##  DE       : |
##    Der Zweck dieser Schrift ist zu aussprechbar Benutzer Passwörter 
##    generieren um mehr leicht zu merken.
##    Einige Best Practices, die Sie achten sollten:
##    - stärkung der Länge aussprechbar Passwörter
##    - wählen Sie eine Vielzahl von Faktoren-Authentifizierungsmechanismus
##    - ändern Sie Ihren Benutzernamen Passwort mindestens alle sechs Monate
##  EN       : |
##    The purpose of this script is to generate pronounceable user passwords 
##    in order to be more easy to remember.
##    Few best practices that you should pay attention to :
##    - strengthen the length of the pronounceable passwords
##    - choose a multiple factors authentication mechanism
##    - change your username password at least every six months
##  ES: |
##    El propósito de este script es para generar contraseñas de usuario pronunciables
##    Con el fin de ser más fácil de recordar.
##    Pocos mejores prácticas que debe prestar atención a:
##    - Fortalecer la longitud de las contraseñas pronunciables
##    - Elegir un mecanismo de autenticación de factores múltiples
##    - Cambiar su nombre de usuario contraseña al menos cada seis meses
##  FR       : |
##    Le but de ce script est de générer des mots de passe utilisateur 
##    prononçables afin d'être plus facile à retenir.
##    Quelques bonnes pratiques auxquelles vous devriez faire attention:
##    - renforcer la longueur des mots de passe prononçable
##    - choisir un mécanisme d'authentification à facteurs multiples
##    - changer votre mot de passe utilisateur tous les six mois, au moins
##  IT       : |
##    Lo scopo di questo script è quello di generare le password degli utenti 
##    pronunciabili per essere più facile da ricordare.
##    Alcune buone pratiche che si dovrebbe prestare attenzione:
##    - rafforzare la lunghezza della password pronunciabili
##    - scegliere un meccanismo di autenticazione fattori multipla
##    - modificare la password nome utente, almeno ogni sei mesi
#--------1---------2---------3---------4---------5---------6---------7---------8
function passwd_getchar
{
  ## Briefs:
  ##     DE: ein Element der Zeichensatz nach Zufalls zu erhalten
  ##     EN: gets element randomly from the charset
  ##     ES: llegar elemento de azar del juego de caracteres
  ##     FR: obtenir au hasard un élèment du jeu de caractères
  ##     IT: ottenere casualmente un elemento del set di caratteri
  ## Parameters:
  ##     $1: code_set
  ## Returns:
  ##     stdout: character element
  ##     sterr:  error
  ##     rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: assert -la -r0 -c 'passwd_getchar "C"'
  ## Usages: passwd_getchar <cod_set>
  ## Comments: |
  ##
  local code_set=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing code_set;"}
  local characters=${char_set[$code_set]} || exit 1
  echo -en ${characters:$((RANDOM%${#characters})):1}
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function passwd_combination
{
  ## Briefs:
  ##     DE: Anzahl der Passwort-Kombinationen
  ##     EN: number of password combination
  ##     ES: número de combinaciones de contraseñas
  ##     FR: nombre de combinaisons de mots de passe
  ##     IT: numero di combinazioni di password
  ## Parameters:
  ##     $1: pattern
  ## Returns:
  ##     stdout: combination number
  ##     sterr:  error
  ##     rc: { passwd combination }
  ## Tests: 
  ##   - ut: assert -la -r0 -c 'passwd_combination'
  ## Usages: passwd_combinations <pattern>
  ## Comments: |
  ##
  local pattern=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing pattern;"}
  #
  local combination_number=1
  for i in $(seq 1 ${#pattern})
  do
      local   charset_code=${pattern:i-1:1}
      local charset_lenght=${#character_set[$charset_code]} || exit -1
      combination_number = $((combination_number * charset_lenght))
  done
  #
  return $combination_number
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function passwd_maker
{
  ## Briefs:
  ##     DE: Erzeugt das Passwort
  ##     EN: generates the password
  ##     ES: genera la contraseña
  ##     FR: génère le mot de passe
  ##     IT: genera la password
  ## Parameters:
  ##     $1: password pattern
  ## Returns:
  ##     stdout: string
  ##     sterr:  error
  ##     rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: assert -la -r0 -c ''
  ## Usages: passwd_maker <pattern>
  ## Comments: |
  ##
  local pattern=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing pattern;"}
  #
  for i in $(seq 1 ${#pattern})
  do
      local code_set=${pattern:i-1:1}
      passwd_getchar $code_set || exit 1
  done
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function passwd_random
{
  ## Briefs:
  ##     DE: Erzeugt das Passwort
  ##     EN: generates the password
  ##     ES: genera la contraseña
  ##     FR: génère le mot de passe
  ##     IT: genera la password
  ## Parameters:
  ##     $1: password pattern
  ## Returns:
  ##     stdout: string
  ##     sterr:  error
  ##     rc: { ok: 0, ko: 1 }
  ## Tests: 
  ##   - ut: assert -la -r0 -c ''
  ## Usages: passwd__maker <pattern>
  ## Comments: |
  ##
  # pass patterns
  declare -A pattern_set
  pattern_set[01]="CvcvCsCvcvCnnn"
  pattern_set[02]="VccvcvsZvccvZnn"
  pattern_set[03]="cvcvcvnnncvcvcv"
  pattern_set[04]="cvncvscvncvs"
  pattern_set[05]="cvZsZvcvZnnn"
  pattern_set[06]="CVCCVCnncvcvvcnn"
  # re-seed the pseudo-random function 
  # (urandom, cause of bad VM entropy
  local RANDOM=$(head -c2 /dev/urandom | od -d | awk '{ print $2 }')
  randidx=$((RANDOM%${#pattern_set[@]}))
  pass=$(passwd_maker "${pattern_set[$randidx]}")
  echo "${pass}"
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - EN: Main programm, tests processing
##   - ES: Programa principal, tratamiento de los juegos de pruebas
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: Programma principale, trattamento di test gioco
## Usages: |
##   passwd.sh -ut <function_name> run tests of this function_name
##   passwd.sh -ut                 run tests of all library functions
## Comments: |
##

# charset dictionnary
declare -A char_set
char_set['c']="bcdfghjklmnpqrstvwxz"             # Lower Consonants
char_set['C']="BCDFGHJKLMNPQRSTVWXZ"             # Upper Consonants
char_set['v']="aeiouy"                           # Lower Vowels
char_set['V']="AEIOUY"                           # Upper Vowels
char_set['d']="0123456789"                       # Digits
char_set['s']="&#%@+-.:,<>"                      # Signs
char_set['A']="${char_set[v]}${char_set[V]}"     # Upper, Lowers Vowels
char_set['Z']="${char_set[c]}${char_set[C]}"     # Upper, Lowers Consonants
#
[[ ${LOGGER_SH++} ]] || source logger.sh
[[ ${ASSERT_SH++} ]] || source assert.sh
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
PASSWD_SH=true
#--------1---------2---------3---------4---------5---------6---------7---------8

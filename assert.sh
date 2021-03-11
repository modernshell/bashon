#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : assert
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
#--------1---------2---------3---------4---------5---------6---------7---------8
function assert
{
  ## Briefs:
  ##   - DE: Behauptung-Test, prüfen die erste Zeile der Ergebnisdatei
  ##   - ES: prueba de aserción, prueba de la primera línea de los resultados
  ##   - EN: assertion test, test the first line of results 
  ##   - FR: test d'assertion, teste la première ligne de résultats 
  ##   - IT: test di asserzione, esamini la prima linea di risultati 
  ## Parameters:
  ##   -  l: test label 
  ##   -  c: command
  ##   -  o: expected standard output of the command (head -1)
  ##   -  r: expected return code of the command
  ##   -  e: expected standard error of the command  (head -1)
  ## Returns: 
  ##   - stdout: YAML report
  ##   - rc: { ok: 0, mismatch: 1-7, call-error: 255 }
  ## Tests:
  ##   #   : expected results 
  ##   - ut: assert -l a -r0 -c "assert -c'echo line1'   -o line1"
  ##   - ut: assert -l b -r0 -c "assert -c'echo out'     -o out"
  ##   - ut: assert -l c -r0 -c "assert -c'echo err >&2' -e err"
  ##   - ut: assert -l d -r0 -c "assert -c'echo err>&2;echo out' -o out -e err"
  ##   #   : Error, not expected results
  ##   - ut: assert -l e -r5 -c "assert -c'echo line1'   -o line3"
  ##   - ut: assert -l f -r5 -c "assert -c'echo out'     -o no_out"
  ##   - ut: assert -l g -r6 -c "assert -c'echo err >&2' -e no_err"
  ##   - ut: assert -l h -r7 -c "assert -c'echo err>&2;echo out' -o no -e no "
  ## Usages: assert -l <label> -r <result> -c <cmd> -o <output>  -e <error>
  ## Comments: |
  ##
  local OPTIND
  local flags=0
  # reads arguments
  while getopts "l:c:o:r:e:" option
  do
     case "${option}" in
       l) local    label="$OPTARG" ;;       # assert: label
       c) local  command="$OPTARG" ;;       # assert: command
       o) local a_stdout="$OPTARG" ;;       # assert: expected stderr
       r) local a_return="$OPTARG" ;;       # assert: expected return code
       e) local a_stderr="$OPTARG" ;;       # assert: expected stderr
      \?) echo "Err: Invalid option -$OPTARG"           >&2 ; return 255 ;;
       :) echo "Err: Option -$OPTARG requires argument" >&2 ; return 255 ;;
     esac
  done
  shift $((OPTIND-1))
  # run test
  local tmp_file r_return r_stdout r_stderr
  tmp_file=$(mktemp)
  r_stdout=$(eval "$command" 2> $tmp_file)  # result: stdout
  r_return=$?                               # result: return code
  r_stdout=$(echo -e "$r_stdout" | head -1) # result: stdout (head -1)
  r_stderr=$(cat $tmp_file | head -1)       # result: stderr (head -1)
  rm $tmp_file
  # the expected data:
  local                assert+="assert: {"
                       assert+=" a_cmd:$command,"
  [[ -v a_stdout ]] && assert+=" a_out:$a_stdout,"
  [[ -v a_stderr ]] && assert+=" a_err:$a_stderr,"
  [[ -v a_return ]] && assert+=" a_rc:$a_return"
                       assert+=" }"
  # the resulted data:
  local                result+="result: {"
  [[ -v a_stdout ]] && result+=" r_out:$r_stdout,"
  [[ -v a_stderr ]] && result+=" r_err:$r_stderr,"
  [[ -v a_return ]] && result+=" r_rc:$r_return,"
                       result+=" }"
  # analyse results
  local report='report: '
  # stdout: the expected data are not the requested data
  #         then raise the first flag and report it
  [[ -v a_stdout ]] && [[ ! "$r_stdout" == "$a_stdout" ]] \
                    && ((flags+=1))                       \
                    && report+="sdtout: mismatch, "
  # stderr: the expected data are not the requested data
  #         then raise the second flag and report it
  [[ -v a_stderr ]] && [[ ! "$r_stderr" == "$a_stderr" ]] \
                    && ((flags+=2))                       \
                    && report+="sdterr: mismatch, "
  # return: the expected data are not the requested data
  #         then raise the third flag and report it
  [[ -v a_return ]] && [[ ! "$r_return" == "$a_return" ]] \
                    && ((flags+=4))                       \
                    && report+="return: mismatch, "
  # display YAML report
  [[ $flags > 0 ]] \
    && echo "- ut @$label: { test:KO, $(echo -n $assert, $result) $report }" \
    || echo "- ut @$label: { test:OK, $(echo -n $assert, $result) }"
  # return flags
  return $flags
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function assert_g
{
  ## Briefs:
  ##   - DE: Behauptung-Test, prüfen Ergebnisdatei mit Grep
  ##   - ES: prueba de aserción, prueba de filtro con Grep en los resultados
  ##   - EN: assertion test, filter test with Grep on results
  ##   - FR: test d'assertion, test de filtre Grep sur les résultats
  ##   - IT: test di asserzione, prova di filtro con Grep sui risultati
  ## Parameters:
  ##   -  l: test label
  ##   -  c: command
  ##   -  o: expected standard output of the command
  ##   -  r: expected return code of the command
  ##   -  e: expected standard error of the command
  ## Returns:
  ##   - stdout: YAML report
  ##   - rc: { ok: 0, mismatch: 1-7, call-error: 255 }
  ## Tests:
  ##   #   : expected results 
  ##   - ut: assert -la -r0 -c"assert_g -c'echo line1;echo line2'  -o line2"
  ##   - ut: assert -lb -r0 -c"assert_g -c'printf \"l1\nout\nl3\"' -o out"
  ##   - ut: assert -lc -r0 -c"assert_g -c \"echo -e 'l1\nerr\nl3'>&2\" -e err"
  ##   - ut: assert -ld -r0 -c"assert_g -c'echo err>&2;echo out' -o out -e err"
  ##   #   : Error, not expected results 
  ##   - ut: assert -le -r5 -c"assert_g -c'echo line1;echo line2'  -o line3"
  ##   - ut: assert -lf -r5 -c"assert_g -c'printf \"l1\nout\nl3\"' -o tuo"
  ##   - ut: assert -lg -r6 -c"assert_g -c'echo -e \"l1\nerr\nl3>&2\"' -e rre"
  ##   - ut: assert -lh -r7 -c"assert_g -c'echo err>&2;echo out' -o tuo -e rre"
  ## Usages: assert -l <label> -c <cmd> -o <output> -r <result> -e <error>
  ## Comments: |
  ##
  local OPTIND
  local flags=0
  # reads arguments
  while getopts "l:c:o:r:e:" option
  do
     case "${option}" in
       l) local    label="$OPTARG" ;;       # assert: label
       c) local  command="$OPTARG" ;;       # assert: command
       o) local a_stdout="$OPTARG" ;;       # assert: expected in stdout
       r) local a_return="$OPTARG" ;;       # assert: expected return code
       e) local a_stderr="$OPTARG" ;;       # assert: expected in stderr
      \?) echo "Err: Invalid option -$OPTARG"           >&2 ; return 255 ;;
       :) echo "Err: Option -$OPTARG requires argument" >&2 ; return 255 ;;
     esac
  done
  shift $((OPTIND-1))
  # run test
  local tmp_file r_return r_stdout r_stderr
  tmp_file=$(mktemp)
  r_stdout=$(eval "$command" 2> $tmp_file)  # result: stdout
  r_return=$?                               # result: return code
  r_stderr="$(cat $tmp_file)"               # result: stderr
  rm $tmp_file
  # the expected data are:
  local                assert+="assert_g: {"
                       assert+=" a_cmd:$command,"
  [[ -v a_stdout ]] && assert+=" a_out:$a_stdout,"
  [[ -v a_stderr ]] && assert+=" a_err:$a_stderr,"
  [[ -v a_return ]] && assert+=" a_rc:$a_return"
                       assert+=" }"
  # the resulted data are:
  local                result+="result: {"
  [[ -v a_stdout ]] && result+=" r_out:$r_stdout,"
  [[ -v a_stderr ]] && result+=" r_err:$r_stderr,"
  [[ -v a_return ]] && result+=" r_rc:$r_return,"
                       result+=" }"
  # analyse discrepencies expected and resulted data
  local report
  # stdout: the expected data does not match the requested data
  #         then raise first flag and report it
  [[ -v a_stdout ]] && [[ ! "$r_stdout" =~ "$a_stdout" ]] \
                    && ((flags+=1))                       \
                    && report+="sdtout mismatch, "
  # stderr: the expected data does not match the requested data
  #         then raise second flag and report it
  [[ -v a_stderr ]] && [[ ! "$r_stderr" =~ "$a_stderr" ]] \
                    && ((flags+=2))                       \
                    && report+="sdterr mismatch, "
  # return: the expected data does not match the requested data
  #         then raise third flag and report it
  [[ -v a_return ]] && [[ ! "$r_return" == "$a_return" ]] \
                    && ((flags+=4))                       \
                    && report+="return mismatch, "
  # display YAML report
  [[ $flags > 0 ]] \
    && echo "- ut @$label: { test:KO, $(echo -n $assert, $result) $report }" \
    || echo "- ut @$label: { test:OK, $(echo -n $assert, $result) }"
  # return flags
  return $flags
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function assert_ft
{
  ## Briefs:
  ##   - DE: Behauptung-Test, prüfen letzte Zeile der Ergebnisdatei
  ##   - ES: prueba de aserción, prueba la última línea del resultado de archivos
  ##   - EN: assertion test, test last line of file result
  ##   - FR: test d'assertion, teste la dernière ligne du fichier resultat
  ##   - IT: test di asserzione, esamini per ultimo linea di risultati 
  ## Parameters:
  ##   -  c: command
  ##   -  f: output filepath
  ##   -  o: expected pattern present in last line of output file
  ##   -  r: expected return value
  ## Returns:
  ##   - stdout: YAML report
  ##   - rc: { ok: 0, mismatch: 1, call-error: 255 }
  ## Tests:
  ##   #   : expected results 
  ##   - ut: assert -la -r0 -c"assert_ft -c'echo l1 >>file' -f file -o l1"
  ##   - ut: assert -la -r0 -c"assert_ft -c'echo l2 >>file' -f file -o l2"
  ##   #   : Error, not expected results 
  ##   - ut: assert -la -r1 -c"assert_ft -c'echo l3'        -f file -o l3"
  ##   #   : clean up
  ##   - ut: rm ./file
  ## Usages: assert_ft -l <label> -c <cmd> -f <filepath> -o <filetail>
  ## Comments: |
  ##
  local OPTIND
  local flags=0
  # reads arguments
  while getopts "l:c:f:o:" option
  do
     case "${option}" in
       l) local    label="$OPTARG" ;;       # assert: label
       c) local  command="$OPTARG" ;;       # assert: command
       f) local filepath="$OPTARG" ;;       # assert: filepath
       o) local   a_fout="$OPTARG" ;;       # assert: expected filetail
       r) local a_return="$OPTARG" ;;       # assert: expected return code
      \?) echo "Err: Invalid option -$OPTARG"           >&2 ; return 255 ;;
       :) echo "Err: Option -$OPTARG requires argument" >&2 ; return 255 ;;
     esac
  done
  shift $((OPTIND-1))
  # run test
  eval "$command"
  # the expected data:
  local                assert+="assert: {"
                       assert+=" a_cmd:$command,"
  [[ -v a_fout ]]   && assert+=" a_out:$f_out,"
  [[ -v a_return ]] && assert+=" a_rc:$a_return"
                       assert+=" }"
  # the resulted data:
  local                result+="result: {"
  [[ -v a_fout ]]   && result+=" r_out:$r_stdout,"
  [[ -v a_return ]] && result+=" r_rc:$r_return,"
                       result+=" }"
  # analyse results
  local report="$(tail -1 $filepath)"
  [[ "$report" =~ "$a_fout" ]]
  local flag=$?
  # display YAML report
  [[ $flag > 0 ]] \
    && echo "- ut @$label: { -test:KO, $(echo -n $assert, $result) $report }"\
    || echo "- ut @$label: { -test:OK, $(echo -n $assert, $result) }"
  # return flags
  return $flag
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function assert_func
{
  ## Briefs:
  ##   - DE: startet Unit-Tests der Funktion
  ##   - ES: lanzar las pruebas unitarias de la función
  ##   - EN: launchs the function's unitary tests
  ##   - FR: lance les tests unitaires de la fonction
  ##   - IT: lanciare i test unitari della funzione
  ## Parameters:
  ##   - $1: function
  ##   - $2: library
  ## Returns:
  ##   - stdout: test results
  ##   - rc: 0 1 2 3
  ## Tests:
  ##   - ut: assert -la -r0 -c"assert_func 'assert' 'assert.sh'"
  ##   - ut: assert -la -r1 -c"assert_func 'foo'    'assert.sh'"
  ##   - ut: assert -lb -r2 -c"assert_func 'foo.sh' 'foo.sh'"
  ## Usages: assert_func  <function>  <library>
  ## Comments: |
  ##
  local func=${1:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:Missing func"}
  local file=${2:?"fnt:${FUNCNAME};from:${BASH_LINENO};err:missing file"}
  #
  echo "\"UTests of function ${func}\":"
  local f_code=$( awk "/^function ${func}$/,/^}/" $file )
  local u_test=$( echo -n "$f_code" | grep '  ##   - ut: ' - | cut -c 14- )
  for ut_line in "$u_test"; do
      eval "$ut_line"
  done
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function assert_lib
{
  ## Briefs:
  ##   - DE: startet Tests der Bibliothek
  ##   - EN: launch the tests of library 
  ##   - ES: lanzar las pruebas de la biblioteca
  ##   - FR: lance les tests de la librairie
  ##   - IT: lanciare le prove di biblioteca
  ## Parameters:
  ##   - $1:  caller(executable)
  ##   - $2:  library
  ##   - $3:  flag
  ##   - $4:  argument
  ## Returns:
  ##   - stdout: test results
  ##   - rc: 0  1 2 3
  ## Tests:
  ##   - ut: assert -la -r1 -c"assert_lib 'foo.sh' 'bar.sh'"
  ##   - ut: assert -lb -r2 -c"assert_lib 'foo.sh' 'foo.sh'"
  ##   - ut: assert -lc -r3 -c"assert_lib 'assert.sh' 'assert.sh' '-ut' 'foo'"
  ##   - ut: assert -ld -r0 -c"assert_lib 'assert.sh' 'assert.sh' '-ut' assert"
  ## Usages: assert_lib <exe> <source> <flag> <function_name>
  ## Comments: |
  ##
  local exe=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing exe;"}
  local src=${2:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing src;"}
  local flg=${3:-''}
  local arg=${4:-''}
  #
  [[ ! $exe == $src  ]] && return 1
  [[ ! $flg == '-ut' ]] && return 2
  #mkdir t 2> /dev/null
  _logger=logger
  #_logger_lvl[log]=TRACE
  #_logger_tgt[log]=">> ./t/ut_${BASH_SOURCE%.*}_$$.log"
  if [[ ! -z ${arg} ]];then
      func=${arg}
      found=$( declare -F "$func" > /dev/null && echo 0 || echo 1)
      if [[ $found == "0" ]]
      then
          assert_func $func $exe
      else
          echo "unknown function $func" >&2 && return 3
      fi
  else
      echo "defined function tests"
      for func in $(awk '/^function/{print$2}' $exe)
      do
          assert_func $func $exe
      done
  fi
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function assert_args
{
  ## Briefs:
  ##   - DE: analyse die Argumentliste 
  ##   - EN: analyze the argument list
  ##   - ES: analizar la lista de argumentos
  ##   - FR: analyse la liste d'arguments
  ##   - IT: analizzare l'elenco argomenti
  ## Parameters:
  ##   - $@: args arrays
  ## Returns:
  ##   - stdout: test results
  ##   - rc: 1
  ## Comments: |
  ##
  args=($@)
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - EN: Main programm, tests processing
##   - ES: programa principal, tratamiento de los juegos de pruebas
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: programma principale, trattamento di test gioco
## Usages: |
##   assert.sh -ut <function_name> run tests of this function_name
##   assert.sh -ut                 run tests of all library functions
## Comments: |
##
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
ASSERT_SH=true
#--------1---------2---------3---------4---------5---------6---------7---------8

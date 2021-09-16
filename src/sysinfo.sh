#!/bin/bash -
#--------1---------2---------3---------4---------5---------6---------7---------8
##  Product  : Bash_Batch_ToolBox
##  Library  : sysinfo
##  Type     : bourne again shell
##  Author   : modern.shell@gmail.com
##  Revision : $Id: $
#--------1---------2---------3---------4---------5---------6---------7---------8
function sysinfo_dmi
{
  ## Briefs:
  ##   - DE: sysinfo von 'Desktop Management Interface'
  ##   - EN: get sysinfo from 'Desktop Management Interface' 
  ##   - ES:
  ##   - FR: sysinfo via 'Desktop Management Interface'
  ##   - IT:
  ## Parameters:
  ##   - $1: Desktop-Management-Interface tag
  ## Returns:
  ##   - stdout: sysinfo
  ## Tests:
  ##   #   : test sysinfo_dmi tags
  ##   - ut: assert -l a -r0 -c'sysinfo_dmi bios-vendor'
  ##   - ut: assert -l b -r0 -c'sysinfo_dmi bios-version'
  ##   - ut: assert -l c -r0 -c'sysinfo_dmi baseboard-manufacturer'
  ##   - ut: assert -l d -r0 -c'sysinfo_dmi baseboard-product-name'
  ##   - ut: assert -l e -r0 -c'sysinfo_dmi baseboard-version'
  ##   - ut: assert -l f -r0 -c'sysinfo_dmi baseboard-serial-number'
  ##   #   : ERROR bad sysinfo_dmi tag
  ## Usages: sysinfo_dmi <dmi_tag>
  ## Comments: |
  ##     url:http://www.nongnu.org/dmidecode/
  ##
  if not which dmidecode >/dev/null 2>&1;then
    echo error required dmidecode  >2
    return -1
  fi 
  #
  local rc
  local tag=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing tag;"}
  #
  local info=$( sudo dmidecode -s $tag )
  rc=${?}
  [[ $rc  -ne 0 ]] && echo "Error:$BASH_LINENO cmd failed">2 && return 3
  #
  echo $info
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function sysinfo_cpu
{
  ## Briefs:
  ##   - DE: sysinfo von  cpuinfo
  ##   - EN: sysinfo from cpuinfo
  ##   - ES:
  ##   - FR: sysinfo via  cpuinfo
  ##   - IT:
  ## Parameters:
  ##   - $1: Desktop-Management-Interface tag
  ## Returns:
  ##   - stdout: sysinfo
  ## Tests:
  ##   #   : test sysinfo_cpu tags
  ##   - ut: assert -l a -r0 -c "sysinfo_cpu 'model name\s*: \K(.*)'"
  ##   - ut: assert -l b -r0 -c "sysinfo_cpu 'cpu MHz\s*: \K(.*)'   "
  ##   - ut: assert -l c -r0 -c "sysinfo_cpu 'cache size\s*: \K(.*)'"
  ##   - ut: assert -l d -r0 -c "sysinfo_cpu 'cpu cores\s*: \K(.*)' "
  ##   #   : ERROR bad sysinfo_cpu tag
  ##   - ut: assert -l e -r1 -c 'sysinfo_cpu Quantum-CPU'
  ## Usages: sysinfo_cpu <dmi_tag>
  ## Comments: |
  ##
  local rc
  local tag=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing tag;"}
  #
  local info=$(cat /proc/cpuinfo | grep -oPi "$tag")
  rc=${?}
  [[ $rc  -ne 0 ]] && echo "Error:$BASH_LINENO cmd failed">2 && return 3
  #
  echo $info
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function sysinfo_mem
{
  ## Briefs:
  ##   - DE: sysinfo von  meminfo
  ##   - EN: sysinfo from meminfo
  ##   - ES:
  ##   - FR: sysinfo via  meminfo
  ##   - IT: sysinfo via  meminfo
  ## Parameters:
  ##   - $1: Desktop-Management-Interface tag
  ## Returns:
  ##   - stdout: sysinfo
  ## Tests:
  ##   #   : test sysinfo_mem tags
  ##   - ut: assert -l a -r0 -c "sysinfo_mem 'MemTotal: \K(.*)'"
  ##   - ut: assert -l b -r0 -c "sysinfo_mem 'MemFree: \K(.*)'"
  ##   #   : Error bad sysinfo mem tag
  ##   - ut: assert -l c -r1 -c 'sysinfo_mem LostMemories'
  ## Usages: sysinfo_mem <dmi_tag>
  ## Comments: |
  ##
  local rc
  local tag=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing tag;"}
  #
  local info=$(cat /proc/meminfo | grep -oPi "$tag")
  rc=${?}
  [[ $rc  -ne 0 ]] && echo "Error:$BASH_LINENO cmd failed">2 && return 3
  #
  echo $info
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function sysinfo_fdisk
{
  ## Briefs:
  ##   - DE:
  ##   - EN: extract cpuinfo tag's information
  ##   - ES:
  ##   - FR: extrait d'information fdisk
  ##   - IT:
  ## Parameters:
  ##   - $1: Desktop-Management-Interface tag
  ## Returns:
  ##   - stdout: sysinfo
  ## Tests:
  ##   - ut: assert -l '0' -c 'sysfdisk_cpu MonTrucEnPlume' -r 1
  ## Usages: sysinfo_fdisk <dmi_tag>
  ## Comments: |
  ##
  local rc
  local tag=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing tag;"}
  #
  local info=$(sudo fdisk -l | grep -i "$tag" | cut -d: -f2)
  rc=${?}
  [[ $rc  -ne 0 ]] && $logger "Error:$BASH_LINENO cmd failed">2 && return 3
  #
  echo $info
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function sysinfo_hdd
{
  ## Briefs:
  ##   - DE:
  ##   - EN: extract information with hdparm
  ##   - ES:
  ##   - FR: extrait l'information avec hdparm
  ##   - IT:
  ## Parameters:
  ##   - $1: Desktop-Management-Interface tag
  ## Returns:
  ##   - stdout: sysinfo
  ## Tests:
  ##   #   : test sysinfo_hdd tags
  ##   - ut: assert -la -r0 -c"sysinfo_hdd 'Model Number: \K(.*)'"
  ##   - ut: assert -lb -r0 -c"sysinfo_hdd 'Serial Number: \K(.*)'"
  ##   - ut: assert -lc -r0 -c"sysinfo_hdd 'Firmware Revision: \K(.*)'"
  ##   - ut: assert -ld -r0 -c"sysinfo_hdd 'size with M = 1024\*1024:\s*\K(\S*)'"
  ##   - ut: assert -le -r0 -c"sysinfo_hdd 'Serial Number'"
  ##   #   : Error bad sysinfo_hdd tag
  ##   - ut: assert -lf -r1 -c"sysinfo_hdd MonTrucEnPlume"
  ## Usages: sysinfo_hdd <dmi_tag>
  ## Comments: |
  ##
  if not which hdparm >/dev/null 2>&1;then
    echo error required hdparm  >2
    return -1
  fi 
  #
  local rc
  local tag=${1:?"fnt:$FUNCNAME;from:$BASH_LINENO;err:missing tag;"}
  #
  local info=$(             \
    sudo hdparm -I "$dev"   \
         | grep -i "$tag"   \
         | cut  -d: -f2     \
         | sed  -e  's/^[ \t]*//'  )
  #
  for perr in ${PIPESTATUS[@]}; do 
    [[ "${PIPESTATUS[$perr]}" -ne 0 ]] && echo "error pipe $perr">2 && return 1
  done
  #
  echo $info
}
#--------1---------2---------3---------4---------5---------6---------7---------8
function sysinfo_sysinfo
{
  ## Briefs:
  ##   - DE:
  ##   - EN: extracts all physical data from system
  ##   - ES:
  ##   - FR: extrait l'ensemble des données physique d'un systèmes
  ##   - IT:
  ## Parameters:
  ##   - $1: 
  ## Returns:
  ##   - stdout: sysinfo_array key value
  ## Tests:
  ## Usages: sysinfo_sysinfo 
  ## Comments: |
  ##
  declare -A sysinfo
  #
  dmi='bios'
  sysinfo["hw_${dmi}_vendor"]=$(  sysinfo_dmi 'bios-vendor' )
  sysinfo["hw_${dmi}_vers"]=$(    sysinfo_dmi 'bios-version')
  #
  dmi='board'
  sysinfo["hw_${dmi}_manu"]=$(    sysinfo_dmi 'baseboard-manufacturer'  )
  sysinfo["hw_${dmi}_name"]=$(    sysinfo_dmi 'baseboard-product-name'  )
  sysinfo["hw_${dmi}_vers"]=$(    sysinfo_dmi 'baseboard-version'       )
  sysinfo["hw_${dmi}_sn"]=$(      sysinfo_dmi 'baseboard-serial-number' )
  #
  cpu_devices=$( find /sys/devices/system/cpu/cpu? | xargs basename )  
  for cpu in $cpu_devices
  do
    sysinfo["hw-${cpu}-model"]=$( sysinfo_cpu 'model name\s*: \K(.*)' )
    sysinfo["hw-${cpu}-speed"]=$( sysinfo_cpu 'cpu MHz\s*: \K(.*)'    )
    sysinfo["hw-${cpu}-lsize"]=$( sysinfo_cpu 'cache size\s*: \K(.*)' )
    sysinfo["hw-${cpu}-cores"]=$( sysinfo_cpu 'cpu cores\s*: \K(.*)'  )
  done
  #
  mem='mem'
  sysinfo["hw-${mem}-total"]=$(   sysinfo_mem 'MemTotal: \K(.*)'   )
  sysinfo["hw-${mem}-free"]=$(    sysinfo_mem 'MemFree: \K(.*)'    )
  #
  disks=$(find /sys/block/sd? /sys/block/hd? 2>/dev/null | xargs basename)
  for hdd in $disks
  do
    sysinfo["hw-${hdd}-model"]=$( sysinfo_hdd 'Model Number: \K(.*)'      )
    sysinfo["hw-${hdd}-sn"]=$(    sysinfo_hdd 'Serial Number: \K(.*)'     )
    sysinfo["hw-${hdd}-firm"]=$(  sysinfo_hdd 'Firmware Revision: \K(.*)' )
    sysinfo["hw-${hdd}-size"]=$(  sysinfo_hdd 'size with M = 1024\*1024:\s*\K(\S*)' )
    sysinfo["hw-${hdd}-speed"]=$( sysinfo_hdd 'Serial Number')
  done
  #
  network_devices=$( find /sys/class/net/en* | xargs basename )
  for nic in network_devices
  do
    sysinfo["hw-${nic}-product"]=$(sysinfo-net 'product: \K(.*)'     )
    sysinfo["hw-${nic}-vendor"]=$( sysinfo-net 'vendor: \K(.*)'      )
    sysinfo["hw-${nic}-name"]=$(   sysinfo-net 'logical name: \K(.*)')
    sysinfo["hw-${nic}-serial"]=$( sysinfo-net 'serial: \K(.*)'      )
    sysinfo["hw-${nic}-speed"]=$(  sysinfo-net 'size: \K(.*)'        )
  done
  #
  for key in "${!sysinfo[@]}"; do
      printf "%-16s: %s\n" "$key" "${sysinfo[$key]}"
  done | sort
  #
  ls
  # carte graphique:  sudo lshw -C display
  sysinfo["hw_${gpu}_desc"]= $(    sysinfo-gpu 'description: \K(.*)'  )
  sysinfo["hw_${gpu}_product"]= $( sysinfo-gpu 'product: \K(.*)'      )
  sysinfo["hw_${gpu}_vendor"]= $(  sysinfo-gpu 'vendor: \K(.*)'       )
  sysinfo["hw_${gpu}_vers"]= $(    sysinfo-gpu 'version: \K(.*)'      )
  sysinfo["hw_${gpu}_width"]= $(   sysinfo-gpu 'width: \K(.*)'        )
  sysinfo["hw_${gpu}_clock"]= $(   sysinfo-gpu 'clock: \K(.*)'        )
  # 
  # cdrom
  cat /proc/sys/dev/cdrom/info | grep 
 'drive name:\s*\K(.*)'
 'drive speed:\s*\K(.*)'
 # usb
 # 
}
#--------1---------2---------3---------4---------5---------6---------7---------8
## Briefs:
##   - DE: Hauptprogramm, Tests Verarbeitung
##   - EN: Main programm, tests processing
##   - ES: Programa principal, tratamiento de los juegos de pruebas
##   - FR: Programme principal, traitement des jeux de tests
##   - IT: Programma principale, trattamento di test gioco
## Usages: |
##   sysinfo.sh -ut <function_name> run tests of this function_name
##   sysinfo.sh -ut                 run tests of all library functions
## Comments: |
##
[[ ${LOGGER_SH++} ]] || source logger.sh
[[ ${ASSERT_SH++} ]] || source assert.sh
assert_lib "$(basename $0)" "$(basename $BASH_SOURCE)" "$1" "$2"
SYSINFO_SH=true
#--------1---------2---------3---------4---------5---------6---------7---------8

#!/QOpenSys/pkgs/bin/bash
set -u

LIBRARY=$1
DEBUG_VIEW=${2:-*LIST}

BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $BASE_DIR
echo "Building from $BASE_DIR"
echo ""
rm -rf .logs
mkdir -p .logs

run(){
  local command=$1
  local ifsFile=$2
  local noStmf=${3:-0}

  local output=".logs/$(basename $ifsFile).splf"
  local srcStmf=$([[ $noStmf -eq 0 ]] && echo "SRCSTMF('$ifsFile')" || echo "")

  echo -n "Building $ifsFile..."  
  cl -q "$command $srcStmf" > $output && echo ✅ || echo ❌
}

run "CRTBNDRPG PGM($LIBRARY/DEBUGME) OPTION(*EVENTF) DBGVIEW($DEBUG_VIEW) TGTCCSID(*JOB)" "debugme.pgm.rpgle"
run "CRTRPGMOD MODULE($LIBRARY/DEBUGSVCS) OPTION(*EVENTF) DBGVIEW($DEBUG_VIEW) TGTCCSID(*JOB)" "debug_services.rpgle"
run "CRTSRVPGM SRVPGM($LIBRARY/DEBUGSVCS) EXPORT(*ALL) ACTGRP(*CALLER) TGTRLS(*CURRENT)" "debug_services.ilesrvpgm" 1

run "CRTBNDRPG PGM($LIBRARY/WAITME) OPTION(*EVENTF) DBGVIEW($DEBUG_VIEW) TGTCCSID(*JOB)" "waitme.pgm.rpgle"

run "CRTCLMOD MODULE($LIBRARY/GETLIBL) OPTION(*EVENTF) DBGVIEW($DEBUG_VIEW) TGTCCSID(*JOB)" "getlibl.clle"
run "CRTRPGMOD MODULE($LIBRARY/MAINMODULE) OPTION(*EVENTF) DBGVIEW($DEBUG_VIEW) TGTCCSID(*JOB)" "mainmodule.rpgle"
run "CRTPGM PGM($LIBRARY/DEBUGMETOO) MODULE($LIBRARY/MAINMODULE $LIBRARY/GETLIBL) ENTMOD($LIBRARY/MAINMODULE) BNDSRVPGM(($LIBRARY/DEBUGSVCS)) ACTGRP(DEBUG)" "debugmetoo.ilepgm" 1
run "RUNSQLSTM COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL($LIBRARY) OUTPUT(*PRINT)" "ifspath.sqludf"
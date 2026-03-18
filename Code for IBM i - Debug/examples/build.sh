#!/QOpenSys/pkgs/bin/bash
BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $BASE_DIR
echo "Building from $BASE_DIR"
echo ""
rm -rf .logs
mkdir -p .logs

echo -n "Building debugme.pgm.rpgle..."
(system -q "CRTBNDRPG PGM($1/debugme) SRCSTMF('debugme.pgm.rpgle') OPTION(*EVENTF) DBGVIEW(*LIST) TGTCCSID(*JOB)" > .logs/debugme.rpgle.splf) && echo ✅ || echo ❌

echo -n "Building getlibl.clle..."
(system -q "CRTCLMOD MODULE($1/GETLIBL) SRCSTMF('getlibl.clle') OPTION(*EVENTF) DBGVIEW(*LIST) TGTCCSID(*JOB)" > .logs/getlibl.clle.splf) && echo ✅ || echo ❌
echo -n "Building mainmodule.rpgle..."
(system -q "CRTRPGMOD MODULE($1/MAINMODULE) SRCSTMF('mainmodule.rpgle') OPTION(*EVENTF) DBGVIEW(*LIST) TGTCCSID(*JOB)" > .logs/mainmodule.rpgle.splf) && echo ✅ || echo ❌
echo -n "Building DEBUGMETOO program..."
(system -q "CRTPGM PGM($1/DEBUGMETOO) MODULE($1/MAINMODULE $1/GETLIBL) ENTMOD($1/MAINMODULE) ACTGRP(DEBUG)" > .logs/debugmetoo.ilepgm) && echo ✅ || echo ❌

echo -n "Building IFS_PATH SQL function..."
(system -q "RUNSQLSTM SRCSTMF('ifspath.sqludf') COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL($1)" > .logs/ifspath.sqludf) && echo ✅ || echo ❌
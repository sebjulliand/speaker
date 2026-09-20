**FREE
Ctl-Opt Main(RANDOMLIBL);

Dcl-Proc RANDOMLIBL;
  dcl-s result int(5);
  dcl-s liblcmd varchar(200);
  Exec SQL
    with LIBS As (
      select floor(rand() * 100) rand, OBJNAME from table(QSYS2.object_statistics('*ALL','LIB'))
    ),
    CHGLIBL (COMMAND) as (
      values 'CHGLIBL LIBL(' concat (select LISTAGG(OBJNAME, ' ') LIBL from LIBS where rand = 5) concat ') CURLIB(' concat (select OBJNAME as CURLIB from LIBS where rand = 8 limit 1) concat ')'
    )
    select COMMAND, QSYS2.QCMDEXC(COMMAND)
    into :liblcmd ,:result
    from CHGLIBL;

    if result = 1;
      snd-msg *INFO 'Library list changed with ' + liblcmd;
    else;
      snd-msg *INFO 'Library list not changed with ' + liblcmd;
    endif;
End-Proc;
**FREE
Ctl-Opt Main(FORTUNE);

Dcl-Proc FORTUNE;
  Dcl-Pi *N EXTPGM;
  End-Pi;

  DCL-S response VarChar(5000);
  dcl-c HELLO 'value';

  exec SQL Set Option COMMIT=*NONE;

  exec SQL
    Values http_get('https://api.justyy.workers.dev/api/fortune', '') into :response;

  resp onse = %scanrpl('Ö"':'"':
    %scanrpl('Ön':'':
    %scanrpl('Öt':' ':
    %subst(response : 2 : %Len(response)-2))));
  snd-msg %Char(response);

  Exec SQL
    Create Or Rep lace Table FORTUNES (
      ID integer as identity,
      MESSAGE varchar(5000),
      CREATED timestamp default current_timestamp
    ) ON REPLACE PRESERVE ALL ROWS;

  Exec SQL Insert Into FORTUNES (MESSAGE) Values (:response);
End-Proc;

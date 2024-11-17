**FREE
//Inspired from https://www.rpgpgm.com/2023/09/creating-spool-file-from-modern-rpg.html
//TODO:
//  - Split joke if length > 115
//  - Give beter name to spooled file
//  - Log SQL errors
Ctl-Opt Main(JOKESPOOL) dftactgrp(*no);

dcl-f QSYSPRT printer(132) oflind(PageOverflow) prtctl(PrtCtlDS);
dcl-s PageOverflow ind ;
dcl-s Count uns(5) ;
dcl-ds PrtCtlDS qualified len(15) ;
  SpaceBefore char(3) inz('  0') ;
  SpaceAfter char(3) inz('  1') ;
  SkipBefore char(3) inz('  0') ;
  SkipAfter char(3) inz('  0') ;
end-ds ;
  
dcl-ds Output qualified len(132) ;
    // Headings
  Title char(132) pos(1) ;
  PageWord char(4) pos(82) ;
  PageChar char(4) pos(86) ;
    // Details
  Id char(11) pos(3) ;
  Joke char(115) pos(16) ;
end-ds ;

dcl-c PageHeading 'Dad jokes to spooled file';
dcl-c ColHeading1 '  ID           Joke';
dcl-c ColHeading2 '  -----------  -------------------------------------------------------------------------------------------------------------------';

Dcl-Proc JOKESPOOL;
  Dcl-Pi *N;
    e_howMany char(2);
  End-Pi;

  dcl-s w_howMany int(5);
  dcl-s w_tries int(5);
  
  w_howMany = %int(%trim(e_howMany));
  NextPage() ;

  dow (w_tries < w_howMany) ;
    Exec SQL
      select
        json_value(response_message, '$.id' returning varchar(11)),
        json_value(response_message, '$.joke' returning varchar(115))
      into
        :Output.Id,
        :Output.joke
      from table (qsys2.http_get_verbose('https://icanhazdadjoke.com',
        json_object(
          'headers': json_object('accept': 'application/json' )
        )
      ));

    if (SQLCOD = 0) ;
      WriteOutput();
      Count += 1 ;
    endif ;

    w_tries +=1;
  enddo ;

  Clear Output;
  Output.Title = ColHeading2;
  WriteOutput();
  
  Output.Title = '  Jokes count = ' + %char(Count) ;
  WriteOutput();
End-Proc;

dcl-proc WriteOutput ;
  if (PageOverflow) ;
    NextPage() ;
  endif ;
  write QSYSPRT Output ;
end-proc;

dcl-proc NextPage ;
  dcl-s PageNumber uns(3) static ;

  if (PageOverflow) ;
    PrtCtlDS.SkipBefore = '  1' ;
  endif ;

  Output.PageWord = 'Page' ;
  PageNumber += 1 ;
  evalr Output.PageChar = %char(PageNumber) ;

  Output.Title = PageHeading ;
  write QSYSPRT Output ;
  clear Output ;

  if (PageOverflow) ;
    reset PrtCtlDS ;
    PageOverflow = *off ;
  endif ;

  Output.Title = ColHeading1 ;
  write QSYSPRT Output ;
  Output.Title = ColHeading2 ;
  write QSYSPRT Output ;
  clear Output ;
end-proc ;
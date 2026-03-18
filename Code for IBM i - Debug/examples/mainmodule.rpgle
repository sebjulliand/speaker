**FREE
Ctl-Opt Main(DEBUGMETOO);

dcl-pr GetLibraryList EXTPROC('GETLIBL');
  ou_library_list char(2750);
end-pr;


Dcl-Proc DEBUGMETOO;
  dcl-ds library_list dim(250) Qualified;
    library char(10);
    *n char(1);
  end-ds;

  dcl-s libraryCount int(5);

  libraryCount = %lookup('          ':library_list(*).library);

  snd-msg 'There are ' + %char(libraryCount) + 'libraries in the list';
End-Proc;
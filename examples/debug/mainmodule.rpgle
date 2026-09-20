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
  dcl-s index int(5);
  dcl-s buffer Char(2750) Based(pBuffer);

  pBuffer = %Addr(library_list);
  GetLibraryList(buffer);
  libraryCount = %lookup('          ':library_list(*).library) - 1;

  snd-msg 'There are ' + %char(libraryCount) + ' libraries in the list';

  for index = 1 to libraryCount;
    snd-msg 'Library ' + %char(index) + ' : ' + library_list(index);
  endFor;
End-Proc;
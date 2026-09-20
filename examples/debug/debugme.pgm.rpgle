**FREE
Ctl-Opt Main(DEBUGME) DftActGrp(*No) ActGrp('DEBUG');

Dcl-Proc DEBUGME;
  Dcl-Pi *N;
    in_message Char(32);
    in_howmany packed(15:5);
  End-Pi;

  dcl-s w_output varchar(22);
  dcl-s index int(5); 

  w_output = %trim(in_message);
  snd-msg w_output;
  for index = 0 to %int(in_howmany);
    w_output = %trim(in_message) + ' ' + %char(index);
    snd-msg w_output;
  endfor;
End-Proc;
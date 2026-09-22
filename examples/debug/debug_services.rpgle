**FREE
Ctl-Opt NoMain;

/include 'debug_services.rpgleinc'

Dcl-Proc Divide export;
  Dcl-Pi *N;
    in_num1 packed(15:5) const;
    in_num2 packed(15:5) const;
  End-Pi;
  
  dcl-s total packed(15:5);

  snd-msg *INFO 'Dividing ' + %char(in_num1) + ' by ' + %char(in_num2);
  total = in_num1 / in_num2;
  snd-msg *INFO 'Result is ' + %char(total);
End-Proc;
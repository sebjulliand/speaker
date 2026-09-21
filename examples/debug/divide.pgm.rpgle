**FREE
Ctl-Opt Main(KABOOM);

Dcl-Proc KABOOM;
  Dcl-Pi *N;
    in_num1 packed(15:5);
    in_num2 packed(15:5);
  End-Pi;
  
  dcl-s total packed(15:5);

  snd-msg *INFO 'Dividing ' + %char(in_num1) + ' by ' + %char(in_num2);
  total = in_num1 / in_num2;
  snd-msg *INFO 'Result is ' + %char(total);
End-Proc;
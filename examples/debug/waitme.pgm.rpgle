**FREE
Ctl-Opt Main(WAITME);

dcl-pr QCMDEXC EXTPGM('QCMDEXC');
  in_command char(32000) const;
  in_length packed(15:5) const;
end-pr;

Dcl-Proc WAITME;
  Dcl-Pi *N;
    in_loops packed(15:5);
  End-Pi;

  dcl-s loops int(5);
  dcl-s current int(5) inz(0);

  snd-msg *INFO 'Going in for ' + %char(in_loops) + ' waiting loop(s)!';
  for loops = %int(in_loops) downto 0;
    snd-msg *INFO %char(loops) + ' loop(s) remaining...';
    QCMDEXC('DLYJOB 5':8);   
  endfor;
  snd-msg *INFO 'Done; bye!';
End-Proc;
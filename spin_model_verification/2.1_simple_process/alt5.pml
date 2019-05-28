// alt5.pml
mtype = { F, S, N };
mtype turn = F;
pid who;        

active [2] proctype Producer()
{
  do
  :: atomic {
      (turn == F) -> turn = N;
                     who = _pid;	
    };
    printf("Producer-%d\n", _pid);
    assert(who == _pid);         
    atomic {
      turn = S;
      who = 0;	
    }	
  od
}

active [2] proctype Consumer()
{
  do
  :: atomic {
    (turn == S) -> turn = F;
                   who = _pid;  
    };
    printf("Consumer-%d\n", _pid);
    assert(who == _pid);              
    turn = F;
  od
}

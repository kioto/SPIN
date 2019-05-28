// alt4.pml
mtype = { F, S };
mtype turn = F;
pid who;        

active [2] proctype Producer()
{
  do
  :: atomic {
    (turn == F) -> who = _pid
    };
    printf("Producer-%d\n", _pid);
    assert(who == _pid);         
    turn = S;
  od
}

active [2] proctype Consumer()
{
  do
  :: atomic {
    (turn == S) -> who = _pid;  
    };
    printf("Consumer-%d\n", _pid);
    assert(who == _pid);              
    turn = F;
  od
}

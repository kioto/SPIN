// alt3.pml
mtype = { F, S, N };
mtype turn = F;

active [2] proctype Producer()
{
  do
  :: atomic {
    (turn == F) -> turn = N
    };
    printf("Producer-%d\n", _pid);
    turn = S;
  od
}

active [2] proctype Consumer()
{
  do
  :: atomic {
    (turn == S) -> turn = N
    };
    printf("Consumer-%d\n", _pid);
    turn = F;
  od
}

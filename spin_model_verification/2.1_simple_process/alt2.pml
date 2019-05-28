// alt2.pml
mtype = { F, S };
mtype turn = F;

active [2] proctype Producer()
{
  do
  :: (turn == F) -> printf("Producer\n");
                    turn = S;

  od
}

active [2] proctype Consumer()
{
  do
  :: (turn == S) -> printf("Consumer\n");
                    turn = F;
  od
}

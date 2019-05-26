// fsm.pml
int x=0;

active proctype P() {
  do
  :: true  -> x = x + 1; assert(x <= 5)
  :: x > 0 -> x = x - 1
  od
}

// fsm_ltl.pml
int x=0;

active proctype P() {
  do
  :: true  -> x = x + 1; assert(x <= 5)
  :: x > 0 -> x = x - 1
  od
}

ltl p0 {[](x <= 5)}    // (x <= 5)が常に成り立つ

// ex.4.1 sync_system.pml

ltl p0 {[] !(robot == OFF) -> <>(robot == ON)}
//ltl p1 {[] (robot == ON ) -> <>(robot == OFF)}

mtype = {GREEN, RED, BLUE, ON, OFF};
mtype a=GREEN;
mtype b=GREEN;
mtype robot=OFF;
mtype Na, Nb, Nrobot;

active proctype robo()
{
  do
  ::true ->
    if	// 次の瞬間のAの状態を決定
    :: (b == RED)   -> Na = a
    :: (a == GREEN) -> Na = RED
    :: (a == RED)   -> Na = BLUE
    :: (a == BLUE)  -> Na = GREEN
    fi;

    if	// 次の瞬間のBの状態を決定
    :: (a == b) -> Nb = b
    :: else ->
      if
      :: (b == GREEN) -> Nb = RED
      :: (b == RED)   -> Nb = BLUE
      :: (b == BLUE)  -> Nb = GREEN
      fi
    fi;

    if	// 次の瞬間のrobotの動作を決定
    :: (a == BLUE && b == BLUE) -> Nrobot = ON
    :: (a == RED  && b == RED ) -> Nrobot = OFF
    :: else                     -> Nrobot = robot
    fi;

    // 値の更新
    a = Na
    b = Nb
    robot = Nrobot
  od
}

# 2.1 簡単な並列実行プロセス

本文署は、書籍に掲載されているサンプルに対し、ちょっと修正、加筆したメモ。s詳細は原著を参照。

## 2.1.1 Promelaプロセスの基本

ProducerとCusumerが交互に入れ替わるモデル`alt1.pml`を用意する。

```c
1	// alt1.pml
2	mtype = { F, S };
3	mtype turn = F;
4
5	active proctype Producer()
6	{
7	  do
8	  :: (turn == F) -> printf("Producer\n");
9	                    turn = S;
10
11	  od
12	}
13
14	active proctype Consumer()
15	{
16	  do
17	  :: (turn == S) -> printf("Consumer\n");
18	                    turn = F;
19	  od
20	}
```

`alt1.pml`のシミュレーションを実行する。<br>
深さ（SPINの内部ステップ数）を100とする。

```sh
$ spin -u100 alt1.pml
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
          Consumer
      Producer
-------------
depth-limit (-u100 steps) reached
#processes: 2
		turn = S
100:	proc  1 (Consumer:1) alt1.pml:16 (state 4)
100:	proc  0 (Producer:1) alt1.pml:7 (state 4)
2 processes created
$
```

## 2.1.2 プロセス数の増加

alt1.pmlからプロセスをそれぞれ２つにした、４プロセスのモデル`alt2.pml`を用意する。

```c
1	// alt2.pml
2	mtype = { F, S };
3	mtype turn = F;
4
5	active [2] proctype Producer()
6	{
7	  do
8	  :: (turn == F) -> printf("Producer\n");
9	                    turn = S;
10
11	  od
12	}
13
14	active [2] proctype Consumer()
15	{
16	  do
17	  :: (turn == S) -> printf("Consumer\n");
18	                    turn = F;
19	  od
20	}
```

のシミュレーションを実行する。

```sh
$ spin -u100 alt2.pml
          Producer
      Producer
                  Consumer
              Consumer
      Producer
              Consumer
          Producer
      Producer
                  Consumer
              Consumer
          Producer
      Producer
              Consumer
                  Consumer
          Producer
      Producer
              Consumer
                  Consumer
          Producer
      Producer
              Consumer
      Producer
              Consumer
          Producer
                  Consumer
      Producer
-------------
depth-limit (-u100 steps) reached
#processes: 4
		turn = F
100:	proc  3 (Consumer:1) alt2.pml:16 (state 4)
100:	proc  2 (Consumer:1) alt2.pml:16 (state 4)
100:	proc  1 (Producer:1) alt2.pml:9 (state 3)
100:	proc  0 (Producer:1) alt2.pml:9 (state 3)
4 processes created
$
```

プロセスの識別をつけたalt3.pmlを用意。

```c
1	// alt3.pml
2	mtype = { F, S, N };
3	mtype turn = F;
4
5	active [2] proctype Producer()
6	{
7	  do
8	  :: atomic {
9	    (turn == F) -> turn = N
10	    };
11	    printf("Producer-%d\n", _pid);
12	    turn = S;
13	  od
14	}
15
16	active [2] proctype Consumer()
17	{
18	  do
19	  :: atomic {
20	    (turn == S) -> turn = N
21	    };
22	    printf("Consumer-%d\n", _pid);
23	    turn = F;
24	  od
25	}
```

`alt3.pml`のシミュレーションを実行する。

```sh
$ spin -u100 alt3.pml
          Producer-1
              Consumer-2
      Producer-0
              Consumer-2
      Producer-0
                  Consumer-3
      Producer-0
                  Consumer-3
          Producer-1
              Consumer-2
      Producer-0
                  Consumer-3
      Producer-0
              Consumer-2
          Producer-1
              Consumer-2
          Producer-1
                  Consumer-3
      Producer-0
                  Consumer-3
-------------
depth-limit (-u100 steps) reached
#processes: 4
		turn = F
100:	proc  3 (Consumer:1) alt3.pml:25 (state 7)
100:	proc  2 (Consumer:1) alt3.pml:18 (state 6)
100:	proc  1 (Producer:1) alt3.pml:7 (state 6)
100:	proc  0 (Producer:1) alt3.pml:9 (state 2)
4 processes created
$
```

## 2.1.3 不具合の自動県地方 - assert文

不具合を自動的に検知する、assert文を使用した方法を示す。<br>
まずalt3.pmlにasseert文を挿入したalt4.pmlを示す。

```c
1	// alt4.pml
2	mtype = { F, S };
3	mtype turn = F;
4	pid who;
5
6	active [2] proctype Producer()
7	{
8	  do
9	  :: atomic {
10	    (turn == F) -> who = _pid
11	    };
12	    printf("Producer-%d\n", _pid);
13	    assert(who == _pid);
14	    turn = S;
15	  od
16	}
17
18	active [2] proctype Consumer()
19	{
20	  do
21	  :: atomic {
22	    (turn == S) -> who = _pid;
23	    };
24	    printf("Consumer-%d\n", _pid);
25	    assert(who == _pid);
26	    turn = F;
27	  od
28	}
```

検出器を生成する。

```sh
$ spin -a alt4.pml
$ gcc pan.c -o alt4
$ ./alt4
pan:1: assertion violated (who==_pid) (at depth 13)
pan: wrote alt4.pml.trail

(Spin Version 6.4.8 -- 2 March 2018)
Warning: Search not completed
	+ Partial Order Reduction

Full statespace search for:
	never claim         	- (none specified)
	assertion violations	+
	acceptance   cycles 	- (not selected)
	invalid end states	+

State-vector 44 byte, depth reached 13, errors: 1
       14 states, stored
        2 states, matched
       16 transitions (= stored+matched)
        0 atomic steps
hash conflicts:         0 (resolved)

Stats on memory usage (in Megabytes):
    0.001	equivalent memory usage for states (stored*(State-vector + overhead))
    0.291	actual memory usage for states
  128.000	memory used for hash table (-w24)
    0.534	memory used for DFS stack (-m10000)
  128.730	total actual memory usage



pan: elapsed time 0 seconds
$ ls *.trail
alt4.pml.trail
$
```
assertion violatedとなっていて、trailファイルが生成されていることを確認した。<br>
spinコマンドで`-t`オプションを指定して、trailファイルを使用したガイド付きシミュレーションを実行する。また`-g`オプションで大域変数（turnとwho）の内容を表示する。

```sh
$ spin -t -g alt4.pml
using statement merging
          Producer-1
                  Consumer-3
      Producer-0
          Producer-1
                  Consumer-3
spin: alt4.pml:13, Error: assertion violated
spin: text of failed assertion: assert((who==_pid))
spin: trail ends after 14 steps
#processes: 4
		turn = F
		who = 3
 14:	proc  3 (Consumer:1) alt4.pml:20 (state 7)
 14:	proc  2 (Consumer:1) alt4.pml:20 (state 7)
 14:	proc  1 (Producer:1) alt4.pml:8 (state 7)
 14:	proc  0 (Producer:1) alt4.pml:14 (state 6)
4 processes created
$
```

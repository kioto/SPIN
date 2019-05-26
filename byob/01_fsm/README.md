# 1. 概要

本サンプルは、以下のURLから入手できる「BYOBモデル検査入門」で紹介され
たものを使用する。

BYOB によるモデル検査入門∗ 神戸大学人間発達環境学研究科<br>
高橋 真</br>
http://herb.h.kobe-u.ac.jp/byob/byobmodelcheck.pdf

# 2. Spinの実行

## 2-1. シミュレーションの実行

モデル`fsm.pml`の内容は以下の通り。
```c
1	// fsm.pml
2	int x=0;
3
4	active proctype P() {
5	  do
6	  :: true  -> x = x + 1; assert(x <= 5)
7	  :: x > 0 -> x = x - 1
8	  od
9	}
```

これをシミュレーション実行する。

```sh
$ spin fsm.pml
spin: fsm.pml:6, Error: assertion violated
spin: text of failed assertion: assert((x<=5))
#processes: 1
		x = 6
 86:	proc  0 (P:1) fsm.pml:6 (state 3)
1 process created
```

このように、assertionが成り立たない場合があることが表示される。

## 2-2. LTL式の追加と検証

PlomeraファイルにLTL式が記述できる。

```c
1	// fsm_ltl.pml
2	int x=0;
3
4	active proctype P() {
5	  do
6	  :: true  -> x = x + 1; assert(x <= 5)
7	  :: x > 0 -> x = x - 1
8	  od
9	}
10
11	ltl p0 {[](x <= 5)}    // (x <= 5)が常に成り立つ
```

検査器をビルドする。

```sh
$ spin -a fsm_ltl.pml
ltl p0: [] ((x<=5))
$ gcc -DMEMLIM=1024 -XUSAFE -w -o pan pan.c
$ ./pan -m10000 -a -N p0
warning: only one claim defined, -N ignored
pan:1: assertion violated  !( !((x<=5))) (at depth 34)
pan: wrote fsm_ltl.pml.trail

(Spin Version 6.4.8 -- 2 March 2018)
Warning: Search not completed
	+ Partial Order Reduction

Full statespace search for:
	never claim         	+ (p0)
	assertion violations	+ (if within scope of claim)
	acceptance   cycles 	+ (fairness disabled)
	invalid end states	- (disabled by never claim)

State-vector 28 byte, depth reached 34, errors: 1
       18 states, stored
        0 states, matched
       18 transitions (= stored+matched)
        0 atomic steps
hash conflicts:         0 (resolved)

Stats on memory usage (in Megabytes):
    0.001	equivalent memory usage for states (stored*(State-vector + overhead))
    0.291	actual memory usage for states
  128.000	memory used for hash table (-w24)
    0.534	memory used for DFS stack (-m10000)
  128.730	total actual memory usage



pan: elapsed time 0.01 seconds
$
```
trailファイル`fsm_ltl.pml.trail`が生成されるので、ガイド付きシミュレーションを実行できる。

```sh
$ spin -t fsm_ltl.pml
ltl p0: [] ((x<=5))
Never claim moves to line 4	[(1)]
spin: _spin_nvr.tmp:3, Error: assertion violated
spin: text of failed assertion: assert(!(!((x<=5))))
Never claim moves to line 3	[assert(!(!((x<=5))))]
spin: trail ends after 35 steps
#processes: 1
		x = 6
 35:	proc  0 (P:1) fsm_ltl.pml:6 (state 3)
 35:	proc  - (p0:1) _spin_nvr.tmp:2 (state 6)
1 processes created
$
```

以上

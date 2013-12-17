c SAT4J: a SATisfiability library for Java (c) 2004-2013 Artois University and CNRS
c This is free software under the dual EPL/GNU LGPL licenses.
c See www.sat4j.org for details.
c version 2.3.5.v20130525
c java.runtime.name	OpenJDK Runtime Environment
c java.vm.name		OpenJDK Server VM
c java.vm.version	20.0-b12
c java.vm.vendor	Sun Microsystems Inc.
c sun.arch.data.model	32
c java.version		1.6.0_27
c os.name		Linux
c os.version		3.2.0-38-generic-pae
c os.arch		i386
c Free memory 		62627016
c Max memory 		954466304
c Total memory 		64356352
c Number of processors 	8
c Pseudo Boolean Optimization by upper bound
c c --- Begin Solver configuration ---
c org.sat4j.pb.constraints.CompetResolutionPBLongMixedWLClauseCardConstrDataStructure@16b13c7
c Learn all clauses as in MiniSAT
c claDecay=0.999 varDecay=0.95 conflictBoundIncFactor=1.5 initConflictBound=100 
c VSIDS like heuristics from MiniSAT using a heap lightweight component caching from RSAT taking into account the objective function
c No reason simplification
c Glucose 2.1 dynamic restart strategy
c Glucose 2 learned constraints deletion strategy
c timeout=2147483s
c DB Simplification allowed=false
c Listener: org.sat4j.minisat.core.VoidTracing@1749757
c --- End Solver configuration ---
c solving /home/tamkin/ResearchWorkSpace/EncodingGenerator/PBEncoding/CostMatrixGenerator/BenchMarks/4_Nodes/PBencd_RandomCost.opb
c reading problem ... 
c ... done. Wall clock time 0.087s.
c declared #vars     64
c #constraints  34
c constraints type 
c org.sat4j.minisat.constraints.cnf.OriginalWLClause => 8
c org.sat4j.minisat.constraints.card.MinWatchCard => 8
c ignored satisfied constraints => 14
c org.sat4j.pb.constraints.pb.MaxWatchPbLong => 18
c 48 constraints processed.
c objective function length is 12 literals
c SATISFIABLE
c OPTIMIZING...
c Got one! Elapsed wall clock time (in seconds):0.169
o 143
c starts		: 2
c conflicts		: 74
c decisions		: 105
c propagations		: 896
c inspects		: 3080
c shortcuts		: 0
c learnt literals	: 1
c learnt binary clauses	: 1
c learnt ternary clauses	: 2
c learnt constraints	: 72
c ignored constraints	: 0
c root simplifications	: 0
c removed literals (reason simplification)	: 0
c reason swapping (by a shorter reason)	: 0
c Calls to reduceDB	: 0
c Number of update (reduction) of LBD	: 12
c Imported unit clauses	: 0
c number of reductions to clauses (during analyze)	: 0
c number of learned constraints concerned by reduction	: 0
c number of learning phase by resolution	: 0
c number of learning phase by cutting planes	: 0
c speed (assignments/second)	: 15719.298245614034
c non guided choices	27
c learnt constraints type 
c constraints type 
c org.sat4j.minisat.constraints.cnf.OriginalWLClause => 8
c org.sat4j.minisat.constraints.card.MinWatchCard => 8
c ignored satisfied constraints => 14
c org.sat4j.pb.constraints.pb.MaxWatchPbLong => 18
c 48 constraints processed.
s OPTIMUM FOUND
c Found 1 solution(s)
v -x1 -x2 x3 -x4 x5 -x6 x7 -x8 -x9 -x10 x11 -x12 x13 -x14 x15 x16 x17 x18 -x19 x20 -x21 -x22 x23 x24 x25 x26 x27 x28 x29 -x30 -x31 -x32 -x33 x34 -x35 -x36 x37 -x38 -x39 -x40 x41 -x42 x43 -x44 -x45 -x46 -x47 -x48 x49 x50 x51 -x52 -x53 -x54 -x55 -x56 -x57 x58 -x59 -x60 -x61 x62 x63 -x64 
c objective function=143
c Total wall clock time (in seconds): 0.176

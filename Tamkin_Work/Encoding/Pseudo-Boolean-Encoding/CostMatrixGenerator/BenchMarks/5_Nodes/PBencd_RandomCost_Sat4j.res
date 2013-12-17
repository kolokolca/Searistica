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
c org.sat4j.pb.constraints.CompetResolutionPBLongMixedWLClauseCardConstrDataStructure@df8f5e
c Learn all clauses as in MiniSAT
c claDecay=0.999 varDecay=0.95 conflictBoundIncFactor=1.5 initConflictBound=100 
c VSIDS like heuristics from MiniSAT using a heap lightweight component caching from RSAT taking into account the objective function
c No reason simplification
c Glucose 2.1 dynamic restart strategy
c Glucose 2 learned constraints deletion strategy
c timeout=2147483s
c DB Simplification allowed=false
c Listener: org.sat4j.minisat.core.VoidTracing@17bd6a1
c --- End Solver configuration ---
c solving /home/tamkin/ResearchWorkSpace/EncodingGenerator/PBEncoding/CostMatrixGenerator/BenchMarks/5_Nodes/PBencd_RandomCost.opb
c reading problem ... 
c ... done. Wall clock time 0.03s.
c declared #vars     104
c #constraints  52
c constraints type 
c org.sat4j.minisat.constraints.cnf.OriginalWLClause => 10
c org.sat4j.minisat.constraints.card.MinWatchCard => 10
c ignored satisfied constraints => 22
c org.sat4j.pb.constraints.pb.MaxWatchPbLong => 32
c 74 constraints processed.
c objective function length is 20 literals
c SATISFIABLE
c OPTIMIZING...
c Got one! Elapsed wall clock time (in seconds):0.048
o 73
c starts		: 2
c conflicts		: 73
c decisions		: 179
c propagations		: 1130
c inspects		: 4523
c shortcuts		: 0
c learnt literals	: 2
c learnt binary clauses	: 1
c learnt ternary clauses	: 3
c learnt constraints	: 70
c ignored constraints	: 0
c root simplifications	: 0
c removed literals (reason simplification)	: 0
c reason swapping (by a shorter reason)	: 0
c Calls to reduceDB	: 0
c Number of update (reduction) of LBD	: 11
c Imported unit clauses	: 0
c number of reductions to clauses (during analyze)	: 0
c number of learned constraints concerned by reduction	: 0
c number of learning phase by resolution	: 0
c number of learning phase by cutting planes	: 0
c speed (assignments/second)	: 33235.294117647056
c non guided choices	85
c learnt constraints type 
c constraints type 
c org.sat4j.minisat.constraints.cnf.OriginalWLClause => 10
c org.sat4j.minisat.constraints.card.MinWatchCard => 10
c ignored satisfied constraints => 22
c org.sat4j.pb.constraints.pb.MaxWatchPbLong => 32
c 74 constraints processed.
s OPTIMUM FOUND
c Found 1 solution(s)
v x1 -x2 -x3 -x4 -x5 -x6 -x7 x8 x9 -x10 -x11 -x12 -x13 -x14 x15 -x16 -x17 -x18 -x19 x20 -x21 x22 -x23 x24 x25 x26 -x27 x28 -x29 -x30 -x31 x32 x33 x34 x35 -x36 -x37 -x38 x39 x40 -x41 -x42 -x43 -x44 -x45 x46 -x47 -x48 x49 -x50 -x51 -x52 -x53 x54 x55 -x56 x57 x58 -x59 -x60 x61 -x62 -x63 -x64 -x65 -x66 -x67 -x68 -x69 -x70 -x71 -x72 x73 -x74 -x75 -x76 x77 x78 x79 -x80 x81 x82 -x83 -x84 -x85 -x86 -x87 x88 x89 x90 x91 -x92 -x93 -x94 -x95 x96 -x97 -x98 -x99 -x100 x101 -x102 -x103 x104 
c objective function=73
c Total wall clock time (in seconds): 0.069

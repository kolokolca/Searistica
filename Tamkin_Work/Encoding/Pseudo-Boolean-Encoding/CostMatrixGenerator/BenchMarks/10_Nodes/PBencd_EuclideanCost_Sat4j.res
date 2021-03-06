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
c solving /home/tamkin/ResearchWorkSpace/EncodingGenerator/PBEncoding/CostMatrixGenerator/BenchMarks/10_Nodes/PBencd_EuclideanCost.opb
c reading problem ... 
c ... done. Wall clock time 0.113s.
c declared #vars     545
c #constraints  202
c constraints type 
c org.sat4j.minisat.constraints.cnf.OriginalWLClause => 20
c org.sat4j.minisat.constraints.card.MinWatchCard => 20
c ignored satisfied constraints => 92
c org.sat4j.pb.constraints.pb.MaxWatchPbLong => 162
c 294 constraints processed.
c objective function length is 90 literals
c SATISFIABLE
c OPTIMIZING...
c Got one! Elapsed wall clock time (in seconds):0.255
o 480
c Got one! Elapsed wall clock time (in seconds):0.285
o 391
c Got one! Elapsed wall clock time (in seconds):0.299
o 353
c Got one! Elapsed wall clock time (in seconds):0.338
o 322
c Got one! Elapsed wall clock time (in seconds):0.345
o 266
c Got one! Elapsed wall clock time (in seconds):0.353
o 263
c Got one! Elapsed wall clock time (in seconds):0.357
o 240
c Got one! Elapsed wall clock time (in seconds):0.366
o 239
c Got one! Elapsed wall clock time (in seconds):0.386
o 235
c Got one! Elapsed wall clock time (in seconds):0.424
o 231
c Got one! Elapsed wall clock time (in seconds):0.428
o 229
c Got one! Elapsed wall clock time (in seconds):0.433
o 227
c Got one! Elapsed wall clock time (in seconds):0.455
o 226
c cleaning 3826 clauses out of 7653 with flag 12486/7653
c starts		: 26
c conflicts		: 13595
c decisions		: 21150
c propagations		: 226438
c inspects		: 1900790
c shortcuts		: 0
c learnt literals	: 6
c learnt binary clauses	: 9
c learnt ternary clauses	: 9
c learnt constraints	: 13588
c ignored constraints	: 0
c root simplifications	: 0
c removed literals (reason simplification)	: 0
c reason swapping (by a shorter reason)	: 0
c Calls to reduceDB	: 1
c Number of update (reduction) of LBD	: 2682
c Imported unit clauses	: 0
c number of reductions to clauses (during analyze)	: 0
c number of learned constraints concerned by reduction	: 0
c number of learning phase by resolution	: 0
c number of learning phase by cutting planes	: 0
c speed (assignments/second)	: 288456.050955414
c non guided choices	1086
c learnt constraints type 
c constraints type 
c org.sat4j.minisat.constraints.cnf.OriginalWLClause => 20
c org.sat4j.minisat.constraints.card.MinWatchCard => 20
c ignored satisfied constraints => 92
c org.sat4j.pb.constraints.pb.MaxWatchPbLong => 162
c 294 constraints processed.
s OPTIMUM FOUND
c Found 13 solution(s)
v x1 -x2 -x3 -x4 -x5 -x6 -x7 -x8 -x9 -x10 -x11 -x12 x13 -x14 -x15 -x16 -x17 -x18 x19 -x20 -x21 -x22 -x23 -x24 -x25 -x26 -x27 -x28 -x29 -x30 -x31 -x32 -x33 -x34 x35 -x36 -x37 -x38 -x39 -x40 -x41 -x42 -x43 -x44 x45 -x46 -x47 -x48 x49 -x50 -x51 -x52 -x53 -x54 -x55 -x56 x57 -x58 -x59 -x60 -x61 -x62 -x63 -x64 -x65 -x66 -x67 -x68 -x69 x70 -x71 -x72 -x73 -x74 -x75 -x76 -x77 -x78 -x79 x80 -x81 -x82 -x83 -x84 -x85 -x86 x87 -x88 -x89 -x90 -x91 x92 x93 -x94 -x95 x96 x97 x98 -x99 -x100 x101 -x102 x103 -x104 -x105 x106 -x107 -x108 -x109 -x110 x111 -x112 -x113 x114 -x115 -x116 -x117 -x118 -x119 -x120 -x121 -x122 x123 -x124 -x125 x126 x127 -x128 -x129 -x130 -x131 x132 -x133 -x134 -x135 x136 x137 -x138 -x139 x140 -x141 -x142 -x143 -x144 -x145 -x146 -x147 -x148 x149 -x150 -x151 -x152 x153 -x154 -x155 -x156 -x157 x158 x159 -x160 x161 x162 -x163 -x164 -x165 x166 x167 x168 -x169 -x170 -x171 x172 x173 -x174 -x175 x176 -x177 x178 -x179 -x180 -x181 x182 x183 -x184 x185 -x186 -x187 -x188 x189 -x190 x191 x192 x193 -x194 -x195 x196 x197 -x198 -x199 -x200 x201 -x202 -x203 -x204 -x205 -x206 x207 -x208 -x209 -x210 -x211 x212 x213 -x214 -x215 x216 -x217 x218 -x219 -x220 -x221 -x222 x223 -x224 -x225 x226 -x227 x228 -x229 x230 -x231 -x232 -x233 -x234 -x235 x236 x237 -x238 x239 -x240 x241 -x242 x243 -x244 -x245 x246 -x247 x248 x249 -x250 -x251 -x252 x253 -x254 -x255 -x256 -x257 -x258 x259 -x260 x261 x262 x263 -x264 -x265 -x266 x267 x268 -x269 -x270 x271 x272 x273 -x274 x275 -x276 x277 x278 x279 -x280 x281 x282 x283 x284 -x285 x286 -x287 x288 x289 -x290 x291 -x292 -x293 -x294 x295 -x296 -x297 -x298 x299 -x300 -x301 -x302 x303 x304 -x305 x306 x307 -x308 x309 -x310 -x311 -x312 -x313 -x314 -x315 x316 x317 -x318 x319 x320 -x321 x322 x323 -x324 -x325 x326 x327 x328 -x329 -x330 x331 -x332 x333 -x334 -x335 x336 -x337 -x338 -x339 -x340 -x341 -x342 -x343 -x344 -x345 -x346 -x347 x348 -x349 -x350 x351 x352 -x353 -x354 -x355 -x356 x357 -x358 -x359 -x360 x361 -x362 -x363 x364 -x365 x366 x367 x368 x369 -x370 -x371 -x372 -x373 -x374 x375 -x376 x377 x378 x379 -x380 -x381 -x382 -x383 -x384 -x385 -x386 x387 -x388 -x389 x390 x391 -x392 x393 x394 -x395 -x396 -x397 x398 x399 -x400 x401 x402 -x403 x404 -x405 -x406 -x407 x408 x409 x410 x411 x412 -x413 x414 -x415 -x416 -x417 x418 x419 -x420 -x421 -x422 -x423 -x424 -x425 -x426 x427 x428 -x429 -x430 -x431 x432 x433 x434 -x435 x436 -x437 x438 -x439 -x440 -x441 -x442 -x443 x444 -x445 x446 x447 x448 -x449 -x450 -x451 -x452 -x453 x454 x455 -x456 -x457 x458 x459 -x460 x461 -x462 x463 x464 -x465 x466 x467 -x468 x469 -x470 x471 x472 x473 -x474 -x475 x476 x477 x478 x479 -x480 -x481 x482 x483 -x484 -x485 -x486 -x487 -x488 -x489 -x490 -x491 -x492 -x493 x494 -x495 x496 -x497 -x498 x499 x500 x501 -x502 x503 x504 -x505 -x506 x507 x508 x509 -x510 -x511 -x512 x513 x514 -x515 -x516 -x517 -x518 x519 -x520 -x521 -x522 -x523 -x524 x525 x526 x527 x528 -x529 -x530 x531 x532 -x533 x534 -x535 -x536 -x537 -x538 -x539 -x540 -x541 x542 -x543 x544 x545 
c objective function=226
c Total wall clock time (in seconds): 0.91

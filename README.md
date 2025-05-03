# basic-computer-
# Basic Computer (M. Morris Mano) - Verilog Implementation

## Project Overview

This project is a Verilog-based hardware implementation of the **Basic Computer** architecture from the textbook *"Digital Design and Computer Architecture"* by **M. Morris Mano**. It faithfully models the datapath, control unit, memory system, and I/O instructions as described in the book, and simulates instruction execution cycle-by-cycle.


##  Architecture Features

- **16-bit Word Length**
- **12-bit Address Bus** (4K words of memory)  // this is in mano's basic computer specifications, but in the verilog code for simplicity of the simulation we scaled the size of registers


- **internal Registers:** AC, DR, IR, TR, AR, PC, INPR, OUTR
- **Memory:** 4096x16-bit, initialized from external file
- **ALU Operations:** AND, ADD, LDA, CLA, etc.
- **sequence counter:** Implements micro-operations T0–T15   // the maximum size for instruction is 15 but this also in mano's specifications and we scale this and reduce it for simplicity
- 
- **Instruction Set:**
  - Memory-Reference Instructions (AND, ADD, LDA, STA, BUN, etc.)
  - Register-Reference Instructions (CLA, INC, HLT, etc.)
  - I/O Instructions (INP, OUT)
- I/O regs: 8-bit INPR and OUTR
- it also based on a cructial concept which is the timing and control structure which means that each microoperation has it is corresponding execuation
- the link of the video https://drive.google.com/file/d/1fRkIO8felcxEaqPWjACFy9cQKGDL5XA_/view?usp=sharing





   0:4  => presentation about the project

  
   4:07 : 12:19 => proteus simulation and overview


   12:19 : end of the video   => verilog simulation and overview



   team members : رقم الكشف\الاسم


  (39) خالد اسامة عصر






  (32) حاتم حسام غازي






  
  
  
  (24) امير عصام سالم












  (6) احمد رفعت الغتوري 













  (52) سلمي احمد مصطفي



















 (116) منار جمال فرغل

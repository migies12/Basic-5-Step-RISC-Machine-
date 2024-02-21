Basic 5-Step RISC Machine for Instruction Processing
This repository contains a basic implementation of a 5-step Reduced Instruction Set Computing (RISC) machine. The machine follows the classic pipeline architecture consisting of the following stages:

Instruction Fetch (IF)
Instruction Decode (ID)
Execute (EX)
Memory Access (MEM)
Writeback (WB)
Each stage is implemented using Verilog modules and connected together to form a complete datapath for instruction processing.

Files
1. cpu.sv
This file contains the state machine representing the central processing unit (CPU). It controls the flow of instructions through the pipeline stages.

2. regfile.sv
The regfile.sv module represents the register file of the processor. It consists of 8 registers implemented using flip flops, providing storage for intermediate results and operands.

3. alu.sv
The Arithmetic Logic Unit (ALU) module (alu.sv) performs arithmetic and logical operations required by the instructions being processed.

4. shifter.sv
The shifter.sv module handles shifting operations based on the opcode of the instruction being executed. It manipulates the bits of data as needed during processing.

5. datapath.sv
The datapath.sv module acts as the backbone of the system, connecting the various hardware components together to ensure proper flow of data and control signals between stages.

How It Works
The CPU module (cpu.sv) orchestrates the movement of instructions through the pipeline. Each clock cycle advances the pipeline by one stage, starting from instruction fetch and ending with writeback.

Instruction Fetch (IF): The CPU fetches the next instruction from memory.
Instruction Decode (ID): The fetched instruction is decoded, determining the operation to be performed and identifying the operands.
Execute (EX): The ALU performs the specified operation on the operands.
Memory Access (MEM): If required, data is accessed from or written to memory.
Writeback (WB): The result of the operation is written back to the register file.
Getting Started
To simulate or synthesize the RISC machine, you can use any Verilog simulation or synthesis toolchain. Ensure all Verilog files are included in your project, and instantiate the cpu module in your top-level design.

Contributions
Contributions to this project are welcome! Feel free to fork the repository, make changes, and submit pull requests. If you encounter any issues or have suggestions for improvement, please open an issue.


// Percent Effort: mcolson 100%

`timescale 1ns / 1ps

module Datapath(
        input CLK,
        input Reset,
        output wire [31:0] RegV0,
        output wire [31:0] RegV1
        // output wire[31:0] DisplayedWriteData,
        // output wire[31:0] DisplayedProgramCounter
    );

    wire[31:0] InstructionFromIF_ID;
    wire AluSrc;
    wire MemWrite;
    wire[4:0] WriteAddrFromID_EX;
    wire[4:0] WriteAddrFromEX_MEM;
    wire[4:0] WriteAddrFromMEM_WB;
    wire Stall;
    
    wire[4:0] RSFromIF_ID = InstructionFromIF_ID[25:21];
    wire[4:0] RTFromIF_ID = InstructionFromIF_ID[20:16];
    HazardDetector compHD(
        .RS(RSFromIF_ID),
        .RT(RTFromIF_ID),
        .AluSrc(AluSrc),
        .MemWrite(MemWrite),
        .WriteAddrFromID_EX(WriteAddrFromID_EX),
        .WriteAddrFromEX_MEM(WriteAddrFromEX_MEM),
        .WriteAddrFromMEM_WB(WriteAddrFromMEM_WB),
        .Stall(Stall)
    );
    
    // BEGIN FETCH
    wire [31:0] PCIn;
    wire TakeBranch;

    wire[31:0] PCOut;
    wire[31:0] PCOutPlus4;
    assign PCOutPlus4 = PCOut + 4;
    ProgramCounter compPC (
        .CLK(CLK),
        .Reset(Reset),
        .Stall(Stall),
        .D(
            TakeBranch 
            ? PCIn 
            : PCOutPlus4
        ),
        .Q(PCOut)
    );

    wire[31:0] Instruction;
    InstructionMemory compIM (
        .Address(PCOut),
        .Instruction(Instruction)
    );

    // END FETCH

    wire[31:0] PCOutPlus4FromIF_ID;
    wire[31:0] PCOutFromIF_ID;
    IF_ID_RegFile compIFIDRF(
        .CLK(CLK),
        .Reset(Reset),
        .Stall(Stall),
        .Instruction(Instruction),
        .PCOutPlus4(PCOutPlus4),
        .PCOut(PCOut),
        .InstructionFromIF_ID(InstructionFromIF_ID),
        .PCOutPlus4FromIF_ID(PCOutPlus4FromIF_ID),
        .PCOutFromIF_ID(PCOutFromIF_ID)
    );

    // BEGIN DECODE
    
    wire[31:0] WriteDataFromMEM_WB;
    wire[31:0] ReadData1;
    wire[31:0] ReadData2;
    Registers compRegs(
        .CLK(CLK),
        .Reset(Reset),
        .ReadAddr1(RSFromIF_ID),
        .ReadAddr2(RTFromIF_ID),
        .WriteAddr(WriteAddrFromMEM_WB),
        .WriteData(WriteDataFromMEM_WB),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .RegV0(RegV0),
        .RegV1(RegV1)
    );

    wire[31:0] SignExtendedImmediate;
    SignExtender16to32 compSEI(
        .D(InstructionFromIF_ID[15:0]),
        .Q(SignExtendedImmediate)
    );

    wire MemRead;
    wire MemToReg;
    wire[1:0] RegDest;
    wire[2:0] BranchType;
    wire[1:0] JumpType;
    wire[1:0] MemWidth;
    wire[3:0] AluFunc;
    Controller compCTRLR(
        .Instruction(InstructionFromIF_ID),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .AluSrc(AluSrc),
        .RegDest(RegDest),
        .MemToReg(MemToReg),
        .BranchType(BranchType),
        .JumpType(JumpType),
        .MemWidth(MemWidth),
        .AluFunc(AluFunc)
    );

    wire[31:0] AluBIn = AluSrc ? SignExtendedImmediate : ReadData2;

    BranchUnit compBU(
        .BranchType(BranchType),
        .JumpType(JumpType),
        .PCOutPlus4(PCOutPlus4FromIF_ID),
        .Address(SignExtendedImmediate),
        .A(ReadData1),
        .B(AluBIn),
        .PCIn(PCIn),
        .TakeBranch(TakeBranch)
    );

    wire[4:0] WriteAddr = RegDest[1]
        ? (RegDest[0] ? InstructionFromIF_ID[15:11] : InstructionFromIF_ID[20:16])
        : (RegDest[0] ? 31 : 0);

    // END DECODE

    wire[31:0] ReadData1FromID_EX;
    wire[31:0] ReadData2FromID_EX;
    wire[31:0] AluBInFromID_EX;
    wire[4:0] AluSAFromID_EX;
    wire[31:0] PCOutFromID_EX;
    wire MemReadFromID_EX;
    wire MemWriteFromID_EX;
    wire[1:0] MemWidthFromID_EX;
    wire[3:0] AluFuncFromID_EX;
    wire MemToRegFromID_EX;
    ID_EX_RegFile compIDEXRF(
        .CLK(CLK),
        .Reset(Reset),
        .Stall(Stall),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .AluBIn(AluBIn),
        .AluSA(InstructionFromIF_ID[10:6]),
        .WriteAddr(WriteAddr),
        .PCOut(PCOutFromIF_ID),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemWidth(MemWidth),
        .AluFunc(AluFunc),
        .MemToReg(MemToReg),
        
        .ReadData1FromID_EX(ReadData1FromID_EX),
        .ReadData2FromID_EX(ReadData2FromID_EX),
        .AluBInFromID_EX(AluBInFromID_EX),
        .AluSAFromID_EX(AluSAFromID_EX),
        .WriteAddrFromID_EX(WriteAddrFromID_EX),
        .PCOutFromID_EX(PCOutFromID_EX),
        .MemReadFromID_EX(MemReadFromID_EX),
        .MemWriteFromID_EX(MemWriteFromID_EX),
        .MemWidthFromID_EX(MemWidthFromID_EX),
        .AluFuncFromID_EX(AluFuncFromID_EX),
        .MemToRegFromID_EX(MemToRegFromID_EX)
    );

    // BEGIN EXECUTE

    wire[31:0] AluResult;
    ALU compALU(
        .A(ReadData1FromID_EX),
        .B(AluBInFromID_EX),
        .SA(AluSAFromID_EX),
        .PCOut(PCOutFromID_EX),
        .F(AluFuncFromID_EX),
        .Q(AluResult)
    );

    // END EXECUTE

    wire[31:0] AluResultFromEX_MEM;
    wire[31:0] ReadData2FromEX_MEM;
    wire MemReadFromEX_MEM;
    wire MemWriteFromEX_MEM;
    wire MemToRegFromEX_MEM;
    wire[1:0] MemWidthFromEX_MEM;
    wire[31:0] PCOutFromEX_MEM;
    EX_MEM_RegFile compEXMEMRF(
        .CLK(CLK),
        .Reset(Reset),
        .AluResult(AluResult),
        .ReadData2(ReadData2FromID_EX),
        .WriteAddr(WriteAddrFromID_EX),
        .MemRead(MemReadFromID_EX),
        .MemWrite(MemWriteFromID_EX),
        .MemToReg(MemToRegFromID_EX),
        .MemWidth(MemWidthFromID_EX),
        .PCOut(PCOutFromID_EX),
        .AluResultFromEX_MEM(AluResultFromEX_MEM),
        .ReadData2FromEX_MEM(ReadData2FromEX_MEM),
        .WriteAddrFromEX_MEM(WriteAddrFromEX_MEM),
        .MemReadFromEX_MEM(MemReadFromEX_MEM),
        .MemWriteFromEX_MEM(MemWriteFromEX_MEM),
        .MemToRegFromEX_MEM(MemToRegFromEX_MEM),
        .MemWidthFromEX_MEM(MemWidthFromEX_MEM),
        .PCOutFromEX_MEM(PCOutFromEX_MEM)
    );

    // BEGIN MEMORY

    wire[31:0] ReadData;
    DataMemory compDM(
        .CLK(CLK),
        .Reset(Reset),
        .Address(AluResultFromEX_MEM),
        .WriteData(ReadData2FromEX_MEM),
        .MemRead(MemReadFromEX_MEM),
        .MemWrite(MemWriteFromEX_MEM),
        .MemWidth(MemWidthFromEX_MEM),
        .ReadData(ReadData)
    );

    // END MEMORY
    
    wire MemToRegFromMEM_WB;
    wire[31:0] AluResultFromMEM_WB;
    wire[31:0] ReadDataFromMEM_WB;
    wire[31:0] PCOutFromMEM_WB;
    MEM_WB_RegFile compMEMWBRF(
        .CLK(CLK),
        .Reset(Reset),
        .AluResult(AluResultFromEX_MEM),
        .ReadData(ReadData),
        .WriteAddr(WriteAddrFromEX_MEM),
        .MemToReg(MemToRegFromEX_MEM),
        .PCOut(PCOutFromEX_MEM),
        .AluResultFromMEM_WB(AluResultFromMEM_WB),
        .ReadDataFromMEM_WB(ReadDataFromMEM_WB),
        .WriteAddrFromMEM_WB(WriteAddrFromMEM_WB),
        .MemToRegFromMEM_WB(MemToRegFromMEM_WB),
        .PCOutFromMEM_WB(PCOutFromMEM_WB)
    );
    
     assign WriteDataFromMEM_WB = MemToRegFromMEM_WB ? AluResultFromMEM_WB : ReadDataFromMEM_WB;
    
    // assign DisplayedWriteData = (WriteAddrFromMEM_WB != 0) ? WriteDataFromMEM_WB : 0;
    // assign DisplayedProgramCounter = PCOutFromMEM_WB;
    
endmodule

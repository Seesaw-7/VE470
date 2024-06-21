/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  forwarding_unit.v                                           //
//                                                                     //
//  Description :  This module creates the Forwarding Unit used by the EX   // 
//                 Stage of the Pipeline.                          //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`ifndef __FORWARDING_UNIT_V__
`define __FORWARDING_UNIT_V__

`timescale 1ns/100ps

module forwarding_unit(
        input   [4:0] rs1, rs2, mem_rd, wb_rd,    // id/ex_stage_reg output register file source 1 index, source 2 index,
                                                // ex/mem_stage_reg output register file destination index, mem_rd == 0 if no reg write
                                                // mem/wb_stage_reg output register file destination index
        input         mem_regWrite, wb_regWrite, // whether mem stage issues reg write, 
                                                //whether wb stage issues reg write
        output ALU_FORWARD_SELECT forward1, forward2    // ALU forwarding path chosen for alu input 1 and aluinput 2
      );

  wire is_ex_hazard1  = mem_regWrite && (mem_rd != 0) && (mem_rd == rs1);
  wire is_ex_hazard2  = mem_regWrite && (mem_rd != 0) && (mem_rd == rs2);
  wire is_mem_hazard1 = wb_regWrite && (wb_rd != 0) && (wb_rd == rs1) && ~is_ex_hazard1;
  wire is_mem_hazard2 = wb_regWrite && (wb_rd != 0) && (wb_rd == rs2) && ~is_ex_hazard2;

  assign forward1 = is_ex_hazard1 ? PATH_IS_FROM_MEM : (is_mem_hazard1 ? PATH_IS_FROM_WB : PATH_IS_ORIGINAL);
  assign forward2 = is_ex_hazard2 ? PATH_IS_FROM_MEM : (is_mem_hazard2 ? PATH_IS_FROM_WB : PATH_IS_ORIGINAL);

endmodule 
`endif

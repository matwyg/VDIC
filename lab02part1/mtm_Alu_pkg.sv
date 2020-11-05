package mtm_Alu_pkg;
		typedef enum bit[2:0] {
		AND = 3'b000,
		OR = 3'b001,
		ADD = 3'b100,
		SUB = 3'b101
	} op_t;

	typedef enum bit [1:0] {DATA, CTL, ERR} byte_type_t;
	typedef enum bit {BYTE_OK, BYTE_BAD} byte_status_t;
	
endpackage : mtm_Alu_pkg

module apb_master (
    input  logic PCLK,
    input  logic RSTN,
    input  logic start_tfr,
    input  logic pready,
    output logic psel,
    output logic penable,
    output logic [1:0] apb_mstr_state
);
 
  typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        ACCESS = 2'b10
    } state_t;

    state_t current_state, next_state;
  
   always_ff @(posedge PCLK or negedge RSTN) begin
        if (!RSTN) current_state <= IDLE;
        else current_state <= next_state;
    end
  
   always_comb begin
        case (current_state)
            IDLE:   next_state = start_tfr ? SETUP : IDLE;
            SETUP:  next_state = ACCESS;
          ACCESS: begin 
            if (pready==1 && start_tfr==1) 
                next_state = SETUP;
            else if (pready==1 && start_tfr==0)
                  next_state = IDLE;
                  else 
                    next_state = ACCESS;
                    end
                  default: next_state = IDLE;  
        endcase
          end 
                    
  always_comb begin
    case (current_state)
        IDLE:   begin psel=0; penable=0; apb_mstr_state=2'b00; end
        SETUP:  begin psel=1; penable=0; apb_mstr_state=2'b01; end
        ACCESS: begin psel=1; penable=1; apb_mstr_state=2'b10; end
        default: begin psel=0; penable=0; apb_mstr_state=2'b00; end
    endcase
  end 
    endmodule
 

module tb_apb;
    reg PCLK, RSTN, start_tfr, pready;
    wire psel, penable;
    wire [1:0] apb_mstr_state;
  
  apb_master dut (
        .PCLK(PCLK),
        .RSTN(RSTN),
        .start_tfr(start_tfr),
        .pready(pready),
        .psel(psel),
        .penable(penable),
        .apb_mstr_state(apb_mstr_state)
    );

  
  initial PCLK = 0;
    always #5 PCLK = ~PCLK;
  
   task single_transfer;
      begin 
     
        start_tfr = 1;
        @(posedge PCLK);

        @(posedge PCLK);
        start_tfr = 0;      

        pready = 1;         

        @(posedge PCLK);
        start_tfr = 0;
        pready = 0;
    end
    endtask
  
  
  task wait_state_transfer;
    begin
        @(posedge PCLK);
        start_tfr = 1;

        @(posedge PCLK);
        start_tfr = 0;

        
        pready = 0;

        repeat(3)
            @(posedge PCLK);

        pready = 1;

        @(posedge PCLK);

        pready = 0;
    end
    endtask

  
  task back_to_back_transfer;
begin
    @(posedge PCLK);
    start_tfr = 1;

    @(posedge PCLK);

    pready = 1;

    @(posedge PCLK); 

    @(posedge PCLK); 

    start_tfr = 0;

    @(posedge PCLK); 
end
endtask
  
  
    initial begin

    
        RSTN      = 0;
        start_tfr = 0;
        pready    = 0;

    
        #20;
        RSTN = 1;

        single_transfer();

        #20;
        wait_state_transfer();
      
      #20;
      back_to_back_transfer();


        #50;
      $finish;
    end

    initial begin
        $dumpfile("apb.vcd");
        $dumpvars(0, tb_apb);
    end
endmodule

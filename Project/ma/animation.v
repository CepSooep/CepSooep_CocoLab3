module Animation(
  input clock,
  input resetn,
  input initializeMEM, //=1 to copy files into RAM (should only happen at start of program)

)
//************************************Initial loading MEM of MAP1, MAP2, Startscreen****************
  reg [14:0] addrLoading;
  reg [31:0] ramMap1 [0:19200];
  reg [31:0] regToOnChipMap1;
  reg [31:0] ramMap2 [0:19200];
  reg [31:0] regToOnChipMap2;
  reg [31:0] ramStart [0:19200];
  reg [31:0] regToOnChipStart;

  initial begin
  $readmemb("rams_init_file.data",ram);
  //putting file in big block of registers
  end

  always @(posedge clock) begin
    if (initializeMEM * !resetn) addrLoading = 0;
    else if (initializeMEM * (addrLoading <= 15'd19199)) begin
      regToOnChipMap1 = ramMap1[addrLoading];
      regToOnChipMap2 = ramMap2[addrLoading];
      regToOnChipStart = ramStart[addrLoading];
      addrLoading = addrLoading + 1;
    end
    else if (initializeMEM * (addrLoading == 15'd19200)) 
      addrLoading = 0;
  end 

  wire [31:0] Q1, Q2, Qs;
  map1startMEM Map1(
    .clock(clock),
    .data(regToOnChipMap1),
    .rdaddress(15'd0), //dont care
    .wraddress(addrLoading),
    .wren(1'b1),
    .q(Q1));

  map1startMEM Map2(
    .clock(clock),
    .data(regToOnChipMap2),
    .rdaddress(15'd0), //dont care
    .wraddress(addrLoading),
    .wren(1'b1),
    .q(Q2));

  map1startMEM Start(
    .clock(clock),
    .data(regToOnChipStart),
    .rdaddress(15'd0), //dont care
    .wraddress(addrLoading),
    .wren(1'b1),
    .q(Qs));
//****************************************END OF loading RAM*****************************



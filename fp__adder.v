`timescale 1ns/1ns
module fp__adder (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] s
);
wire [7:0] exp1;
wire [7:0] exp2;
wire [7:0] exponent1;
wire [7:0] exponent2;
wire sign1;
wire sign2;
wire hiddenbit1;
wire hiddenbit2;

wire [26:0] biggernum;
wire [26:0] smallernum;
wire [25:0] testshift;

wire sticky;
wire [7:0]shift;

wire [24:0] fraction1;
wire [24:0] fraction2;

wire [8:0] subtractor;

wire [25:0] mantisa1;
wire [25:0] mantisa2;
wire [28:0] sbiggernum;
wire [28:0] ssmallernum;
wire [28:0] answersum;

wire [27:0] sanswersum; //p8
wire sign;
wire [27:0] normalizedans;
wire [7:0] normalizedexp;
//p9
wire [7:0] biggerexp;
wire [5:0] firstone;
wire [24:0] finalans;
wire test;
wire [24:0]fmantisa;
wire [7:0] fexp;
wire [25:0] lbiggernum;
wire[25:0] lsmallernum;
wire [8:0] exptest;
assign exp1=a[30:23];
assign exp2=b[30:23];
assign hiddenbit1= exp1==1'b0 ? 1'b0 : 1'b1;
assign hiddenbit2= exp2==1'b0 ? 1'b0 : 1'b1;
assign exponent1= exp1==1'b0 ? 1'b1 : exp1 ;
assign exponent2= exp2==1'b0 ? 1'b1 : exp2;
assign fraction1= {a[22:0],2'b00};
assign fraction2= {b[22:0],2'b00};
assign mantisa1={hiddenbit1,fraction1};
assign mantisa2={hiddenbit2,fraction2};
assign subtractor= exponent1-exponent2;
// peyda kardan exp bozorg 

assign biggerexp = subtractor[8]==1'b1 ? exponent2 : exponent1;
assign shift= (subtractor[8]==1'b1) ? (~subtractor[7:0]+1'b1) : subtractor[7:0];
assign lbiggernum= subtractor[8]==1'b1 ? mantisa2 : mantisa1;
assign lsmallernum =subtractor[8]==1'b1 ? mantisa1: mantisa2;
assign sign1=subtractor[8]==1'b1 ? b[31] : a[31];
assign sign2=subtractor[8]==1'b1 ? a[31] : b[31];
assign testshift={lsmallernum<<(26-shift)};
assign sticky= |testshift;
assign smallernum = {lsmallernum>>shift,sticky};
assign biggernum={lbiggernum[25:0],1'b0};
assign ssmallernum=sign2 ?{~{2'b00,smallernum}+1'b1} : {2'b00,smallernum};
assign sbiggernum=sign1 ? {~{2'b00,biggernum}+1'b1} :{2'b00,biggernum} ;
assign answersum= sbiggernum+ssmallernum;
assign sign=answersum[28];
assign sanswersum= sign ? (~answersum[27:0]+1'b1) :answersum[27:0];

//part 9 normalizing
assign firstone= sanswersum[25] ? 1 :
                 sanswersum[24] ? 2 :
                 sanswersum[23] ? 3 :
                 sanswersum[22] ? 4 :
                 sanswersum[21] ? 5 :
                 sanswersum[20] ? 6 :
                 sanswersum[19] ? 7 :
                 sanswersum[18] ? 8 :
                 sanswersum[17] ? 9 :
                 sanswersum[16] ? 10 :
                 sanswersum[15] ? 11 :
                 sanswersum[14] ? 12 :
                 sanswersum[13] ? 13 :
                 sanswersum[12] ? 14 :
                 sanswersum[11] ? 15 :
                 sanswersum[10] ? 16 :
                 sanswersum[9] ?  17 :
                 sanswersum[8] ?  18 :
                 sanswersum[7] ?  19 :
                 sanswersum[6] ?  20 :
                 sanswersum[5] ?  21 :
                 sanswersum[4] ?  22 :
                 sanswersum[3] ?  23 :
                 sanswersum[2] ?  24 :
                 sanswersum[1] ?  25 : 26;
assign exptest=biggerexp-firstone;
assign normalizedans= sanswersum[27:26]==2'b01 ? sanswersum : sanswersum[27:26]==2'b10 || sanswersum[27:26]==2'b11  ? {1'b0,sanswersum[27:2],sanswersum[1]|sanswersum[0]} : (biggerexp>firstone)&&sanswersum[27:26]==2'b00  ? {sanswersum<<firstone} :  {sanswersum<<(biggerexp-1)} ;
assign normalizedexp= sanswersum[27:26]==2'b01 ? biggerexp : sanswersum[27:26]==2'b10 || sanswersum[27:26]==2'b11 ? biggerexp+1: (biggerexp>firstone)&&sanswersum[27:26]==2'b00&&sanswersum!=0 ? biggerexp-firstone : normalizedans==0 ? 0 : 1'b1 ;
assign test=normalizedans[3];
assign finalans= normalizedans[2:0]>3'b100 ? normalizedans[27:3]+1'b1 : normalizedans[2:0]<3'b100 ?  normalizedans[27:3] : test==1'b1 ? {normalizedans[27:3]+1'b1} : normalizedans[27:3] ;
assign fmantisa= finalans[24:23]==2'b10 ? {finalans>>1} : finalans;
assign fexp= finalans[24:23]==2'b10 ? normalizedexp+ 1'b1 : normalizedexp;
assign s= fexp!=1'b1  ?   {sign,fexp,fmantisa[22:0]} : fmantisa[24:23]==2'b00 ? {sign,8'b0,fmantisa[22:0]} :  {sign,fexp,fmantisa[22:0]};         


endmodule
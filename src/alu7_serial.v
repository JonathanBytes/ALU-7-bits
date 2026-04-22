module alu7_serial (
    input  wire       CLK,
    input  wire       RST_n,     // Reset activo en bajo
    input  wire       Bit_in,    // Entrada de bit serial
    input  wire [2:0] op,        // Operación a realizar (3 bits para hasta 8 operaciones)
    output reg  [6:0] Data_out,  // Salida de datos de 7 bits
    output reg        Done       // Señal de finalización de la operación
);

  reg [6:0] A;          // Registro del operando A
  reg [6:0] B;          // Registro del operando B
  reg [2:0] op_reg;     // Operacion latcheada durante la carga serial
  reg [3:0] bit_count;  // Cuenta 14 bits seriales de entrada

  wire [6:0] b_next = {Bit_in, B[6:1]};

  always @(posedge CLK or negedge RST_n) begin
    if (!RST_n) begin
      A <= 7'd0;
      B <= 7'd0;
      op_reg <= 3'd0;
      bit_count <= 4'd0;
      Data_out <= 7'd0;
      Done <= 1'b0;
    end else if (!Done) begin
      // Latch de op durante toda la carga de bits.
      op_reg <= op;

      if (bit_count < 4'd7) begin
        // Captura LSB-first para A.
        A <= {Bit_in, A[6:1]};
        bit_count <= bit_count + 4'd1;
      end else if (bit_count < 4'd14) begin
        // Captura LSB-first para B.
        B <= b_next;
        bit_count <= bit_count + 4'd1;

        // Al recibir el bit 14, resolver y publicar resultado.
        if (bit_count == 4'd13) begin
          case (op_reg)
            3'b000:  Data_out <= (A + b_next) & 7'h7F;  // Suma
            3'b001:  Data_out <= A & b_next;            // AND
            3'b010:  Data_out <= A | b_next;            // OR
            3'b011:  Data_out <= A ^ b_next;            // XOR
            3'b100:  Data_out <= (A - b_next) & 7'h7F;  // Resta
            default: Data_out <= 7'd0;
          endcase
          Done <= 1'b1;
        end
      end
    end
  end

endmodule

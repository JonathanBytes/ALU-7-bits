module alu7_serial (
    input  wire       CLK,
    input  wire       RST_n,     // Reset activo en bajo
    input  wire       Bit_in,    // Entrada de bit serial
    input  wire [2:0] op,        // Operación a realizar (3 bits para hasta 8 operaciones)
    output reg  [6:0] Data_out,  // Salida de datos de 7 bits
    output reg        Done       // Señal de finalización de la operación
);

  reg [6:0] A;          // Registro para el primer operando
  reg [6:0] B;          // Registro para el segundo operando
  reg [3:0] bit_count;  // Cuenta los 14 bits seriales de entrada

  always @(posedge CLK or negedge RST_n) begin
    if (!RST_n) begin
      A <= 7'b0;         // Reiniciar A
      B <= 7'b0;         // Reiniciar B
      bit_count <= 4'b0; // Reiniciar contador de bits
      Data_out <= 7'b0;  // Reiniciar salida de datos
      Done <= 1'b0;      // Reiniciar señal de finalización
    end else if (!Done) begin
      if (bit_count < 4'd7) begin
        // Los primeros 7 bits (LSB a MSB) pertenecen a A.
        A[bit_count] <= Bit_in;
        bit_count <= bit_count + 4'd1;
      end else if (bit_count < 4'd14) begin
        // Los siguientes 7 bits (LSB a MSB) pertenecen a B.
        B[bit_count-4'd7] <= Bit_in;

        // Después del bit 14, producir el resultado en paralelo y activar Done.
        if (bit_count == 4'd13) begin
          case (op)
            3'b000:  Data_out <= A + {Bit_in, B[5:0]};  // Suma
            3'b001:  Data_out <= A & {Bit_in, B[5:0]};  // AND
            3'b010:  Data_out <= A | {Bit_in, B[5:0]};  // OR
            3'b011:  Data_out <= A ^ {Bit_in, B[5:0]};  // XOR
            3'b100:  Data_out <= A - {Bit_in, B[5:0]};  // Resta
            default: Data_out <= 7'b0;                  // Operación no definida
          endcase
          Done <= 1'b1;
        end
        bit_count <= bit_count + 4'd1;
      end
    end
  end

endmodule

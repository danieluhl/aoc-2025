import gleam/int
import gleam/io
import gleam/result

pub fn main() {
  let result = -18 % 100
  // -18
  let result2 = result.unwrap(int.modulo(-18, 100), 0)
  // 82
  io.print(int.to_string(result))
  io.print("\n---\n")
  io.print(int.to_string(result2))
  io.print("\n---\n")
}

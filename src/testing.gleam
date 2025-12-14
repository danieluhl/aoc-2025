import gleam/int
import gleam/io

pub fn main() {
  let result = -7 % 5
  io.print(int.to_string(result))
  io.print("\n---\n")
}

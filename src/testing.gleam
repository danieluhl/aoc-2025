import gleam/int
import gleam/io

pub fn main() {
  let result = -180 / 100
  io.print(int.to_string(result))
  io.print("\n---\n")
}

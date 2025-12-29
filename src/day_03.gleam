import file_utils.{pp, read_input_by_delimiter}
import gleam/int
import gleam/list
import gleam/option.{None}
import gleam/result
import gleam/string

type Bank(digits) {
  Bank(digits: List(Int))
}

pub fn main() {
  let instructions = read_input_by_delimiter("03", True, None)
  let banks =
    instructions
    |> list.map(fn(ins) {
      Bank(
        digits: ins
        |> string.split("")
        |> list.map(int.parse)
        |> result.values,
      )
    })

  banks
  |> list.map(fn(n) { list.map(n.digits, fn(n2) { pp("", int.to_string(n2)) }) })
}

import gleam/bool
import gleam/io
import gleam/list
import gleam/option.{type Option, Some}
import gleam/string
import simplifile.{describe_error}

// function to read input
pub fn read_input(day: String, sample: Bool) {
  let path_base = "input/day"
  let sample_path = "_sample"
  let extension = ".txt"
  let path = case sample {
    True -> path_base <> day <> sample_path <> extension
    False -> path_base <> day <> extension
  }
  let read_results = simplifile.read(from: path)
  case read_results {
    Ok(content) -> content
    Error(e) -> {
      io.print("Error reading file: " <> path <> " ")
      io.print_error(describe_error(e))
      ""
    }
  }
}

pub fn read_input_by_delimiter(
  day: String,
  sample: Bool,
  delimiter: Option(String),
) {
  let del = case delimiter {
    Some(d) -> d
    _ -> "\n"
  }
  let contents = read_input(day, sample)
  string.split(contents, on: del)
  |> list.filter(fn(s) { bool.negate(string.is_empty(s)) })
  |> list.map(fn(s) { string.trim(s) })
}

pub fn pp(label: String, output: String) {
  io.print("\n---\n")
  io.print(label)
  io.print(":\n")
  io.print(output)
  io.print("\n")
}

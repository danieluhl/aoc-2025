import file_utils.{read_list_input}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

fn process_next_instruction(
  instruction: String,
) -> Result(#(String, Int), String) {
  case string.pop_grapheme(instruction) {
    Ok(#(direction, amount)) -> {
      case int.parse(amount) {
        Ok(n) -> Ok(#(direction, n))
        Error(_e) ->
          Error("Error parsing amount\n instruction:\n" <> instruction)
      }
    }
    Error(_e) -> {
      Error("Error calculating zeros\n instruction:\n" <> instruction)
    }
  }
}

fn calculate_zeros_count(
  aggregates: Result(#(Int, Int), String),
  next_instruction: String,
) {
  case aggregates {
    Error(e) -> Error(e)
    Ok(#(zeros_total, running_total)) -> {
      use #(direction, amount) <- result.try(process_next_instruction(
        next_instruction,
      ))

      use new_total <- result.try(case direction {
        "R" ->
          result.replace_error(
            int.modulo(running_total + amount, 100),
            "modulo failed",
          )
        "L" ->
          result.replace_error(
            int.modulo(running_total - amount, 100),
            "modulo failed",
          )
        _ -> {
          io.print_error("invalid direction")
          io.print(direction)
          io.print(int.to_string(amount))
          Error("invalid direction")
        }
      })

      case new_total {
        0 -> Ok(#(zeros_total + 1, new_total))
        _ -> Ok(#(zeros_total, new_total))
      }
    }
  }
}

pub fn main() {
  let instructions = read_list_input("01", True)

  // keep a running total
  // keep a running zero count
  // when it hits zero, increment the zero count
  // return the zero count
  case
    list.fold(
      over: instructions,
      from: Ok(#(0, 50)),
      with: calculate_zeros_count,
    )
  {
    Ok(#(zeros_total, _)) -> {
      io.print("success!\n")
      io.print(int.to_string(zeros_total))
    }
    Error(e) -> {
      io.print("Error\n")
      io.print(e)
    }
  }
}

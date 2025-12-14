import file_utils.{pp, read_list_input}
import gleam/int
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
          pp("invalid direction", direction)
          pp("amount", int.to_string(amount))
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

fn calculate_zeroes_touched_count(
  aggregates: Result(#(Int, Int), String),
  next_instruction: String,
) {
  case aggregates {
    Error(e) -> Error(e)
    Ok(#(zeros_total, running_total)) -> {
      use #(direction, amount) <- result.try(process_next_instruction(
        next_instruction,
      ))

      use #(zeros_hit, new_dial_location) <- result.try(case direction {
        "R" -> {
          let div_total = running_total + amount
          Ok(#(div_total / 100, div_total % 100))
        }
        "L" -> {
          let sub_total = running_total - amount
          let add_negative = case running_total == 0 {
            True -> 0
            _ -> 1
          }
          case sub_total {
            x if x < 0 -> {
              // how many hundreds below are we
              let hundreds = int.absolute_value(sub_total / 100)
              // take the remainder of the divide and subtract that from 100
              let remainder = 100 + sub_total % 100
              Ok(#(hundreds + add_negative, remainder))
            }
            x if x == 0 -> {
              // if add_negative is zero it means we're going from zero to zero
              Ok(#(add_negative, sub_total))
            }
            _ -> Ok(#(0, sub_total))
          }
        }
        _ -> {
          pp("invalid direction", direction)
          pp("amount", int.to_string(amount))
          Error("invalid direction")
        }
      })

      pp("------------------", "---------------------")
      pp("next_instruction", next_instruction)
      pp("new_dial_location", int.to_string(new_dial_location))
      pp("zeros_hit", int.to_string(zeros_hit))

      Ok(#(zeros_total + zeros_hit, new_dial_location))
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
      pp("success", int.to_string(zeros_total))
    }
    Error(e) -> {
      pp("error", e)
    }
  }

  // Part 2!!!!
  case
    list.fold(
      over: instructions,
      from: Ok(#(0, 50)),
      with: calculate_zeroes_touched_count,
    )
  {
    Ok(#(zeros_total, _)) -> {
      pp("success", int.to_string(zeros_total))
    }
    Error(e) -> {
      pp("error", e)
    }
  }
}

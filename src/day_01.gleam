import file_utils.{pp, read_input_by_delimiter}
import gleam/int
import gleam/list
import gleam/option.{None}
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
    Ok(#(zeros_total, previous_dial_location)) -> {
      use #(direction, amount) <- result.try(process_next_instruction(
        next_instruction,
      ))

      use #(zeros_hit, new_dial_location) <- result.try(case direction {
        "R" -> {
          let div_total = previous_dial_location + amount
          Ok(#(div_total / 100, div_total % 100))
        }
        "L" -> {
          let zeros_hit = case previous_dial_location {
            0 -> amount / 100
            _ -> {
              case amount < previous_dial_location {
                True -> 0
                False -> 1 + { amount - previous_dial_location } / 100
              }
            }
          }

          let new_location_1 =
            int.absolute_value({ previous_dial_location - amount } % 100)
          use new_location <- result.try(result.replace_error(
            int.modulo(previous_dial_location - amount, 100),
            "modulo failed",
          ))

          pp("sub", int.to_string(previous_dial_location - amount))
          pp("new_location_1", int.to_string(new_location_1))
          pp("new_location", int.to_string(new_location))

          Ok(#(zeros_hit, new_location))
        }
        _ -> {
          pp("invalid direction", direction)
          pp("amount", int.to_string(amount))
          Error("invalid direction")
        }
      })

      Ok(#(zeros_total + zeros_hit, new_dial_location))
    }
  }
}

pub fn main() {
  let instructions = read_input_by_delimiter("01", True, None)

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

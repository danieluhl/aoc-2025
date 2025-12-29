import file_utils.{pp, read_input_by_delimiter}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string

fn check_chunks(input: String, size: Int) -> Bool {
  let chunks =
    input
    |> string.to_graphemes
    |> list.sized_chunk(size)

  // pp("size", int.to_string(size))
  // pp(
  //   "chunks",
  //   list.fold(chunks, "", fn(acc, next) {
  //     acc
  //     <> "\n"
  //     <> list.fold(next, "", fn(in_acc, in_next) { in_acc <> ", " <> in_next })
  //   }),
  // )
  case chunks {
    [] -> False
    // Compare every subsequent chunk to the first one
    [first, ..rest] -> list.all(rest, fn(chunk) { chunk == first })
  }
}

fn is_double(num: Int) {
  let id = int.to_string(num)
  let len = string.length(id)
  case len < 2 {
    True -> False
    _ -> {
      let min_chunk_size = 1
      let max_chunk_size = len / 2

      // pp("min_chunk_size", int.to_string(min_chunk_size))
      // pp("max_chunk_size", int.to_string(max_chunk_size))
      list.range(min_chunk_size, max_chunk_size)
      |> list.any(fn(chunk_size) { check_chunks(id, chunk_size) })
    }
  }
}

fn find_doubles(first: Int, end: Int) {
  list.range(first, end) |> list.filter(is_double)
}

pub fn main() {
  let instructions = read_input_by_delimiter("02", False, Some(","))
  let ids =
    list.fold(instructions, [], fn(acc, next) {
      let res = {
        case string.split(next, on: "-") {
          [start, end] -> {
            use start_num <- result.try(int.parse(start))
            use end_num <- result.try(int.parse(end))
            Ok(find_doubles(start_num, end_num))
          }
          _ -> Error(Nil)
        }
      }

      case res {
        Ok(doubles) -> list.flatten([doubles, acc])
        Error(_) -> acc
      }
    })
    // list.fold(instructions, list.new(), fn(acc: List(Int), next: String) {
    //   let range_list = string.split(next, on: "-")
    //   let assert Ok(start) = list.first(range_list)
    //   let assert Ok(end) = list.last(range_list)
    //   let assert Ok(start_num) = int.parse(start)
    //   let assert Ok(end_num) = int.parse(end)
    //   let doubles = find_doubles(start_num, end_num)
    //   list.append(acc, doubles)
    // })
    |> int.sum()
  pp("final result", int.to_string(ids))
  // pp(
  //   list.fold(ids, "", fn(acc, ins) {
  //     acc <> "\"" <> int.to_string(ins) <> "\n"
  //   }),
  //   "",
  // )
  // check if each id has any repeat numbers, get a list of repeats
  //  - 
  // sum the list of repeats
  // pp(list.fold(instructions, "", fn(acc, ins) { acc <> ins }), "")
}

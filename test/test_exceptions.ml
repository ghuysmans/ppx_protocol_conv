open StdLabels
open Sexplib.Std

module Make(Driver: Testable.Driver) = struct
  module M = Testable.Make(Driver)

  module Stack_overflow = struct
    type t = int list
    [@@deriving protocol ~driver:(module Driver), sexp]
    let t = List.init ~len:1_000_000 ~f:(fun i -> i)
    let name = __MODULE__ ^ "Stack_overflow"
    let test =
      Alcotest.test_case name `Quick (fun () ->
          try
            to_driver t
            |> of_driver_exn
            |> ignore
          with
          | Failure "ignore" [@warning "-52"] -> ()
        )
  end

  module Exceptions = struct
    type t = { text: string }
    [@@deriving protocol ~driver:(module Driver), sexp]
    type u = string
    [@@deriving protocol ~driver:(module Driver), sexp]
    let t' = u_to_driver "test string"

    (* This should raise an exception *)
    let test =
      Alcotest.test_case "text exception handling" `Quick (fun () ->
          of_driver t' |> ignore
    )
  end

  let unittest = __MODULE__, [
      Stack_overflow.test;
      Exceptions.test
    ]
end

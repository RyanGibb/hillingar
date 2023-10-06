open Lwt.Infix
let return = Lwt.return
let run t = Unix_os.Main.run t ; exit
0

module Mirage_logs_make__7 = Mirage_logs.Make(Pclock)

module Unikernel_hello__9 = Unikernel.Hello(Unix_os.Time)

let bootvar__1 = lazy (
  Bootvar.argv ()
  )

let key_gen__2 = lazy (
  let __bootvar__1 = Lazy.force bootvar__1 in
  __bootvar__1 >>= fun _bootvar__1 ->
  return (Mirage_runtime.with_argv (List.map fst Key_gen.runtime_keys) "hello" _bootvar__1)
  )

let printexc__3 = lazy (
  return (Printexc.record_backtrace (Key_gen.backtrace ()))
  )

let hashtbl__4 = lazy (
  return (if (Key_gen.randomize_hashtables ()) then Hashtbl.randomize ())
  )

let gc__5 = lazy (
  return (
let open Gc in
  let ctrl = get () in
  set ({ ctrl with allocation_policy = (match (Key_gen.allocation_policy ()) with `Next_fit -> 0 | `First_fit -> 1 | `Best_fit -> 2);
  minor_heap_size = (match (Key_gen.minor_heap_size ()) with None -> ctrl.minor_heap_size | Some x -> x);
  major_heap_increment = (match (Key_gen.major_heap_increment ()) with None -> ctrl.major_heap_increment | Some x -> x);
  space_overhead = (match (Key_gen.space_overhead ()) with None -> ctrl.space_overhead | Some x -> x);
  max_overhead = (match (Key_gen.max_space_overhead ()) with None -> ctrl.max_overhead | Some x -> x);
  verbose = (match (Key_gen.gc_verbosity ()) with None -> ctrl.verbose | Some x -> x);
  window_size = (match (Key_gen.gc_window_size ()) with None -> ctrl.window_size | Some x -> x);
  custom_major_ratio = (match (Key_gen.custom_major_ratio ()) with None -> ctrl.custom_major_ratio | Some x -> x);
  custom_minor_ratio = (match (Key_gen.custom_minor_ratio ()) with None -> ctrl.custom_minor_ratio | Some x -> x);
  custom_minor_max_size = (match (Key_gen.custom_minor_max_size ()) with None -> ctrl.custom_minor_max_size | Some x -> x) })
)
  )

let pclock__6 = lazy (
  return ()
  )

let mirage_logs_make__7 = lazy (
  let __pclock__6 = Lazy.force pclock__6 in
  __pclock__6 >>= fun _pclock__6 ->
  let ring_size = None in
  let reporter = Mirage_logs_make__7.create ?ring_size () in
  Mirage_runtime.set_level ~default:(Some Logs.Info) (Key_gen.logs ());
  Mirage_logs_make__7.set_reporter reporter;
  Lwt.return reporter
  )

let unix_os_time__8 = lazy (
  return ()
  )

let unikernel_hello__9 = lazy (
  let __unix_os_time__8 = Lazy.force unix_os_time__8 in
  __unix_os_time__8 >>= fun _unix_os_time__8 ->
  Unikernel_hello__9.start _unix_os_time__8
  )

let mirage_runtime__10 = lazy (
  let __key_gen__2 = Lazy.force key_gen__2 in
  let __printexc__3 = Lazy.force printexc__3 in
  let __hashtbl__4 = Lazy.force hashtbl__4 in
  let __gc__5 = Lazy.force gc__5 in
  let __mirage_logs_make__7 = Lazy.force mirage_logs_make__7 in
  let __unikernel_hello__9 = Lazy.force unikernel_hello__9 in
  __key_gen__2 >>= fun _key_gen__2 ->
  __printexc__3 >>= fun _printexc__3 ->
  __hashtbl__4 >>= fun _hashtbl__4 ->
  __gc__5 >>= fun _gc__5 ->
  __mirage_logs_make__7 >>= fun _mirage_logs_make__7 ->
  __unikernel_hello__9 >>= fun _unikernel_hello__9 ->
  return ()
  )

let () =
  let t =
  Lazy.force key_gen__2 >>= fun _ ->
    Lazy.force printexc__3 >>= fun _ ->
    Lazy.force hashtbl__4 >>= fun _ ->
    Lazy.force gc__5 >>= fun _ ->
    Lazy.force mirage_logs_make__7 >>= fun _ ->
    Lazy.force mirage_runtime__10
  in run t

let () =
  Alcotest.run "Explore"
    [
      ("Collections", Test_collection.tests);
      ("Files", Test_files.tests);
      ("Toc", Test_toc.tests);
    ]

(let [snap (require :snap)
      fzy (require :snap.vendor.fzy-lua-native.lua)]
  (fn [producer]
    "Adds positions to results"
    (fn [request]
      (each [results (snap.consume producer request)]
        (match (type results)
          "table" (coroutine.yield
                    (if (= request.filter "")
                      results
                      (vim.tbl_map
                        (fn [result]
                          (snap.with_meta result :positions (fzy.positions request.filter (tostring result))))
                        results)))
          "nil" (coroutine.yield nil))))))

#!/usr/bin/env bb

(require '[babashka.process :as p])
(require '[cheshire.core :as json])
(require '[clojure.pprint :as pp])

(defmacro debug [sym] `(do (println ~(keyword sym)) (pp/pprint ~sym) (println)))

(def outputs
  (-> (p/sh ["swaymsg" "-t" "get_outputs"])
      :out
      (json/parse-string true)))

(def focused-output (some #(when (:focused %) %) outputs))

(debug focused-output)

(defn set-output-scale [scale]
  (p/sh ["swaymsg" "output" "-" "scale" scale]))

(cond (== 1 (:scale focused-output)) (set-output-scale 1.5)
      ;; (== 1.5 current-scale) (set-output-scale 2)
      :else (set-output-scale 1.0))


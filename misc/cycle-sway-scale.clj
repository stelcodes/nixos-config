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

(def current-scale (-> focused-output :scale (* 10) Math/round (/ 10) double))

(debug current-scale)

(cond (= 1.0 current-scale) (set-output-scale 1.7)
      ;; (= 1. current-scale) (set-output-scale 2.0)
      :else (set-output-scale 1.0))


#!/usr/bin/env bb

(require '[babashka.process :as p])
(require '[cheshire.core :as json])
(require '[clojure.pprint :as pp])

(defmacro debug [sym] `(do (println ~(keyword sym)) (pp/pprint ~sym) (println)))

(defn set-output-scale [scale]
  (p/sh ["swaymsg" "output" "eDP-1" "scale" scale]))

(def outputs
  (-> (p/sh ["swaymsg" "-t" "get_outputs"])
      :out
      (json/parse-string true)))

(debug outputs)

(def current-scale (:scale (some #(when (= "eDP-1" (:name %)) %) outputs)))

(debug current-scale)

(cond (== 1 current-scale) (set-output-scale 1.5)
      ;; (== 1.5 current-scale) (set-output-scale 2)
      :else (set-output-scale 1))

